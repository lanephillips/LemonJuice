//
//  CTMasterViewController.h
//  Cryptext
//
//  Created by Lane Phillips on 3/29/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface CTMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
