//
//  CTDecryptViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTDecryptViewController.h"
#import "CTAppDelegate.h"

@interface CTDecryptViewController ()

@property (weak, nonatomic) IBOutlet UITextView *messageTxt;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;

@end

@implementation CTDecryptViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.messageTxt.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.spinnerView.hidden = NO;
    [APP.crypto decryptBase64EncodedString:self.message
                                completion:^(NSString *plaintext) {
                                    self.messageTxt.text = plaintext;
                                    self.spinnerView.hidden = YES;
                                }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.messageTxt.text = @"";
    [super viewWillDisappear:animated];
}

@end
