//
//  CTContact.m
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTContact.h"


@implementation CTContact

@dynamic nickname;
@dynamic key;
@dynamic dateAdded;

+ (instancetype)contactForKey:(NSData *)key inContext:(NSManagedObjectContext *)ctx create:(BOOL)create isNew:(BOOL*)isNew
{
    *isNew = NO;
    
    NSFetchRequest* r = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    [r setPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
    
    NSError* err = nil;
    NSArray* a = [ctx executeFetchRequest:r error:&err];
    if (!a) {
        // TODO: report this
        NSLog(@"error during contact fetch %@", err);
        a = @[];
    }
    
    if (create && a.count == 0) {
        *isNew = YES;
        NSEntityDescription* ed = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:ctx];
        CTContact* c = [[CTContact alloc] initWithEntity:ed insertIntoManagedObjectContext:ctx];
        c.key = key;
        c.dateAdded = [NSDate date];
        c.nickname = @"";
        a = @[c];
    }
    
    return a.firstObject;
}

@end
