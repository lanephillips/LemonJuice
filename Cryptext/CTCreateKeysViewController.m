//
//  CTCreateKeysViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTCreateKeysViewController.h"
#import "CTAppDelegate.h"

@interface CTCreateKeysViewController ()
<UIActionSheetDelegate>

@end

@implementation CTCreateKeysViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UIActionSheet* a = [[UIActionSheet alloc] initWithTitle:@"RSA Key Size"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"512", @"1024", @"2048", nil];
    [a showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSInteger size = [actionSheet buttonTitleAtIndex:buttonIndex].integerValue;
    
    [APP.crypto generateKeyPairOfSize:size completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
