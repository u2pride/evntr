//
//  InitialScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "InitialScreenVC.h"
#import "UIColor+EVNColors.h"
#import "IDTransitioningDelegate.h"
#import "LogInVC.h"
#import "UIImageEffects.h"
#import <Parse/Parse.h>


@interface InitialScreenVC ()

@property (nonatomic, strong) NSDictionary *detailsFromFBRegistration;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) UIVisualEffectView *darkBlurEffectView;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

@end

@implementation InitialScreenVC

@synthesize loginButton, registerButton, customTransitionDelegate, logoView, backgroundImageView, darkBlurEffectView, detailsFromFBRegistration;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for testing purposes
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor redColor];


    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    //Setting Colors
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];
    self.registerButton.backgroundColor = [UIColor orangeThemeColor];
    
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

//Unwind Segue from Register or Login Pages - Via Back Button (or Cancel from FB Page - todo)
- (IBAction) backToLoginSignUpScreen:(UIStoryboardSegue *)unwindSegue {
    //nothing to do.
    
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1, 1);
        self.darkBlurEffectView.alpha = 0;
        self.logoView.alpha = 1;
        self.loginButton.alpha = 1;
        self.registerButton.alpha = 1;

        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self.darkBlurEffectView removeFromSuperview];
        }
        
    }];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"InitialToLogin"]) {
        
        UIBlurEffect *lightBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.darkBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:lightBlur];
        self.darkBlurEffectView.alpha = 0;
        self.darkBlurEffectView.frame = self.view.bounds;
        [self.view addSubview:self.darkBlurEffectView];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:lightBlur];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:self.view.bounds];
        
        [[self.darkBlurEffectView contentView] addSubview:vibrancyEffectView];
        
        [UIView animateWithDuration:1.0 animations:^{
            self.darkBlurEffectView.alpha = 0.76;
        } completion:^(BOOL finished) {
            
            NSLog(@"Finished");
            
        }];
    
        [UIView animateWithDuration:0.5 animations:^{
           
            self.backgroundImageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
            
            self.logoView.alpha = 0;
            self.loginButton.alpha = 0;
            self.registerButton.alpha = 0;
            
        }];
        
        //NSTimer *simulation = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(simulateMovement) userInfo:nil repeats:NO];
        //uncomment to run timer - [[NSRunLoop mainRunLoop] addTimer:simulation forMode:NSDefaultRunLoopMode];
        
        LogInVC *viewController = (LogInVC *) [segue destinationViewController];
        viewController.transitioningDelegate = self.customTransitionDelegate;
        viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        viewController.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"NewUserFacebook"]) {
        
        NewUserFacebookVC *destVC = (NewUserFacebookVC *) [segue destinationViewController];
        
        destVC.transitioningDelegate = self.customTransitionDelegate;
        destVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        destVC.informationFromFB = self.detailsFromFBRegistration;
        NSLog(@"in PrepareForSegue: %@", destVC.informationFromFB);
        NSLog(@"in PFS:  %@", self.detailsFromFBRegistration);
                
    
    } else if ([segue.identifier isEqualToString:@"InitialToSignUp"]) {
        
        UIBlurEffect *lightBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.darkBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:lightBlur];
        self.darkBlurEffectView.alpha = 0;
        self.darkBlurEffectView.frame = self.view.bounds;
        [self.view addSubview:self.darkBlurEffectView];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:lightBlur];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:self.view.bounds];
        
        [[self.darkBlurEffectView contentView] addSubview:vibrancyEffectView];
        
        [UIView animateWithDuration:1.0 animations:^{
            self.darkBlurEffectView.alpha = 0.76;
        } completion:^(BOOL finished) {
            
            NSLog(@"Finished");
            
        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.backgroundImageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
            
            self.logoView.alpha = 0;
            self.loginButton.alpha = 0;
            self.registerButton.alpha = 0;
            
        }];
        
        
        SignUpVC *signUpView = (SignUpVC *) [segue destinationViewController];
        signUpView.transitioningDelegate = self.customTransitionDelegate;
        signUpView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        signUpView.delegate = self;
        
    }
    
    
}

- (void) simulateMovement {
    
    
    [UIView animateWithDuration:0.75 animations:^{
        
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    }];
    
}

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"User Details Passed Back to Initial Screen: %@ and User: %@", userDetailsFromFB, [PFUser currentUser]);
       
        //Pass FB Details
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];
        
        //Segue to New User - FB Registration Screen
        [self performSegueWithIdentifier:@"NewUserFacebook" sender:self];
        
 
        
        
    }];
    
    
}


- (void) createFBRegisterVCWithDetailsFromSignUp:(NSDictionary *)userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        NSLog(@"User Details Passed Back to Initial Screen From Sign Up: %@ and User: %@", userDetailsFromFB, [PFUser currentUser]);
        
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];

        [self performSegueWithIdentifier:@"NewUserFacebook" sender:nil];
        
        
    }];
    
    
}




//TOOD: Implement Button States

- (IBAction)loginButtonTouchDownTrial:(id)sender {
    
    self.loginButton.backgroundColor = [UIColor orangeColor];
    
}

- (IBAction)loginButtonTouchUpInsideExample:(id)sender {
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];

}
@end




/*
 //Screenshot Method - IE Not able to see background animations/video.
 CGRect screenRect = [[UIScreen mainScreen] bounds];
 
 UIGraphicsBeginImageContext(screenRect.size);
 [self.view drawViewHierarchyInRect:screenRect afterScreenUpdates:YES];
 UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 
 UIImage *backgroundWithBlur = [UIImageEffects imageByApplyingDarkEffectToImage:snapshotImage];
 self.blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
 self.blurredImageView.image = backgroundWithBlur;
 self.blurredImageView.alpha = 0.8;
 
 
 [self.view addSubview:self.blurredImageView];
 
 [UIView animateWithDuration:5.0f animations:^{
 self.blurredImageView.alpha = 1;
 self.blurredImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
 
 }];
 
 */
