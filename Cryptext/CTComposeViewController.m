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

@interface CTMessageProvider : NSObject
<UIActivityItemSource>

@property (nonatomic) NSString* message;

@end

@interface CTComposeViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTxt;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (nonatomic) NSString* cipherURL;

@end

@implementation CTComposeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isMovingToParentViewController) {
        self.messageTxt.text = @"";
    }
    self.title = [NSString stringWithFormat:@"Message to %@", self.contact.nickname];
    self.navigationItem.rightBarButtonItem.enabled = self.messageTxt.text.length > 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController) {
        self.messageTxt.text = @"";
    }
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
                       self.spinnerView.hidden = YES;
                       
                       self.cipherURL = [NSString stringWithFormat:@"lmnj://m?%@", base64EncodedCiphertext];
                       CTMessageProvider* provider = [[CTMessageProvider alloc] init];
                       provider.message = self.cipherURL;
                       
                       UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:@[provider]
                                                                                        applicationActivities:nil];
                       vc.completionHandler = ^(NSString *activityType, BOOL completed) {
                           if (completed) {
                               self.messageTxt.text = @"";
                               [self.navigationController popViewControllerAnimated:YES];
                           }
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

- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = textView.text.length > 0;
}

@end

@implementation CTMessageProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.message;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    return @"Lemon Juice Encrypted Message";
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end

