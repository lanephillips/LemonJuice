//
//  CTAppDelegate.h
//  Cryptext
//
//  Created by Lane Phillips on 3/29/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTCrypto.h"

@interface CTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) CTCrypto* crypto;
@property (retain) NSOperationQueue * cryptoQueue;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

#define APP ((CTAppDelegate *)[UIApplication sharedApplication].delegate)