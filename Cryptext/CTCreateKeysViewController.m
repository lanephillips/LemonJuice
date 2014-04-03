//
//  CTCreateKeysViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 3/31/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTCreateKeysViewController.h"
#import "CTAppDelegate.h"

// Valid sizes are currently 512, 1024, and 2048.
#define kAsymmetricSecKeyPairModulusSize 512

@interface CTCreateKeysViewController ()

@end

@implementation CTCreateKeysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startGeneratingKeys];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - key pair generation

- (IBAction)startGeneratingKeys
{
    // start generation operation
    NSInvocationOperation * genOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(generateKeyPairOperation) object:nil];
    [APP.cryptoQueue addOperation:genOp];
}

- (void)generateKeyPairOperation
{
    @autoreleasepool {
        // Generate the asymmetric key (public and private)
        [APP.crypto generateKeyPair:kAsymmetricSecKeyPairModulusSize];
        //        [APP.crypto generateSymmetricKey];
        [self performSelectorOnMainThread:@selector(generateKeyPairCompleted) withObject:nil waitUntilDone:NO];
    }
}

- (void)generateKeyPairCompleted
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelKeyGeneration
{
}

@end
