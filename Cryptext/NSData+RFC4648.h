//
//  NSData+RFC4648.h
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RFC4648)

- (NSString*)rfc4648Base64EncodedString;

@end
