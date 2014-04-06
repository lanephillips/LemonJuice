//
//  CTAddContactViewController.m
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

#import "CTAddContactViewController.h"
#import "NSData+RFC4648.h"

@interface CTAddContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nickTxt;
@property (weak, nonatomic) IBOutlet UILabel *keyTxt;

@end

@implementation CTAddContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nickTxt.text = self.contact.nickname;
//    self.keyTxt.text = self.contact.key.rfc4648Base64EncodedString;
    self.keyTxt.text = [self.contact.key base64EncodedStringWithOptions:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContact:(CTContact *)contact
{
    _contact = contact;
    
    if (self.isViewLoaded) {
        self.nickTxt.text = contact.nickname;
        //    self.keyTxt.text = self.contact.key.rfc4648Base64EncodedString;
        self.keyTxt.text = [self.contact.key base64EncodedStringWithOptions:0];
    }
}

- (IBAction)doCancel:(id)sender
{
    self.cancelHandler();
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doSave:(id)sender
{
    // TODO: validate nickname?
    self.contact.nickname = self.nickTxt.text;
    self.saveHandler();
    [self.navigationController popViewControllerAnimated:YES];
}


@end
