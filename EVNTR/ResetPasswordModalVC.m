//
//  ResetPasswordModalVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ResetPasswordModalVC.h"
#import <Parse/Parse.h>
#import "IDTransitioningDelegate.h"

@interface ResetPasswordModalVC ()

//@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegate;

@property (weak, nonatomic) IBOutlet UIView *backgroundForModalPopup;
- (IBAction)resetPasswordButton:(id)sender;
- (IBAction)cancelReset:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation ResetPasswordModalVC

@synthesize backgroundForModalPopup, emailTextField;
//@synthesize transitioningDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.transitioningDelegate = [[IDTransitioningDelegate alloc] init];
    self.backgroundForModalPopup.layer.cornerRadius = 30;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)resetPasswordButton:(id)sender {
    
    
    [PFUser requestPasswordResetForEmailInBackground:self.emailTextField.text block:^(BOOL succeeded, NSError *error) {
        
        if (succeeded && !error) {
            //UIAlertView *successPopup = [[UIAlertView alloc] initWithTitle:@"Reset Success" message:@"Click on the link in your email to reset your password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            //[successPopup show];
            
            id<ResetPasswordDelegate> strongDelegate = self.delegate;

            if ([strongDelegate respondsToSelector:@selector(resetPasswordSuccess)]) {
                
                [strongDelegate resetPasswordSuccess];
            }
            
        } else {
            //UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Reset Error" message:@"Not able to reset your password.  Try restarting the app." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            //[errorAlert show];
            
            id<ResetPasswordDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(resetPasswordFailed)]) {
                
                [strongDelegate resetPasswordFailed];
                
            }
            
        }
        
    }];
    
    
}

- (IBAction)cancelReset:(id)sender {
    
    id<ResetPasswordDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(resetPasswordCanceled)]) {
        
        [strongDelegate resetPasswordCanceled];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}


@end
