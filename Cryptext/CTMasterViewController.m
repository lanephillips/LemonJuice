//
//  CTMasterViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 3/29/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTMasterViewController.h"
#import "CTAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "NSData+RFC4648.h"
#import "CTContact.h"
#import "CTComposeViewController.h"
#import "CTWebViewController.h"
#import "CTAddContactViewController.h"

#define MAKE_LOADING_SCREEN 0

@interface CTPubkeyProvider : NSObject
<UIActivityItemSource>

@property (nonatomic) NSString* pubkey;

- (instancetype)initWithPubkey:(NSString*)pubkey;

@end

@interface CTMasterViewController ()
<MFMailComposeViewControllerDelegate>

@property (nonatomic) NSArray* section2;

@end

@implementation CTMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startGeneratingKeys)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    self.section2 = @[@"HowToCell", @"CreditCell", @"FeedbackCell", @"OtherAppsCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender
//{
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"createKeys"]) {

    } else if ([segue.identifier isEqualToString:@"shareKey"]) {
        // nope
    } else if ([segue.identifier isEqualToString:@"destroyKeys"]) {

    } else if ([segue.identifier isEqualToString:@"sendMessage"]) {
        CTComposeViewController* vc = segue.destinationViewController;
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        indexPath = [self shiftIndexPath:indexPath bySections:-1];
        CTContact *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        vc.contact = object;
    } else if ([segue.identifier isEqualToString:@"howTo"]) {
        CTWebViewController* vc = segue.destinationViewController;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"howto" withExtension:@"html"];
        NSError* err = nil;
        vc.title = @"How To";
        vc.html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    } else if ([segue.identifier isEqualToString:@"whoMade"]) {
        CTWebViewController* vc = segue.destinationViewController;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"credits" withExtension:@"html"];
        NSError* err = nil;
        vc.title = @"Credits";
        vc.html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if !MAKE_LOADING_SCREEN
    return 2 + [[self.fetchedResultsController sections] count];
#else
    return 3;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if !MAKE_LOADING_SCREEN
    if (section == 0) {
        NSString* pubKey = [APP.crypto base64EncodedPublicKey];
        return pubKey? 2 : 1;
    }
    
    if (section == 1 + [[self.fetchedResultsController sections] count]) {
        return self.section2.count;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section - 1];
    return [sectionInfo numberOfObjects];
#else
    return 1;
#endif
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Your Keys";
    }
#if !MAKE_LOADING_SCREEN
    if (section == 1 + [[self.fetchedResultsController sections] count]) {
        return @"Etc.";
    }
#else
    if (section == 2) {
        return @"Etc.";
    }
#endif
    return @"Your Contacts";
}

#if !MAKE_LOADING_SCREEN
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.fetchedResultsController.sections.count == 1) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections.firstObject;
        if ([sectionInfo objects].count == 0) {
            return 22;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.fetchedResultsController.sections.count == 1) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections.firstObject;
        if ([sectionInfo objects].count == 0) {
            UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectZero];
            lbl.font = [UIFont italicSystemFontOfSize:15];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = @"You have not added any contacts.";
            lbl.textColor = [UIColor lightGrayColor];
            return lbl;
        }
    }
    return nil;
}
#endif

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if !MAKE_LOADING_SCREEN
    if (indexPath.section == 0) {
        NSString* pubKey = [APP.crypto base64EncodedPublicKey];
        if (pubKey && indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell" forIndexPath:indexPath];
//            cell.detailTextLabel.text = pubKey.rfc4648Base64EncodedString;
            cell.detailTextLabel.text = pubKey;
            return cell;
        } else if (pubKey && indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DestroyCell" forIndexPath:indexPath];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateCell" forIndexPath:indexPath];
            // TODO: use storyboard segues
            cell.textLabel.text = @"Create Your Key";
            return cell;
        }
    }

    if (indexPath.section == 1 + [[self.fetchedResultsController sections] count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.section2[indexPath.row] forIndexPath:indexPath];
        return cell;
    }

    indexPath = [self shiftIndexPath:indexPath bySections:-1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
#else
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
    return cell;
#endif
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.section > 0 && indexPath.section < 1 + [[self.fetchedResultsController sections] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        indexPath = [self shiftIndexPath:indexPath bySections:-1];
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSString* pubKey = [APP.crypto base64EncodedPublicKey];
        if (pubKey && indexPath.row == 0) { // share
            UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:@[[[CTPubkeyProvider alloc] initWithPubkey:pubKey]]
                                                                             applicationActivities:nil];
            vc.completionHandler = ^(NSString *activityType, BOOL completed) {
                NSLog(@"%@ %d", activityType, completed);
            };
            [self presentViewController:vc animated:YES completion:nil];
        } else if (pubKey && indexPath.row == 1) {
            // use segue
        } else {
            // use segue
        }
    }
    else if (indexPath.section == 1 + [[self.fetchedResultsController sections] count]) {
        if (indexPath.row == 2) {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* vc = [[MFMailComposeViewController alloc] init];
                vc.mailComposeDelegate = self;
                [vc setToRecipients:[NSArray arrayWithObject:@"lemon-juice-feedback@milkllc.com"]];
                [vc setSubject:@"Lemon Juice Feedback"];
                
                NSMutableString* s = [[NSMutableString alloc] init];
                [s appendString:@"\n\n"];
                [s appendFormat:@"Device: %@, iOS Version: %@\n", [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion];
                NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
                [s appendFormat:@"App Version: %@, Build: %@", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
                [vc setMessageBody:s isHTML:NO];
                
                [self presentViewController:vc animated:YES completion:NULL];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Send Feedback"
                                            message:@"This device is not able to send mail. This usually means that you have not yet configured your mail app with an email account."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }
        else if (indexPath.row == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/MilkLLC"]];
        }
    } else {
        // use segue
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    CTAddContactViewController* addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addKey"];
    
    indexPath = [self shiftIndexPath:indexPath bySections:-1];
    CTContact *c = [self.fetchedResultsController objectAtIndexPath:indexPath];

    addVC.title = @"Edit Contact";
    addVC.contact = c;
    addVC.cancelHandler = ^() {
    };
    addVC.saveHandler = ^() {
        [APP saveContext];
    };
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Contacts"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + 1] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    indexPath = [self shiftIndexPath:indexPath bySections:1];
    newIndexPath = [self shiftIndexPath:newIndexPath bySections:1];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:[self shiftIndexPath:indexPath bySections:-1]];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CTContact *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.nickname;
    cell.detailTextLabel.text = [object.key base64EncodedStringWithOptions:0];
}

- (NSIndexPath*)shiftIndexPath:(NSIndexPath*)ip bySections:(NSInteger)dSec
{
    return [NSIndexPath indexPathForRow:ip.row inSection:ip.section + dSec];
}

@end

@implementation CTPubkeyProvider

- (instancetype)initWithPubkey:(NSString *)pubkey
{
    self = [super init];
    if (self) {
        self.pubkey = pubkey;
    }
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // shorter message
        return [NSString stringWithFormat:@"My Lemon Juice key is lmnj://pk?%@", self.pubkey];
    }
    return [NSString stringWithFormat:@"I'm using Lemon Juice for encrypted messaging (https://itunes.apple.com/us/app/lemon-juice/id854695407?ls=1&mt=8). Please add my public key: lmnj://pk?%@", self.pubkey];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end
