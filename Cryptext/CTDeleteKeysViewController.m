//
//  CTDeleteKeysViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTDeleteKeysViewController.h"
#import "CTAppDelegate.h"
#import "SecKeyWrapper.h"

@interface CTDeleteKeysViewController ()
<UIAlertViewDelegate>

@end

@implementation CTDeleteKeysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[UIAlertView alloc] initWithTitle:@"Delete Keys"
                                message:@"Are you sure you want to delete your public and private keys? You will not be able to decrypt messages you previously received."
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil]
     show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - alert view

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self startDeletingKeys];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - key deletion

- (IBAction)startDeletingKeys
{
    NSInvocationOperation * delOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(deleteKeyPairOperation) object:nil];
    [APP.cryptoQueue addOperation:delOp];
}

- (void)deleteKeyPairOperation
{
    @autoreleasepool {
        [[SecKeyWrapper sharedWrapper] deleteAsymmetricKeys];
        //        [[SecKeyWrapper sharedWrapper] generateSymmetricKey];
        [self performSelectorOnMainThread:@selector(deleteKeyPairCompleted) withObject:nil waitUntilDone:NO];
    }
}

- (void)deleteKeyPairCompleted
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
