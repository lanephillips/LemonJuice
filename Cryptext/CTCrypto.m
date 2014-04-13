//
//  CTCrypto.m
//  Cryptext
//
//  Created by Lane Phillips (@bugloaf) on 4/2/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Milk LLC (@Milk_LLC).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// Much of this code was copied from Apple's SecKeyWrapper class.
// Here's the notice from that file:

/*
 
 File: SecKeyWrapper.m
 Abstract: Core cryptographic wrapper class to exercise most of the Security
 APIs on the iPhone OS. Start here if all you are interested in are the
 cryptographic APIs on the iPhone OS.
 
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.
 
 */

#import "CTCrypto.h"

#define kTypeOfWrapPadding		kSecPaddingPKCS1

#define kPublicKeyTag			"com.milkllc.cryptext.publickey"
#define kPrivateKeyTag			"com.milkllc.cryptext.privatekey"

@interface CTCrypto ()
{
	NSData * publicTag;
	NSData * privateTag;
    SecKeyRef publicKeyRef;
	SecKeyRef privateKeyRef;
}

@property (nonatomic, retain) NSData * publicTag;
@property (nonatomic, retain) NSData * privateTag;

@end

@implementation CTCrypto

@synthesize publicTag, privateTag;

#if DEBUG
#define LOGGING_FACILITY(X, Y)	\
NSAssert(X, Y);

#define LOGGING_FACILITY1(X, Y, Z)	\
NSAssert1(X, Y, Z);
#else
#define LOGGING_FACILITY(X, Y)	\
if (!(X)) {			\
NSLog(Y);		\
}

#define LOGGING_FACILITY1(X, Y, Z)	\
if (!(X)) {				\
NSLog(Y, Z);		\
}
#endif

static const uint8_t publicKeyIdentifier[]		= kPublicKeyTag;
static const uint8_t privateKeyIdentifier[]		= kPrivateKeyTag;

-(id)init {
    if (self = [super init])
    {
        // Tag data to search for keys.
        privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
        publicTag = [[NSData alloc] initWithBytes:publicKeyIdentifier length:sizeof(publicKeyIdentifier)];
    }
	
	return self;
}

