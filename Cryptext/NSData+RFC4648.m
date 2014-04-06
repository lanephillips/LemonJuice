//
//  NSData+RFC4648.m
//  Cryptext
//
//  Created by Lane Phillips (@bugloaf) on 3/31/14.
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

#import "NSData+RFC4648.h"

@implementation NSData (RFC4648)

//+ (instancetype)dataWithRFC4648Base64EncodedString:(NSString*)s
//{
//    s = [s stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
//    s = [s stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
//    while (s.length % 4 > 0) {  // this is still not right
//        s = [s stringByAppendingString:@"="];
//    }
//    return [[NSData alloc] initWithBase64EncodedString:s options:0];
//}
//
//- (NSString *)rfc4648Base64EncodedString
//{
//    NSString* key = [self base64EncodedStringWithOptions:0];
//    // URL safe substitutions according to RFC 4648: http://en.wikipedia.org/wiki/Base64
//    key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
//    key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
//    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
//    return key;
//}

@end
