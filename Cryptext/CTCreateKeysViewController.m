//
//  CTCreateKeysViewController.m
//  Cryptext
//
//  Created by Lane Phillips (@bugloaf) on 3/31/14.
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
