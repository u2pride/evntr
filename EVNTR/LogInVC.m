//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "FacebookSDK/FacebookSDK.h"
#import "HomeScreenVC.h"
#import "IDTransitioningDelegate.h"
#import "LogInVC.h"
#import "ParseFacebookUtils/PFFacebookUtils.h"
#import "ResetPasswordModalVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>


@interface LogInVC ()
{
    BOOL isNewUserFromFacebook;
}

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;

@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *textSeparator;
@property (nonatomic, strong) UIVisualEffectView *blurViewForModal;

- (IBAction)resetUserPassword:(id)sender;

@end



@implementation LogInVC

@synthesize usernameField, passwordField, transitioningDelegateForModal;
@synthesize forgotPasswordButton, textSeparator, loginButton, fbLoginButton, blurViewForModal;


- (void)viewDidLoad {
    [super viewDidLoad];

    //Initializing Variables and Objects
    isNewUserFromFacebook = NO;
    self.transitioningDelegateForModal = [[IDTransitioningDelegate alloc] init];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    //Stying Elements
    self.usernameField.text = @"EVNTR";
    self.usernameField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = @"eventkey";
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];


    //background video code
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Polygon" ofType:@"gif"];
    //NSData *gif = [NSData dataWithContentsOfFile:filePath];
    //backgroundVideo.frame = self.view.frame;
    //[backgroundVideo loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    //backgroundVideo.userInteractionEnabled = NO;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - Login Requests

//Normal User Login with Username and Password
- (void)login:(id)sender {
    
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
        } else {
            
            //Failed to Login
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Username or Password Does Not Exist" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert show];
            
            NSLog(@"PFUser Login Error: %@", error);
        }
    }];
    
    
}

//Logging In with Parse and Facebook Integration
- (IBAction)loginWithFacebook:(id)sender {
    
    // TODO:  Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        //TODO: Stop Activity Indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                isNewUserFromFacebook = YES;
                
            } else {
                NSLog(@"User with facebook logged in!");
            }
            
            [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
        }
    }];
    
    // TODO: Start Activity Indicator
    
}


#pragma mark - Reset User Password Modal

//Present Modal View for Resetting Password
- (IBAction)resetUserPassword:(id)sender {
    
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    resetPasswordModal.delegate = self;
    
    //Add Blur Effect
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurViewForModal = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurViewForModal.frame = self.view.bounds;
    self.blurViewForModal.alpha = 0;
    [self.view addSubview:self.blurViewForModal];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 1;
    }];
    
    /* Swift Example
     let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
     visuaEffectView.frame = self.view.bounds
     visuaEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
     visuaEffectView.setTranslatesAutoresizingMaskIntoConstraints(true)
     self.view.addSubview(visuaEffectView)
     */
    
    [self presentViewController:resetPasswordModal animated:YES completion:nil];
    
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];

    return YES;
}

//Adjust View When The User Starts Inputting Credentials
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 
    [self moveLoginFieldsWithKeyboard:YES];
    return YES;
}
 
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 
    [self moveLoginFieldsWithKeyboard:NO];
    return YES;
}
 
 
- (void) moveLoginFieldsWithKeyboard:(BOOL)up {

    //TODO : Adjust According to Keyboard of System
    
    int movement = (up ? -180 : 180);
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        self.fbLoginButton.alpha = (up ? 0 : 1);
        self.forgotPasswordButton.alpha = (up ? 0 : 1);
        self.textSeparator.alpha = (up ? 0 : 1);
        self.loginButton.alpha = (up ? 0 : 1);
        
    } completion:^(BOOL finished) {
        
    }];

}
 

//Allow user to dismiss keyboard by tapping the View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];

}



#pragma mark - Delegate Methods from Reset Password Modal

- (void) resetPasswordSuccess {
    
    NSLog(@"Success");
    
    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurViewForModal removeFromSuperview];        
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) resetPasswordFailed {
    
    NSLog(@"Failed Reset");

    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurViewForModal removeFromSuperview];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) resetPasswordCanceled {
    
    NSLog(@"Canceled Reset");

    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurViewForModal removeFromSuperview];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
    if ([segue.identifier isEqualToString:@"LoginToHomeView"]) {
        TabNavigationVC *tabController = (TabNavigationVC *)[segue destinationViewController];
        tabController.isNewUserWithFacebookLogin = isNewUserFromFacebook;
    }
     
}


@end
