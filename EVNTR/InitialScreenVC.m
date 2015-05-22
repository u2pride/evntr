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
#import "IDTransitioningDelegate.h"
#import "InitialScreenVC.h"
#import "LogInVC.h"
#import "MapForEventView.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"
#import "UIImageEffects.h"

@import MediaPlayer;
@import QuartzCore;
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

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;


- (IBAction)showBetaInformation:(id)sender;
- (IBAction)showBuildInformation:(id)sender;

@end



@implementation InitialScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO: for testing purposes
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor whiteColor];

    //Setting Up Custom Buttons
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
    
    
    NSLog(@"-- REGISTER for Movie Player Finished, Command to Stop Player, Command to Restart Movie Play, and UIApplicationWill Come Back into Foreground Notifications");
    [self registerForNotifications];

}


- (IBAction)showBetaInformation:(id)sender {
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Welcome to the Beta" message:@"Just a couple of quick things... First, each new major update includes a database wipe - which explains why you sometimes log in and all your data is gone.  If you are having issues logging in, delete the app and reinstall from TestFlight.  Finally, if you have feedback - send us an email or tweet at us from Settings.  We would love to hear from you!" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
    
    [errorAlert show];
}

- (IBAction)showBuildInformation:(id)sender {
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Version 0.7 - Build 1" message:@"Thanks for downloading the latest version. We've updated this first screen (like the new video?) and now you can submit comments that are multiple lines.  The notifications table is also updated to dynamically size based on its content. As usual, if you run into issues, shoot us an email or send a tweet from the settings page (top right corner of the profile page).  We love to hear new feature ideas, usability changes, and visual updates. It's your chance to shape this app before it's released!" delegate:self cancelButtonTitle:@"Cool Deal" otherButtonTitles: nil];
    
    [errorAlert show];
}

- (MPMoviePlayerController *)moviePlayer
{
    NSLog(@"Accessed movie player controller variable");
    
    if (!_moviePlayer) {
        NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"evntrVideo" withExtension:@"mov"];
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.view.frame = self.view.frame;
        [self.view insertSubview:_moviePlayer.view atIndex:0];
        
        NSLog(@"Created Movie Player");
        
    }
    return _moviePlayer;
}




- (void)continueIntoTheApp:(UIGestureRecognizer *)gr {
    
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

    NSLog(@"View Will Appear - Start Movie");
    [self.moviePlayer play];

}





#pragma mark - Navigation

- (IBAction) logOutUnwindSegue:(UIStoryboardSegue *)unwindSegue {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    NSLog(@"Back from logout unwind segue");
    NSLog(@"-- REGISTER for App Enters Foreground and Movie Finished Notifications - Should not be registered for them right now");
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
        
    } else if ([segue.identifier isEqualToString:@"currentUserExists"]) {
        
    }
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

    NSLog(@"Version: %@ and Build: %@", version, build);
    
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *versionBuildNumber = [standardDefaults objectForKey:kFirstLoginNewBuild];
    
    if ([versionBuildNumber isEqualToString:@"V0.70Build1"]) {
        
        if ([EVNUser currentUser]) {
            
            [self stopMoviePlayer];
            [self performSegueWithIdentifier:@"currentUserExists" sender:nil];
            
        }
        
    } else {
    
        [standardDefaults setObject:@"V0.70Build1" forKey:kFirstLoginNewBuild];
        [standardDefaults synchronize];
        
    }

}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    NSLog(@"ViewDidDisappear - not called because we use a custom transistion");
    
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


#pragma mark - Movie Player

- (void)loopVideo {
    NSLog(@"Loop video notification");
    [self.moviePlayer play];
}

- (void)backFromForeground {
    NSLog(@"Play MoviePlayer - Back from foreground notification or restart notificaiton");
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

-(void)dealloc {
    
    NSLog(@"initialscreenvc is being deallocated");
    //NSLog(@"Removing Notifications for Stop, Restart, Loop, and Foreground Notification");
    //super dealloc is called automatically with ARC


}



@end

