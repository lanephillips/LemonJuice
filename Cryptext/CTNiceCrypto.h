//
//  CTNiceCrypto.h
//  Cryptext
//
//  Created by Lane Phillips on 4/2/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// friendlier interface than CTCrypto
@interface CTNiceCrypto : NSObject

- (void)generateKeyPair:(void(^)())completion;
- (void)deleteKeyPair:(void(^)())completion;

- (NSString*)base64EncodedPublicKey;

- (void)encryptString:(NSString*)plainText
        withPublicKey:(NSData*)key
           completion:(void(^)(NSString* base64EncodedCiphertext))completion;

- (void)decryptBase64EncodedString:(NSString*)ciphertext
                        completion:(void(^)(NSString* plaintext))completion;

@end
