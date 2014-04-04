//
//  CTComposeViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTComposeViewController.h"
#import "CTAppDelegate.h"
#import <MessageUI/MessageUI.h>

@interface CTComposeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *messageTxt;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (nonatomic) NSString* cipherURL;

@end

@implementation CTComposeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.messageTxt.text = @"";
    self.title = [NSString stringWithFormat:@"Message to %@", self.contact.nickname];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.messageTxt.text = @"";
    [super viewWillDisappear:animated];
}

- (IBAction)doCancel:(id)sender
{
    self.messageTxt.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doSend:(id)sender
{
    self.spinnerView.hidden = NO;
    [APP.crypto encryptString:self.messageTxt.text
                withPublicKey:self.contact.key
                   completion:^(NSString *base64EncodedCiphertext) {
                       self.messageTxt.text =base64EncodedCiphertext;
                       self.spinnerView.hidden = YES;
                       
                       self.cipherURL = [NSString stringWithFormat:@"lmnj://m?%@", base64EncodedCiphertext];
                       UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.cipherURL]
                                                                                        applicationActivities:nil];
                       vc.completionHandler = ^(NSString *activityType, BOOL completed) {
                           NSLog(@"%@ %d", activityType, completed);
                           [self.navigationController popViewControllerAnimated:YES];
                       };
                       if (self.cipherURL.length > 140) {
                           // exclude the microblogging sites if the message is too long
                           vc.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo];
                       }
                       [self presentViewController:vc animated:YES completion:nil];
                   }];
}

- (void)setContact:(CTContact *)contact
{
    _contact = contact;
    self.title = [NSString stringWithFormat:@"Message to %@", contact.nickname];
}

@end
