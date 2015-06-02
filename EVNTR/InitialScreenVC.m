//
//  InitialScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "GuestWelcomeVC.h"
#import "IDTTransitioningDelegate.h"
#import "InitialScreenVC.h"
#import "LogInVC.h"
#import "MapForEventView.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>
@import MediaPlayer;
@import QuartzCore;


@interface InitialScreenVC ()

@property (nonatomic, strong) NSDictionary *detailsFromFBRegistration;
@property (strong, nonatomic) IBOutlet EVNButton *loginButton;
@property (strong, nonatomic) IBOutlet EVNButton *registerButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *skipLoginButton;

@property (nonatomic) BOOL isRunningValidCodeVersion;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIVisualEffectView *darkBlurEffectView;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

- (IBAction)skipForNow:(id)sender;

@end


@implementation InitialScreenVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    //Initialization
    self.isRunningValidCodeVersion = NO;
    self.loginButton.buttonColor = [UIColor orangeThemeColor];
    self.loginButton.titleText = @"Log In";
    self.loginButton.isRounded = NO;
    self.loginButton.tag = 1;
    self.loginButton.isSelected = YES;
    self.loginButton.font = [UIFont fontWithName:EVNFontRegular size:20.0];
    self.loginButton.isStateless = YES;
    
    self.registerButton.buttonColor = [UIColor orangeThemeColor];
    self.registerButton.titleText = @"Register";
    self.registerButton.isRounded = NO;
    self.registerButton.tag = 2;
    self.registerButton.isSelected = YES;
    self.registerButton.font = [UIFont fontWithName:EVNFontRegular size:20.0];
    self.registerButton.isStateless = YES;
    
    self.customTransitionDelegate = [[IDTTransitioningDelegate alloc] init];
    
    //Setup Blur
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.darkBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.darkBlurEffectView.alpha = 0;
    self.darkBlurEffectView.frame = self.view.bounds;
    [self.view addSubview:self.darkBlurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    [[self.darkBlurEffectView contentView] addSubview:vibrancyEffectView];
    
    //Actions
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueIntoTheApp:)];
    UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueIntoTheApp:)];
    
    //TODO:  Appear to be unneccessary.
    tapgr.cancelsTouchesInView = NO;
    tapgr2.cancelsTouchesInView = NO;
    
    [self.registerButton addGestureRecognizer:tapgr];
    [self.loginButton addGestureRecognizer:tapgr2];
    
    
    NSLog(@"-- REGISTER for Movie Player Finished, Command to Stop Player, Command to Restart Movie Play, and UIApplicationWill Come Back into Foreground Notifications");
    [self registerForNotifications];

}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self checkAppVersion];
}



- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    NSLog(@"ViewDidDisappear - not called because we use a custom transistion");
    
}


#pragma mark - User Actions

- (IBAction)skipForNow:(id)sender {
    
    if (self.isRunningValidCodeVersion) {
        
        [self leavingTransitionAnimations];
        
        [PFAnalytics trackEventInBackground:@"SkipForNow" block:nil];
        
        //Set isGuest Object
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setBool:YES forKey:kIsGuest];
        [standardDefaults synchronize];
        
        GuestWelcomeVC *guestWelcomeVC = (GuestWelcomeVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"GuestWelcomeViewController"];
        guestWelcomeVC.transitioningDelegate = self.customTransitionDelegate;
        guestWelcomeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:guestWelcomeVC animated:YES completion:nil];
        
    }
    
}

- (void)continueIntoTheApp:(UIGestureRecognizer *)gr {
    
    if (self.isRunningValidCodeVersion) {
        
        NSInteger tag = gr.view.tag;
        
        EVNButton *button = (EVNButton *)gr.view;
        [button startedTask];
        
        [self leavingTransitionAnimations];
        
        //Login Button
        if (tag == 1) {
            
            LogInVC *loginVC = (LogInVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            loginVC.transitioningDelegate = self.customTransitionDelegate;
            loginVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            loginVC.delegate = self;
            
            [self presentViewController:loginVC animated:YES completion:^{
                [self.loginButton endedTask];
            }];
            
        } else {
            
            SignUpVC *signUpVC = (SignUpVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
            signUpVC.transitioningDelegate = self.customTransitionDelegate;
            signUpVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            signUpVC.delegate = self;
            
            [self presentViewController:signUpVC animated:YES completion:^{
                self.registerButton.isSelected = YES;
                [self.registerButton endedTask];
            }];
            
        }

    }
    
}

#pragma mark - Custom Getters

- (MPMoviePlayerController *) moviePlayer {
    NSLog(@"Accessed movie player controller variable");
    
    if (!_moviePlayer) {
        NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"evntrBackground" withExtension:@"mov"];
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.view.frame = self.view.frame;
        [self.view insertSubview:_moviePlayer.view atIndex:0];
        
        NSLog(@"Created Movie Player");
    }
    
    return _moviePlayer;
}



#pragma mark - Navigation

- (IBAction) logOutUnwindSegue:(UIStoryboardSegue *)unwindSegue {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    NSLog(@"Back from logout unwind segue");
    NSLog(@"-- REGISTER for App Enters Foreground and Movie Finished Notifications - Should not be registered for them right now");
    
    [self checkAppVersion];
    
    [self registerForNotifications];
    
    [self.moviePlayer play];
    
    [self returningTransitionAnimations];
    
}

//Unwind Segue from Register or Login Pages - Via Back Button (or Cancel from FB Page - TODO)
- (IBAction) backToLoginSignUpScreen:(UIStoryboardSegue *)unwindSegue {
    
    NSLog(@"Unwind from Login Screens");
    [self returningTransitionAnimations];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self leavingTransitionAnimations];
    
}


