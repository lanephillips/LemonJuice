//
//  CTDetailViewController.h
//  Cryptext
//
//  Created by Lane Phillips on 3/29/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
