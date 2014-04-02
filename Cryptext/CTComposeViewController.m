//
//  CTComposeViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTComposeViewController.h"
#import "CTAppDelegate.h"
#import "SecKeyWrapper.h"
#import <MessageUI/MessageUI.h>

@interface CTComposeViewController ()
<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTxt;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (nonatomic) NSString* cipherURL;

@end

@implementation CTComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCancel:(id)sender
{
    self.messageTxt.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doSend:(id)sender
{
    [self startEncryption];
}

- (void)setContact:(CTContact *)contact
{
    _contact = contact;
    self.title = [NSString stringWithFormat:@"Message to %@", contact.nickname];
}

#pragma mark - encryption

- (IBAction)startEncryption
{
    // start operation
    NSInvocationOperation * genOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(encryptOperation:)
                                                                           object:self.messageTxt.text];
    self.messageTxt.text = @"";
    [APP.cryptoQueue addOperation:genOp];
    self.spinnerView.hidden = NO;
}

- (void)encryptOperation:(NSString*)message
{
    @autoreleasepool {
        SecKeyRef key = [[SecKeyWrapper sharedWrapper] addPeerPublicKey:self.contact.nickname keyBits:self.contact.key];
        NSData* plaintext = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        NSInteger blockSize = SecKeyGetBlockSize(key) - kPKCS1;
        NSMutableData* ciphertext = [[NSMutableData alloc] initWithCapacity:(plaintext.length + blockSize - 1) / blockSize * (blockSize + kPKCS1)];
        
        for (NSInteger offset = 0; offset < plaintext.length; offset += blockSize) {
            NSData* block = [plaintext subdataWithRange:NSMakeRange(offset, MIN(blockSize, plaintext.length - offset))];
            block = [[SecKeyWrapper sharedWrapper] wrapSymmetricKey:block keyRef:key];
            [ciphertext appendData:block];
        }
        
        [[SecKeyWrapper sharedWrapper] removePeerPublicKey:self.contact.nickname];
        [self performSelectorOnMainThread:@selector(encryptionCompleted:) withObject:ciphertext waitUntilDone:NO];
    }
}

- (void)encryptionCompleted:(NSData*)message
{
    self.cipherURL = [NSString stringWithFormat:@"cryptext://m?%@", [message base64EncodedStringWithOptions:0]];
    BOOL isLong = self.cipherURL.length > 160;
    BOOL canEmail = [MFMailComposeViewController canSendMail];
    BOOL canText = [MFMessageComposeViewController canSendText];
    
    if (canEmail && canText) {
        [[[UIAlertView alloc] initWithTitle:@"Send CrypText"
                                    message:(isLong ? @"This message is longer than 160 characters, you should probably send it as mail." :
                                             @"Do you want to send this as text or mail?")
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Text", @"Mail", nil]
         show];
    } else if (canText && !canEmail) {
        [self smsCiphertext];
    } else if (canEmail && !canText) {
        [self emailCiphertext];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Text or Email"
                                    message:[NSString stringWithFormat:@"This device can't send text or mail. Copy this URL to send the message: %@", self.cipherURL]
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil]
         show];
    }
}

- (void)smsCiphertext
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendAttachments] && self.cipherURL.length > 160) {
        controller.body = @"See the attached CrypText.";
        [controller addAttachmentData:[self.cipherURL dataUsingEncoding:NSUTF8StringEncoding]
                       typeIdentifier:@"public.url"
                             filename:@"CrypText URL"];
    } else {
        controller.body = self.cipherURL;
    }
    //        controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
    controller.messageComposeDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)emailCiphertext
{
    MFMailComposeViewController* vc = [[MFMailComposeViewController alloc] init];
    [vc setSubject:@"I sent you a CrypText"];
    [vc setMessageBody:self.cipherURL isHTML:NO];
    vc.mailComposeDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - message delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (result == MessageComposeResultFailed) {
            NSLog(@"Failed!");
        }
    }];
}

#pragma mark - mail delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent || result == MFMailComposeResultSaved) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (result == MFMailComposeResultFailed) {
            NSLog(@"Failed!");
        }
    }];
}

#pragma mark - alert delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"button %d, first %d", buttonIndex, alertView.firstOtherButtonIndex);
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self smsCiphertext];
    } else {
        [self emailCiphertext];
    }
}

@end
