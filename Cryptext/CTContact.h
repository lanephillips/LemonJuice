//
//  CTContact.h
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CTContact : NSManagedObject

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSData * key;
@property (nonatomic, retain) NSDate * dateAdded;

+ (instancetype)contactForKey:(NSData*)key inContext:(NSManagedObjectContext*)ctx create:(BOOL)create isNew:(BOOL*)isNew;

@end