- (void) leavingTransitionAnimations {
    
    [UIView animateWithDuration:0.65 animations:^{
        self.darkBlurEffectView.alpha = 0.76;
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
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
        self.loginButton.alpha = 1;
        self.registerButton.alpha = 1;
        self.skipLoginButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2) {
        [self checkAppVersion];
    }
    
}

#pragma mark - Facebook Delegate Methods

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        //Pass FB Details
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];
        
        [self leavingTransitionAnimations];
        
        NewUserFacebookVC *destVC = (NewUserFacebookVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserFacebookViewController"];
        destVC.transitioningDelegate = self.customTransitionDelegate;
        destVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        destVC.informationFromFB = self.detailsFromFBRegistration;
        
        [self presentViewController:destVC animated:YES completion:nil];
        //[self performSegueWithIdentifier:@"NewUserFacebook" sender:self];
        
    }];
    
}


- (void) createFBRegisterVCWithDetailsFromSignUp:(NSDictionary *)userDetailsFromFB {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.detailsFromFBRegistration = [NSDictionary dictionaryWithDictionary:userDetailsFromFB];
        
        [self leavingTransitionAnimations];

        NewUserFacebookVC *destVC = (NewUserFacebookVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"NewUserFacebookViewController"];
        destVC.transitioningDelegate = self.customTransitionDelegate;
        destVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        destVC.informationFromFB = self.detailsFromFBRegistration;
        
        [self presentViewController:destVC animated:YES completion:nil];
        //[self performSegueWithIdentifier:@"NewUserFacebook" sender:nil];
        
    }];
    
}


#pragma mark - Movie Player

- (void)loopVideo {
    NSLog(@"Loop video notification");
    [self.moviePlayer play];
}

- (void)backFromForeground {
    NSLog(@"Play MoviePlayer - Back from foreground notification or restart notificaiton");
    
    [self checkAppVersion];
    
    [self.moviePlayer play];

    //Reregister for Everthing except the foreground notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loopVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMoviePlayer) name:@"StopMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromForeground) name:@"RestartMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void) appEnteredBackground {
    NSLog(@"app entered background");
    [self stopMoviePlayer];

    //Reregister for foreground notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromForeground) name:UIApplicationWillEnterForegroundNotification object:nil];


}

- (void)stopMoviePlayer {
    NSLog(@"Stop movie player and ----- DEREGISTER ------ observers");
    [self.moviePlayer stop];
    
    [self deregisterForNotifications];

}

#pragma mark - Helper Methods

- (void) registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loopVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMoviePlayer) name:@"StopMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromForeground) name:@"RestartMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

}


- (void) deregisterForNotifications {
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StopMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RestartMoviePlayer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

}


- (void) checkAppVersion {
    
    NSLog(@"Check App Version Code Run");
    
    self.isRunningValidCodeVersion = NO;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *numbersSeparated = [versionString componentsSeparatedByString:@"."];
    
    NSString *majorVersion = [[NSString alloc] init];
    NSString *minorVersion = [[NSString alloc] init];
    
    if ([numbersSeparated count] >= 1) {
        majorVersion = [numbersSeparated objectAtIndex:0];
    }
    
    if ([numbersSeparated count] >= 2) {
        minorVersion = [numbersSeparated objectAtIndex:1];
    }
    
    [PFCloud callFunctionInBackground:@"checkVersion" withParameters:@{@"majorVersion": majorVersion, @"minorVersion": minorVersion} block:^(NSString *result, NSError *error) {
        
        if ([result isEqualToString:@"true"]) {
            self.isRunningValidCodeVersion = YES;
            
            if ([EVNUser currentUser]) {
                
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                //[self stopMoviePlayer];
                [self performSegueWithIdentifier:@"currentUserExists" sender:nil];
                
            } else {
                NSLog(@"View Will Appear - Start Movie");
                
                [self.moviePlayer play];
            }
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Update Required" message:@"Looks like you are running an old version of the app, head over to the app store to grab the latest update." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [self.moviePlayer play];
            
        }
        
        
        if (error) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"We're having trouble connecting to the internet." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            errorAlert.tag = 2;
            
            [errorAlert addButtonWithTitle:@"Retry"];
            
            [errorAlert show];
            
            [self.moviePlayer play];
            
        }
        
    }];
}


#pragma mark - Clean Up

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end

