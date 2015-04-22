//
//  GuestWelcomeVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "GuestWelcomeVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

@interface GuestWelcomeVC ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation GuestWelcomeVC


- (void)viewDidLoad {
    [super viewDidLoad];

    self.continueButton.backgroundColor = [UIColor orangeThemeColor];
}

-(void)dealloc {
    NSLog(@"guestwelcomevc is being deallocated");
}

@end
