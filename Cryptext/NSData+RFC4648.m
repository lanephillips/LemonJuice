//
//  NSData+RFC4648.m
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "NSData+RFC4648.h"

@implementation NSData (RFC4648)

- (NSString *)rfc4648Base64EncodedString
{
    NSString* key = [self base64EncodedStringWithOptions:0];
    // URL safe substitutions according to RFC 4648: http://en.wikipedia.org/wiki/Base64
    key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    return key;
}

@end
