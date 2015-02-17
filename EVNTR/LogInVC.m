//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "LogInVC.h"
#import <Parse/Parse.h>

@interface LogInVC ()
- (IBAction)resetUserPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailForReset;
@property (weak, nonatomic) IBOutlet UIWebView *backgroundVideo;
@property (weak, nonatomic) IBOutlet UIView *filterView;

@end

@implementation LogInVC

@synthesize usernameField, passwordField, emailForReset, backgroundVideo, filterView;

- (void)viewDidLoad {
    [super viewDidLoad];

    //Setup the username and password text fields.
    self.usernameField.text = @"EVNTR";
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = @"eventkey";
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    
    
    //background video
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"railway" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    backgroundVideo.frame = self.view.frame;
    [backgroundVideo loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    backgroundVideo.userInteractionEnabled = NO;
    
    filterView.frame = self.view.frame;
    filterView.backgroundColor = [UIColor blackColor];
    filterView.alpha = 0.05;
    [self.view addSubview:filterView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(id)sender {
    
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            
            //Testing - Use to Change User Details
            //user[@"twitterHandle"] = @"@U2Pride14";
            //user[@"instagamHandle"] = @"@u2pride";
            //NSArray *followers = @[@"12", @"14", @"18"];
            //NSArray *following = @[@"11", @"14", @"19"];
            //user[@"followers"] = followers;
            //user[@"following"] = following;
            
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

//Reset User Password - Parse
- (IBAction)resetUserPassword:(id)sender {
    
    [PFUser requestPasswordResetForEmailInBackground:self.emailForReset.text block:^(BOOL succeeded, NSError *error) {
       
        if (succeeded && !error) {
                UIAlertView *successPopup = [[UIAlertView alloc] initWithTitle:@"Reset Success" message:@"Click on the link in your email to reset your password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            [successPopup show];
        } else {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Reset Error" message:@"Not able to reset your password.  Try restarting the app." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [errorAlert show];
        }
        
    }];
    
}
@end
