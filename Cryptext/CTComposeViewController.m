//
//  CTComposeViewController.m
//  Cryptext
//
//  Created by Lane Phillips (@bugloaf) on 4/1/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Milk LLC (@Milk_LLC).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.messageTxt becomeFirstResponder];
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
                       vc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
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

