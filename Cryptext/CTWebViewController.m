//
//  CTWebViewController.m
//  Cryptext
//
//  Created by Lane Phillips on 4/4/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import "CTWebViewController.h"

@interface CTWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CTWebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.webView loadHTMLString:self.html baseURL:nil];
}

@end
