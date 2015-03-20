//
//  InitialScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "MapForEventView.h"
#import <QuartzCore/QuartzCore.h>

#import "EVNButton.h"
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
@property (strong, nonatomic) IBOutlet EVNButton *loginButton;
@property (strong, nonatomic) IBOutlet EVNButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *skipLoginButton;

@property (strong, nonatomic) UIVisualEffectView *darkBlurEffectView;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

@end



@implementation InitialScreenVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO: for testing purposes
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor redColor];

    //Setting Up Custom Buttons
    self.loginButton.buttonColor = [UIColor orangeThemeColor];
    self.loginButton.titleText = @"Login";
    self.loginButton.isRounded = NO;
    self.loginButton.tag = 1;
    self.loginButton.isSelected = YES;
    self.loginButton.font = [UIFont fontWithName:@"Lato-Regular" size:20.0];
    self.loginButton.isStateless = YES;
    
    self.registerButton.buttonColor = [UIColor orangeThemeColor];
    self.registerButton.titleText = @"Register";
    self.registerButton.isRounded = NO;
    self.registerButton.tag = 2;
    self.registerButton.isSelected = YES;
    self.registerButton.font = [UIFont fontWithName:@"Lato-Regular" size:20.0];
    self.registerButton.isStateless = YES;
    
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
    
    
    //Adding Tap Gestures To Custom Buttons
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueIntoTheApp:)];
    UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueIntoTheApp:)];
    
    //Note:  Appear to be unneccessary.
    tapgr.cancelsTouchesInView = NO;
    tapgr2.cancelsTouchesInView = NO;
    
    [self.registerButton addGestureRecognizer:tapgr];
    [self.loginButton addGestureRecognizer:tapgr2];

    
}


- (void)continueIntoTheApp:(UIGestureRecognizer *)gr {
    
    NSLog(@"Gesture Recognized");
    
    NSInteger tag = gr.view.tag;
    
    EVNButton *button = (EVNButton *)gr.view;
    [button startedTask];
    
    //Login Button
    if (tag == 1) {
        
        [self performSegueWithIdentifier:@"InitialToLogin" sender:self];
        [self.loginButton endedTask];
        
    //Register Button
    } else {
        
        [self performSegueWithIdentifier:@"InitialToSignUp" sender:self];
        self.registerButton.isSelected = YES;
        [self.registerButton endedTask];
    }
    
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

