//
//  CTAddContactViewController.h
//  Cryptext
//
//  Created by Lane Phillips on 4/1/14.
//  Copyright (c) 2014 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTContact.h"

@interface CTAddContactViewController : UIViewController

@property (nonatomic) CTContact* contact;

@property (nonatomic,copy) void (^cancelHandler)();
@property (nonatomic,copy) void (^saveHandler)();

@end
