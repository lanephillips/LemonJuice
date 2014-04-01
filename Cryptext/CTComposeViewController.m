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
<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTxt;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;

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
        // TODO: assumes a short message!!
        NSData* msg = [message dataUsingEncoding:NSUTF8StringEncoding];
        msg = [[SecKeyWrapper sharedWrapper] wrapSymmetricKey:msg keyRef:key];
        [[SecKeyWrapper sharedWrapper] removePeerPublicKey:self.contact.nickname];
        [self performSelectorOnMainThread:@selector(encryptionCompleted:) withObject:msg waitUntilDone:NO];
    }
}

- (void)encryptionCompleted:(NSData*)message
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = [NSString stringWithFormat:@"cryptext://m?%@", [message base64EncodedStringWithOptions:0]];
        //        controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - message delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
