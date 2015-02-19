//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "LogInVC.h"
#import <Parse/Parse.h>
#import "ResetPasswordModalVC.h"
#import "IDTransitioningDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+EVNColors.h"
#import "ParseFacebookUtils/PFFacebookUtils.h"
#import "HomeScreenVC.h"
#import "FacebookSDK/FacebookSDK.h"
#import "TabNavigationVC.h"


@interface LogInVC () {
    BOOL isNewUserFromFacebook;
}

- (IBAction)resetUserPassword:(id)sender;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *textSeparator;
- (IBAction)loginWithFacebook:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;


@end

@implementation LogInVC

@synthesize usernameField, passwordField, loginButton;

@synthesize transitioningDelegateForModal;

@synthesize forgotPasswordButton, textSeparator, fbLoginButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    isNewUserFromFacebook = NO;
    self.transitioningDelegateForModal = [[IDTransitioningDelegate alloc] init];
    
    //Setup the username and password text fields.
    self.usernameField.text = @"EVNTR";
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = @"eventkey";
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    
    
    //Set Colors and Borders
    self.usernameField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.passwordField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.passwordField.layer.borderWidth = 1.0f;
    
    self.loginButton.backgroundColor = [UIColor orangeThemeColor];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    //background video
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Polygon" ofType:@"gif"];
    //NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    /*
    backgroundVideo.frame = self.view.frame;
    [backgroundVideo loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    backgroundVideo.userInteractionEnabled = NO;
    
     // MAKE SURE THIS VIEW IS UNDER ANY VIEW THAT NEEDS USER INTERACTION.
    filterView.frame = self.view.frame;
    filterView.backgroundColor = [UIColor blackColor];
    filterView.alpha = 0.05;
    [self.view addSubview:filterView];
     */

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender {
    
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            
            [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
            
        } else {
            //Failed
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Username or Password Does Not Exist" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert show];
        }
    }];
    
    
}

- (IBAction)loginWithFacebook:(id)sender {
    
    // TODO:  Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
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
    
    //[_activityIndicator startAnimating]; // Show loading indicator until login is finished
    
    
}



//Present Modal View for Resetting Password
- (IBAction)resetUserPassword:(id)sender {
    
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    //Will need to add a delegate to tell login that the password has been reset or action has been cancelled.
    resetPasswordModal.delegate = self;
    
    [self presentViewController:resetPasswordModal animated:YES completion:nil];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];

    return YES;
}


 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 
 [self moveLoginFieldsWithKeyboard:YES];
 
 return YES;
 }
 
 - (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 
 [self moveLoginFieldsWithKeyboard:NO];
 
 return YES;
 }
 
 
 - (void) moveLoginFieldsWithKeyboard:(BOOL)up {
 
 int movement = (up ? -180 : 180);
 
     [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
         
         self.view.frame = CGRectOffset(self.view.frame, 0, movement);
         self.fbLoginButton.alpha = (up ? 0 : 1);
         self.forgotPasswordButton.alpha = (up ? 0 : 1);
         self.textSeparator.alpha = (up ? 0 : 1);
         self.loginButton.alpha = (up ? 0 : 1);
 
     } completion:^(BOOL finished) {
 
         NSLog(@"DOne");
     }];
 
}
 


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];

}






#pragma mark - Delegate Methods from Reset Password Modal

- (void) resetPasswordSuccess {
    
    NSLog(@"Success");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) resetPasswordFailed {
    
    NSLog(@"Failed Reset");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) resetPasswordCanceled {
    NSLog(@"Canceled Reset");
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqualToString:@"LoginToHomeView"]) {
         TabNavigationVC *tabController = (TabNavigationVC *)[segue destinationViewController];
         tabController.isNewUserWithFacebookLogin = isNewUserFromFacebook;
     }
     
     
     
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }




@end





//ATTEMPTED TO USE - BUT THE NOTIFICATION IS TOO SLOW
/*
 // Call this method somewhere in your view controller setup code.
 - (void)registerForKeyboardNotifications
 {
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWasShown:)
 name:UIKeyboardDidShowNotification object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillBeHidden:)
 name:UIKeyboardWillHideNotification object:nil];
 }
 
 // Called when the UIKeyboardDidShowNotification is sent.
 - (void)keyboardWasShown:(NSNotification*)aNotification
 {
 NSDictionary* info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
 [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
 
 self.view.frame = CGRectOffset(self.view.frame, 0, -kbSize.height);
 self.fbLoginButton.alpha = 0;
 self.forgotPasswordButton.alpha = 0;
 self.textSeparator.alpha = 0;
 self.loginButton.alpha = 0 ;
 
 } completion:^(BOOL finished) {
 
 NSLog(@"DOne");
 }];
 
 }
 
 // Called when the UIKeyboardWillHideNotification is sent
 - (void)keyboardWillBeHidden:(NSNotification*)aNotification
 {
 NSDictionary* info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
 [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
 
 self.view.frame = CGRectOffset(self.view.frame, 0, kbSize.height);
 self.fbLoginButton.alpha = 1;
 self.forgotPasswordButton.alpha = 1;
 self.textSeparator.alpha = 1;
 self.loginButton.alpha = 1;
 
 } completion:^(BOOL finished) {
 
 NSLog(@"DOne");
 }];
 
 }
 */
