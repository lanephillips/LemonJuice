//
//  CTNiceCrypto.m
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

#import "CTNiceCrypto.h"
#import "CTCrypto.h"

// Valid sizes are currently 512, 1024, and 2048.
#define kAsymmetricSecKeyPairModulusSize 512

@interface CTNiceCrypto ()

@property (nonatomic) CTCrypto* crypto;
@property (retain) NSOperationQueue * cryptoQueue;

@end

@implementation CTNiceCrypto

- (id)init
{
    self = [super init];
    if (self) {
        self.crypto = [[CTCrypto alloc] init];
        
        self.cryptoQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)generateKeyPairOfSize:(NSInteger)size completion:(void (^)())completion
{
    [self.cryptoQueue addOperationWithBlock:^{
        [self.crypto generateKeyPair:size];
        dispatch_async(dispatch_get_main_queue(), completion);
    }];
}

- (void)deleteKeyPair:(void (^)())completion
{
    [self.cryptoQueue addOperationWithBlock:^{
        [self.crypto deleteAsymmetricKeys];
        dispatch_async(dispatch_get_main_queue(), completion);
    }];
}

- (NSString*)base64EncodedPublicKey
{
    return [[self.crypto getPublicKeyBits] base64EncodedStringWithOptions:0];
}

- (void)encryptString:(NSString *)plainText withPublicKey:(NSData *)key completion:(void (^)(NSString *))completion
{
    if (plainText.length == 0) {
        // shouldn't get here, but let's not send a bad URL
        plainText = @"This message was intentionally left blank.";
    }
    
    [self.cryptoQueue addOperationWithBlock:^{
        NSString* keyNick = [key base64EncodedStringWithOptions:0];
        SecKeyRef keyref = [self.crypto addPeerPublicKey:keyNick keyBits:key];
        NSData* plaindata = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        
        NSInteger blockSize = SecKeyGetBlockSize(keyref) - kPKCS1;
        NSMutableData* cipherdata = [[NSMutableData alloc] initWithCapacity:(plaindata.length + blockSize - 1) / blockSize * (blockSize + kPKCS1)];
        
        for (NSInteger offset = 0; offset < plaindata.length; offset += blockSize) {
            NSData* block = [plaindata subdataWithRange:NSMakeRange(offset, MIN(blockSize, plaindata.length - offset))];
            block = [self.crypto encryptBlock:block keyRef:keyref];
            [cipherdata appendData:block];
        }
        
        [self.crypto removePeerPublicKey:keyNick];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([cipherdata base64EncodedStringWithOptions:0]);
        });
    }];
}

- (void)decryptBase64EncodedString:(NSString *)cipherText completion:(void (^)(NSString *))completion
{
    [self.cryptoQueue addOperationWithBlock:^{
        SecKeyRef key = [self.crypto getPrivateKeyRef];
        if (!key) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([NSString stringWithFormat:@"You don't have a private key to decrypt this message: %@", cipherText]);
            });
            return;
        }
        
        NSData* cipherdata = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
        
        NSInteger blockSize = SecKeyGetBlockSize(key);
        NSMutableData* plaindata = [[NSMutableData alloc] initWithCapacity:cipherdata.length / blockSize * (blockSize - kPKCS1)];
        
        for (NSInteger offset = 0; offset < cipherdata.length; offset += blockSize) {
            NSData* block = [cipherdata subdataWithRange:NSMakeRange(offset, MIN(blockSize, cipherdata.length - offset))];
            block = [self.crypto decryptBlock:block];
            if (!block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion([NSString stringWithFormat:@"This message could not be decrypted with your private key: %@", cipherText]);
                });
                return;
            }
            [plaindata appendData:block];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([[NSString alloc] initWithData:plaindata encoding:NSUTF8StringEncoding]);
        });
    }];
}

@end
