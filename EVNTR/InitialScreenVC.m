//
//  InitialScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "InitialScreenVC.h"
#import "UIColor+EVNColors.h"

@interface InitialScreenVC ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation InitialScreenVC

@synthesize loginButton, registerButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    //Setting Colors
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];
    self.registerButton.backgroundColor = [UIColor orangeThemeColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//Unwind Segue from Register or Login Pages
- (IBAction) backToLoginSignUpScreen:(UIStoryboardSegue *)unwindSegue {
    //nothing to do.
}



@end
