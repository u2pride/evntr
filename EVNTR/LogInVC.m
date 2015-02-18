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

@interface LogInVC ()

- (IBAction)resetUserPassword:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *forgotPasswordEmailField;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;


@end

@implementation LogInVC

@synthesize usernameField, passwordField, forgotPasswordEmailField;

@synthesize transitioningDelegateForModal;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transitioningDelegateForModal = [[IDTransitioningDelegate alloc] init];
    
    //Setup the username and password text fields.
    self.usernameField.text = @"EVNTR";
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = @"eventkey";
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    
    
    //background video
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Polygon" ofType:@"gif"];
    //NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    /*
    backgroundVideo.frame = self.view.frame;
    [backgroundVideo loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    backgroundVideo.userInteractionEnabled = NO;
    
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