- (void)deleteAsymmetricKeys {
	OSStatus sanityCheck = noErr;
	NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
	
	// Set the public key query dictionary.
	[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	
	// Set the private key query dictionary.
	[queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
	[queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	
	// Delete the private key.
	sanityCheck = SecItemDelete((CFDictionaryRef)queryPrivateKey);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %d.", (int)sanityCheck );
	
	// Delete the public key.
	sanityCheck = SecItemDelete((CFDictionaryRef)queryPublicKey);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %d.", (int)sanityCheck );
	
	[queryPrivateKey release];
	[queryPublicKey release];
	if (publicKeyRef) {
        CFRelease(publicKeyRef);
        publicKeyRef = NULL;
    }
	if (privateKeyRef) {
        CFRelease(privateKeyRef);
        privateKeyRef = NULL;
    }
}

- (void)generateKeyPair:(NSUInteger)keySize {
	OSStatus sanityCheck = noErr;
	publicKeyRef = NULL;
	privateKeyRef = NULL;
	
	LOGGING_FACILITY1( keySize == 512 || keySize == 1024 || keySize == 2048, @"%lu is an invalid and unsupported key size.", (unsigned long)keySize );
	
	// First delete current keys.
	[self deleteAsymmetricKeys];
	
	// Container dictionaries.
	NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
	
	// Set top level dictionary for the keypair.
	[keyPairAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keySize] forKey:(id)kSecAttrKeySizeInBits];
	
	// Set the private key dictionary.
	[privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
	[privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
	// See SecKey.h to set other flag values.
	
	// Set the public key dictionary.
	[publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
	[publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	// See SecKey.h to set other flag values.
	
	// Set attributes to top level dictionary.
	[keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
	[keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
	
	// SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
	sanityCheck = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
	LOGGING_FACILITY( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL, @"Something really bad went wrong with generating the key pair." );
	
	[privateKeyAttr release];
	[publicKeyAttr release];
	[keyPairAttr release];
}

- (SecKeyRef)addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey {
	OSStatus sanityCheck = noErr;
	SecKeyRef peerKeyRef = NULL;
	CFTypeRef persistPeer = NULL;
	
	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	LOGGING_FACILITY( publicKey != nil, @"Public key parameter is nil." );
	
	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
	
	[peerPublicKeyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[peerPublicKeyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[peerPublicKeyAttr setObject:peerTag forKey:(id)kSecAttrApplicationTag];
	[peerPublicKeyAttr setObject:publicKey forKey:(id)kSecValueData];
	[peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];
	
	sanityCheck = SecItemAdd((CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);
	
	// The nice thing about persistent references is that you can write their value out to disk and
	// then use them later. I don't do that here but it certainly can make sense for other situations
	// where you don't want to have to keep building up dictionaries of attributes to get a reference.
	//
	// Also take a look at SecKeyWrapper's methods (CFTypeRef)getPersistentKeyRefWithKeyRef:(SecKeyRef)key
	// & (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef.
	
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecDuplicateItem, @"Problem adding the peer public key to the keychain, OSStatus == %d.", (int)sanityCheck );
	
	if (persistPeer) {
		peerKeyRef = [self getKeyRefWithPersistentKeyRef:persistPeer];
	} else {
		[peerPublicKeyAttr removeObjectForKey:(id)kSecValueData];
		[peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		// Let's retry a different way.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);
	}
	
	LOGGING_FACILITY1( sanityCheck == noErr && peerKeyRef != NULL, @"Problem acquiring reference to the public key, OSStatus == %d.", (int)sanityCheck );
	
	[peerTag release];
	[peerPublicKeyAttr release];
	if (persistPeer) CFRelease(persistPeer);
	return peerKeyRef;
}

- (void)removePeerPublicKey:(NSString *)peerName {
	OSStatus sanityCheck = noErr;
	
	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	
	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
	
	[peerPublicKeyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[peerPublicKeyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[peerPublicKeyAttr setObject:peerTag forKey:(id)kSecAttrApplicationTag];
	
	sanityCheck = SecItemDelete((CFDictionaryRef) peerPublicKeyAttr);
	
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Problem deleting the peer public key to the keychain, OSStatus == %d.", (int)sanityCheck );
	
	[peerTag release];
	[peerPublicKeyAttr release];
}

- (NSData *)encryptBlock:(NSData *)symmetricKey keyRef:(SecKeyRef)publicKey {
	OSStatus sanityCheck = noErr;
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
	LOGGING_FACILITY( symmetricKey != nil, @"Symmetric key parameter is nil." );
	LOGGING_FACILITY( publicKey != nil, @"Key parameter is nil." );
	
	NSData * cipher = nil;
	uint8_t * cipherBuffer = NULL;
	
	// Calculate the buffer sizes.
	cipherBufferSize = SecKeyGetBlockSize(publicKey);
	keyBufferSize = [symmetricKey length];
	
	if (kTypeOfWrapPadding == kSecPaddingNone) {
		LOGGING_FACILITY( keyBufferSize <= cipherBufferSize, @"Nonce integer is too large and falls outside multiplicative group." );
	} else {
		LOGGING_FACILITY( keyBufferSize <= (cipherBufferSize - 11), @"Nonce integer is too large and falls outside multiplicative group." );
	}
	
	// Allocate some buffer space. I don't trust calloc.
	cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
	memset((void *)cipherBuffer, 0x0, cipherBufferSize);
	
	// Encrypt using the public key.
	sanityCheck = SecKeyEncrypt(	publicKey,
                                kTypeOfWrapPadding,
                                (const uint8_t *)[symmetricKey bytes],
                                keyBufferSize,
                                cipherBuffer,
                                &cipherBufferSize
								);
	
	LOGGING_FACILITY1( sanityCheck == noErr, @"Error encrypting, OSStatus == %d.", (int)sanityCheck );
	
	// Build up cipher text blob.
	cipher = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
	
	if (cipherBuffer) free(cipherBuffer);
	
	return cipher;
}

- (NSData *)decryptBlock:(NSData *)wrappedSymmetricKey {
	OSStatus sanityCheck = noErr;
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
	NSData * key = nil;
	uint8_t * keyBuffer = NULL;
	
	SecKeyRef privateKey = NULL;
	
	privateKey = [self getPrivateKeyRef];
	LOGGING_FACILITY( privateKey != NULL, @"No private key found in the keychain." );
	
	// Calculate the buffer sizes.
	cipherBufferSize = SecKeyGetBlockSize(privateKey);
	keyBufferSize = [wrappedSymmetricKey length];
	
	LOGGING_FACILITY( keyBufferSize <= cipherBufferSize, @"Encrypted nonce is too large and falls outside multiplicative group." );
	
	// Allocate some buffer space. I don't trust calloc.
	keyBuffer = malloc( keyBufferSize * sizeof(uint8_t) );
	memset((void *)keyBuffer, 0x0, keyBufferSize);
	
	// Decrypt using the private key.
	sanityCheck = SecKeyDecrypt(	privateKey,
                                kTypeOfWrapPadding,
                                (const uint8_t *) [wrappedSymmetricKey bytes],
                                cipherBufferSize,
                                keyBuffer,
                                &keyBufferSize
								);
	
    if (sanityCheck != noErr) {
        // this will happen if the key does not match
        NSLog(@"Error decrypting, OSStatus == %d.", (int)sanityCheck );
        key = nil;
    } else {
        // Build up plain text blob.
        key = [NSData dataWithBytes:(const void *)keyBuffer length:(NSUInteger)keyBufferSize];
    }
    
	if (keyBuffer) free(keyBuffer);
	
	return key;
}

- (SecKeyRef)getPublicKeyRef {
	OSStatus sanityCheck = noErr;
	SecKeyRef publicKeyReference = NULL;
	
	if (publicKeyRef == NULL) {
		NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
		
		// Set the public key query dictionary.
		[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
		[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
		[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
		[queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
		// Get the key.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
		
		if (sanityCheck != noErr)
		{
			publicKeyReference = NULL;
		}
		
		[queryPublicKey release];
	} else {
		publicKeyReference = publicKeyRef;
	}
	
	return publicKeyReference;
}

- (NSData *)getPublicKeyBits {
	OSStatus sanityCheck = noErr;
	NSData * publicKeyBits = nil;
	
	NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
    
	// Set the public key query dictionary.
	[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
    
	// Get the key bits.
	sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyBits);
    
	if (sanityCheck != noErr)
	{
		publicKeyBits = nil;
	}
    
	[queryPublicKey release];
	
	return publicKeyBits;
}

- (SecKeyRef)getPrivateKeyRef {
	OSStatus sanityCheck = noErr;
	SecKeyRef privateKeyReference = NULL;
	
	if (privateKeyRef == NULL) {
		NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
		
		// Set the private key query dictionary.
		[queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
		[queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
		[queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
		[queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
		// Get the key.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
		
		if (sanityCheck != noErr)
		{
			privateKeyReference = NULL;
		}
		
		[queryPrivateKey release];
	} else {
		privateKeyReference = privateKeyRef;
	}
	
	return privateKeyReference;
}

- (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef {
	OSStatus sanityCheck = noErr;
	SecKeyRef keyRef = NULL;
	
	LOGGING_FACILITY(persistentRef != NULL, @"persistentRef object cannot be NULL." );
	
	NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
	
	// Set the SecKeyRef query dictionary.
	[queryKey setObject:(id)persistentRef forKey:(id)kSecValuePersistentRef];
	[queryKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
	
	// Get the persistent key reference.
	sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryKey, (CFTypeRef *)&keyRef);
	[queryKey release];
	
	return keyRef;
}

- (void)dealloc {
    [privateTag release];
    [publicTag release];
	if (publicKeyRef) CFRelease(publicKeyRef);
	if (privateKeyRef) CFRelease(privateKeyRef);
    [super dealloc];
}

@end
