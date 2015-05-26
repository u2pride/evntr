//
//  GuestWelcomeVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "GuestWelcomeVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

@interface GuestWelcomeVC ()

@property (strong, nonatomic) IBOutlet EVNButton *continueButton;
 
@end

@implementation GuestWelcomeVC

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.continueButton.titleText = @"Got It!";
    self.continueButton.isSelected = YES;

    [self.continueButton addTarget:self action:@selector(startUsingApp) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - User Actions

- (void) startUsingApp {
    
    [self performSegueWithIdentifier:@"useAppAsGuest" sender:nil];

}


- (void) dealloc {
    NSLog(@"guestwelcomevc is being deallocated");
}

@end
