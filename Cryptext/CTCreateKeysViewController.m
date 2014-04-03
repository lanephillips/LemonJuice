//
//  CTCreateKeysViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTCreateKeysViewController.h"
#import "CTAppDelegate.h"

@implementation CTCreateKeysViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [APP.crypto generateKeyPair:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
