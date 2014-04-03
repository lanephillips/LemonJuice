//
//  CTCrypto.h
//  Cryptext
//
//  Created by Lane Phillips on 4/2/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonCryptor.h>

// TODO: better name for padding size
#define	kPKCS1					11

// common crypto functions
// based on Apple's SecKeyWrapper
@interface CTCrypto : NSObject

- (void)generateKeyPair:(NSUInteger)keySize;
- (void)deleteAsymmetricKeys;

- (SecKeyRef)addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey;
- (void)removePeerPublicKey:(NSString *)peerName;

- (SecKeyRef)getPublicKeyRef;
- (NSData *)getPublicKeyBits;
- (SecKeyRef)getPrivateKeyRef;

- (NSData *)encryptBlock:(NSData *)block keyRef:(SecKeyRef)publicKey;
- (NSData *)decryptBlock:(NSData *)block;

@end
