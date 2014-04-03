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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.messageTxt.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDecryption];
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

#pragma mark - decryption

- (IBAction)startDecryption
{
    // start operation
    NSInvocationOperation * genOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(decryptOperation:)
                                                                           object:self.message];
    self.messageTxt.text = @"";
    [APP.cryptoQueue addOperation:genOp];
    self.spinnerView.hidden = NO;
}

- (void)decryptOperation:(NSString*)message
{
    @autoreleasepool {
        SecKeyRef key = [APP.crypto getPrivateKeyRef];
        if (!key) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.messageTxt.text = [NSString stringWithFormat:@"You don't have a private key to decrypt this message: %@", message];
                self.spinnerView.hidden = YES;
            });
            return;
        }
        
        NSData* ciphertext = [[NSData alloc] initWithBase64EncodedString:message options:0];
        
        NSInteger blockSize = SecKeyGetBlockSize(key);
        NSMutableData* plaintext = [[NSMutableData alloc] initWithCapacity:ciphertext.length / blockSize * (blockSize - kPKCS1)];
        
        for (NSInteger offset = 0; offset < ciphertext.length; offset += blockSize) {
            NSData* block = [ciphertext subdataWithRange:NSMakeRange(offset, MIN(blockSize, ciphertext.length - offset))];
            block = [APP.crypto decryptBlock:block];
            [plaintext appendData:block];
        }
        
        [self performSelectorOnMainThread:@selector(decryptionCompleted:) withObject:plaintext waitUntilDone:NO];
    }
}

- (void)decryptionCompleted:(NSData*)message
{
    self.messageTxt.text = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    self.spinnerView.hidden = YES;
}

@end
