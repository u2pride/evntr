//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "HomeScreenVC.h"
#import "IDTTransitioningDelegate.h"
#import "LogInVC.h"
#import "ResetPasswordModalVC.h"
#import "SignUpVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>


@interface LogInVC ()

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;

@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet EVNButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (weak, nonatomic) IBOutlet UILabel *textSeparator;
@property (weak, nonatomic) IBOutlet UIView *separatorLineLeft;
@property (weak, nonatomic) IBOutlet UIView *separatorLineRight;

- (IBAction)resetUserPassword:(id)sender;
- (IBAction)login:(id)sender;

@end


@implementation LogInVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    //Initialization
    self.transitioningDelegateForModal = [[IDTTransitioningDelegate alloc] init];
    
    //UITextFields
    self.usernameField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    
    //Buttons
    self.fbLoginButton.layer.cornerRadius = 4.0;
    self.loginButton.titleText = @"Log In";
    self.loginButton.font = [UIFont fontWithName:EVNFontRegular size:21];
    self.loginButton.isRounded = NO;
    self.loginButton.isSelected = YES;
    self.loginButton.isStateless = YES;

    //Delegates
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    }
    
    if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    }
    
}



#pragma mark - Login Requests

- (IBAction)login:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Logging you in..."];
    
    [EVNUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        
        if (user) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance setUserId:user.objectId];
            [appDelegate.amplitudeInstance logEvent:@"Logged In"];
            
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setBool:NO forKey:kIsGuest];
            [standardDefaults synchronize];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"SegueToHomeView" sender:self];
                [self cleanUpBeforeTransition];
            });
            
        } else {

            UIAlertView *loginIssue = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you mistyped your username or password." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles: nil];
            
            [loginIssue show];
            
            [self cleanUpBeforeTransition];
            
        }

    }];
    
}


- (IBAction)loginWithFacebook:(id)sender {

    [self blurViewDuringLoginWithMessage:@"Logging in..."];
    
    [self loginThruFacebook];

}


#pragma mark - User Actions

- (IBAction)resetUserPassword:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.amplitudeInstance logEvent:@"Reset Password"];
    
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    resetPasswordModal.delegate = self;
    
    [self blurViewDuringLoginWithMessage:@""];
    
    [self presentViewController:resetPasswordModal animated:YES completion:nil];
    
}


#pragma mark - Delegate Methods from Reset Password Modal

- (void) resetPasswordSuccess {
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) resetPasswordFailed {
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) resetPasswordCanceled {
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestartMoviePlayer" object:nil];
    
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}


#pragma mark - Helper Methods

- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    [super moveLoginFieldsUp:up withKeyboardSize:distance];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.fbLoginButton.alpha = (up ? 0 : 1);
        self.forgotPasswordButton.alpha = (up ? 0 : 1);
        self.textSeparator.alpha = (up ? 0 : 1);
        self.loginButton.alpha = (up ? 0 : 1);
        self.separatorLineLeft.alpha = (up ? 0 : 1);
        self.separatorLineRight.alpha = (up ? 0 : 1);
        
    } completion:^(BOOL finished) {
    
    }];
    
    
}


#pragma mark - Clean Up

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
