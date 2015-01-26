//
//  SignUpVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SignUpVC.h"
#import <Parse/Parse.h>

@interface SignUpVC ()

@end

@implementation SignUpVC

@synthesize usernameField, passwordField, emailField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signUp:(id)sender {
    
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    
    NSArray *followers = @[@"12", @"14", @"18"];
    NSArray *following = @[@"11", @"14", @"19"];

    newUser[@"Followers"] = followers;
    newUser[@"Following"] = following;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Success!" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [successAlert show];
            
            [self performSegueWithIdentifier:@"SignupToHomeView" sender:self];

            
        } else {
            
            NSString *errorString = [error userInfo][@"error"];
            
            UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:errorString delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [failureAlert show];
            
            
            
            
        }
        
    }];
    
    

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [textField resignFirstResponder];
    }
    
    return YES;
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller. - for ex passing a user to a new userprofileVC
}
*/

@end
