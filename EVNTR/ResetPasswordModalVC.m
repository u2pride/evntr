//
//  ResetPasswordModalVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import "IDTTransitioningDelegate.h"
#import "ResetPasswordModalVC.h"

#import <Parse/Parse.h>

@interface ResetPasswordModalVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *backgroundForModalPopup;

- (IBAction)resetPasswordButton:(id)sender;
- (IBAction)cancelReset:(id)sender;

@end


@implementation ResetPasswordModalVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundForModalPopup.layer.cornerRadius = 20;
    self.emailTextField.delegate = self;
    
}


#pragma mark - Reset Password

- (IBAction)resetPasswordButton:(id)sender {
    
    if (self.emailTextField.text.length > 0) {
        
        [EVNUser requestPasswordResetForEmailInBackground:self.emailTextField.text block:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                id<ResetPasswordDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(resetPasswordSuccess)]) {
                    
                    [strongDelegate resetPasswordSuccess];
                }
                
            } else {
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hmm..." message:@"Are you sure that's the right email?  We don't recognize it." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                
                [errorAlert show];
                
                id<ResetPasswordDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(resetPasswordFailed)]) {
                    
                    [strongDelegate resetPasswordFailed];
                    
                }
                
            }
            
        }];

    } else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Email Address" message:@"Please enter an email." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
        
        [errorAlert show];
    }
    
}


#pragma mark - Cancel Password Reset

- (IBAction)cancelReset:(id)sender {
    
    id<ResetPasswordDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(resetPasswordCanceled)]) {
        
        [strongDelegate resetPasswordCanceled];
    }
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}


@end
