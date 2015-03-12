//
//  InitialScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "GuestWelcomeVC.h"
#import "IDTransitioningDelegate.h"
#import "InitialScreenVC.h"
#import "LogInVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"
#import "UIImageEffects.h"

#import <Parse/Parse.h>


@interface InitialScreenVC ()

@property (nonatomic, strong) NSDictionary *detailsFromFBRegistration;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *skipLoginButton;

@property (strong, nonatomic) UIVisualEffectView *darkBlurEffectView;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

@end



@implementation InitialScreenVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for testing purposes
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor redColor];

    //Setting Colors
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];
    self.registerButton.backgroundColor = [UIColor orangeThemeColor];
    
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Visual Effect View - Blur
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.darkBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.darkBlurEffectView.alpha = 0;
    self.darkBlurEffectView.frame = self.view.bounds;
    [self.view addSubview:self.darkBlurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    [[self.darkBlurEffectView contentView] addSubview:vibrancyEffectView];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"ViewWillAppear - only called once");
    
}


#pragma mark - Navigation

- (IBAction) logOutUnwindSegue:(UIStoryboardSegue *)unwindSegue {
    
    [self returningTransitionAnimations];
    
}

//Unwind Segue from Register or Login Pages - Via Back Button (or Cancel from FB Page - TODO)
- (IBAction) backToLoginSignUpScreen:(UIStoryboardSegue *)unwindSegue {
    
    [self returningTransitionAnimations];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"Prepare for Segue Called");
    
    [self leavingTransitionAnimations];

    if ([segue.identifier isEqualToString:@"InitialToLogin"]) {
        
        LogInVC *loginVC = (LogInVC *) [segue destinationViewController];
        loginVC.transitioningDelegate = self.customTransitionDelegate;
        loginVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        loginVC.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"NewUserFacebook"]) {
        
        NewUserFacebookVC *destVC = (NewUserFacebookVC *) [segue destinationViewController];
        
        destVC.transitioningDelegate = self.customTransitionDelegate;
        destVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        destVC.informationFromFB = self.detailsFromFBRegistration;
        
    
    } else if ([segue.identifier isEqualToString:@"InitialToSignUp"]) {
        
        SignUpVC *signUpView = (SignUpVC *) [segue destinationViewController];
        signUpView.transitioningDelegate = self.customTransitionDelegate;
        signUpView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        signUpView.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"SkipForNowSegue"]) {
        
        //Set isGuest Object
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setBool:YES forKey:kIsGuest];
        [standardDefaults synchronize];
        

        GuestWelcomeVC *guestWelcomeView = (GuestWelcomeVC *) [segue destinationViewController];
        guestWelcomeView.transitioningDelegate = self.customTransitionDelegate;
        guestWelcomeView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
    }
    
    
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [self viewDidDisappear:animated];
    
    NSLog(@"ViewDidDisappear - not called");
    
    //Reset View to Original State
    self.darkBlurEffectView.alpha = 0;
    self.backgroundImageView.transform = CGAffineTransformIdentity;
    self.logoView.alpha = 1;
    self.loginButton.alpha = 1;
    self.registerButton.alpha = 1;
    self.skipLoginButton.alpha = 1;
    
    
}


- (void) leavingTransitionAnimations {
    
    [UIView animateWithDuration:0.65 animations:^{
        self.darkBlurEffectView.alpha = 0.76;
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
        self.logoView.alpha = 0;
        self.loginButton.alpha = 0;
        self.registerButton.alpha = 0;
        self.skipLoginButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
}


- (void) returningTransitionAnimations {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.darkBlurEffectView.alpha = 0;
        self.logoView.alpha = 1;
        self.loginButton.alpha = 1;
        self.registerButton.alpha = 1;
        self.skipLoginButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
}


#pragma mark - Facebook Delegate Methods

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        //Pass FB Details
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];
        
        [self performSegueWithIdentifier:@"NewUserFacebook" sender:self];
        
    }];
    
}


- (void) createFBRegisterVCWithDetailsFromSignUp:(NSDictionary *)userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];

        [self performSegueWithIdentifier:@"NewUserFacebook" sender:nil];
        
    }];
    
}


@end

