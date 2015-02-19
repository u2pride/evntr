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
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+EVNColors.h"


@interface LogInVC ()

- (IBAction)resetUserPassword:(id)sender;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) FBLoginView *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *textSeparator;



@end

@implementation LogInVC

@synthesize usernameField, passwordField, loginButton, fbLoginButton;

@synthesize transitioningDelegateForModal;

@synthesize forgotPasswordButton, textSeparator;

- (void)viewDidLoad {
    [super viewDidLoad];

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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Polygon" ofType:@"gif"];
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

    //[self registerForKeyboardNotifications];

    
    fbLoginButton = [[FBLoginView alloc] init];
    fbLoginButton.center = self.view.center;
    [self.view addSubview:fbLoginButton];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
    
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3f];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    self.fbLoginButton.alpha = (up ? 0 : 1);
    self.forgotPasswordButton.alpha = (up ? 0 : 1);
    self.textSeparator.alpha = (up ? 0 : 1);
    self.loginButton.alpha = (up ? 0 : 1);
    [UIView commitAnimations];
    

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];

}


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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    //self.scrollViewForKeyboard.contentInset = contentInsets;
    //self.scrollViewForKeyboard.scrollIndicatorInsets = contentInsets;

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    //self.scrollViewForKeyboard.contentInset = contentInsets;
   //self.scrollViewForKeyboard.scrollIndicatorInsets = contentInsets;
}
 */


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

@end
