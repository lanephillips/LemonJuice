//
//  CTAddContactViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
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
