//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNButton.h"
#import "FacebookSDK/FacebookSDK.h"
#import "HomeScreenVC.h"
#import "IDTransitioningDelegate.h"
#import "FBShimmeringView.h"
#import "LogInVC.h"
#import "MBProgressHUD.h"
#import "ParseFacebookUtils/PFFacebookUtils.h"
#import "ResetPasswordModalVC.h"
#import "SignUpVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>


@interface LogInVC ()

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> transitioningDelegateForModal;

@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (strong, nonatomic) IBOutlet EVNButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *textSeparator;

@property (nonatomic, strong) UIVisualEffectView *blurViewForModal;
@property (nonatomic, strong) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;
@property (nonatomic) BOOL isNewUserFromFacebook;
@property (nonatomic) BOOL viewIsPulledUpForTextInput;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (IBAction)resetUserPassword:(id)sender;
- (IBAction)login:(id)sender;

@end



@implementation LogInVC


- (void)viewDidLoad {
    [super viewDidLoad];

    //Initializing Variables and Objects
    self.isNewUserFromFacebook = NO;
    self.viewIsPulledUpForTextInput = NO;
    self.transitioningDelegateForModal = [[IDTransitioningDelegate alloc] init];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    //Stying Elements
    self.usernameField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    
    self.loginButton.titleText = @"Login";
    self.loginButton.font = [UIFont fontWithName:@"Lato-Light" size:21];
    self.loginButton.isRounded = NO;
    self.loginButton.isSelected = YES;
    self.loginButton.isStateless = YES;
    
    

}

- (void) viewWillAppear:(BOOL)animated {
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    
}



#pragma mark - Login Requests

//Normal User Login with Username and Password
- (void)login:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Logging you in..."];
    
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            
            //Set isGuest Object
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setBool:NO forKey:kIsGuest];
            [standardDefaults synchronize];
            
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
                [self cleanUpBeforeTransition];
            });
            
        } else {
            //Failed to Login
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Username or Password Does Not Exist" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [self cleanUpBeforeTransition];
        }

        
    }];
    
    
}


//Logging In with Parse and Facebook Integration
- (IBAction)loginWithFacebook:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Logging you in..."];
    
    // TODO:  Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            
            [self cleanUpBeforeTransition];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                
                double delayInSeconds = 3.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self grabUserDetailsFromFacebook];
                    [self cleanUpBeforeTransition];

                });
                
            } else {
                NSLog(@"User with facebook logged in!");
                
                //Set isGuest Object
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                double delayInSeconds = 3.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
                    [self cleanUpBeforeTransition];

                });
                    

            }
            
        }
        

        
    }];
    
    
}



- (void) grabUserDetailsFromFacebook {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            [activityIndicator stopAnimating];
            
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSMutableDictionary *userDetailsForFBRegistration = [[NSMutableDictionary alloc] init];
            
            NSLog(@"FB User Data: %@", result);
            
            NSString *facebookID = userData[@"id"];
            //NSString *name = userData[@"name"];
            //NSString *location = userData[@"location"][@"name"];
            //NSString *firstName = userData[@"first_name"];
            //NSString *email = userData[@"email"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            if (userData[@"id"]) {
                [userDetailsForFBRegistration setObject:userData[@"id"] forKey:@"ID"];
            }
            
            if (userData[@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"name"] forKey:@"realName"];
            }
            
            if (userData[@"location"][@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"location"] forKey:@"location"];
            }
            
            if (userData[@"first_name"]) {
                [userDetailsForFBRegistration setObject:userData[@"first_name"] forKey:@"firstName"];
            }
            
            if (userData[@"email"]) {
                [userDetailsForFBRegistration setObject:userData[@"email"] forKey:@"email"];
            }
            
            if (userData[@"id"]) {
                [userDetailsForFBRegistration setObject:pictureURL forKey:@"profilePictureURL"];
            }
            
            
            id<NewUserFacebookDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetails:)]) {
                
                [strongDelegate createFBRegisterVCWithDetails:[NSDictionary dictionaryWithDictionary:userDetailsForFBRegistration]];
            }
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to retrieve user details" delegate:self cancelButtonTitle:@"Cmon" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
    
    }];
    
}


- (void) blurViewDuringLoginWithMessage:(NSString *)message {
    
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurOutLogInScreen = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.blurOutLogInScreen.alpha = 0;
    self.blurOutLogInScreen.frame = self.view.bounds;
    [self.view addSubview:self.blurOutLogInScreen];
    
    self.blurMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.blurMessage.alpha = 0;
    self.blurMessage.text = message;
    self.blurMessage.font = [UIFont fontWithName:@"Lato-Regular" size:24];
    self.blurMessage.textAlignment = NSTextAlignmentCenter;
    self.blurMessage.textColor = [UIColor whiteColor];
    self.blurMessage.center = self.view.center;
    //[self.view addSubview:self.blurMessage];
    
    self.shimmerView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.shimmerView];

    self.shimmerView.contentView = self.blurMessage;
    self.shimmerView.shimmering = YES;
    
    [UIView animateWithDuration:0.8 animations:^{
        self.blurOutLogInScreen.alpha = 1;
        self.blurMessage.alpha = 1;
    } completion:^(BOOL finished) {
        

    }];
    
}


#pragma mark - Reset User Password Modal

//Present Modal View for Resetting Password
- (IBAction)resetUserPassword:(id)sender {
    
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    resetPasswordModal.delegate = self;
    
    [self blurViewDuringLoginWithMessage:@""];
     
    //Add Blur Effect
    /*
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurViewForModal = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurViewForModal.frame = self.view.bounds;
    self.blurViewForModal.alpha = 0;
    [self.view addSubview:self.blurViewForModal];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 1;
    }];
    
     Swift Example
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
    
    if ([textField isEqual:self.usernameField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

//Adjust View When The User Starts Inputting Credentials
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 
    if (!self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsWithKeyboard:YES];
    }

    return YES;
}
 
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 
    if ([textField isEqual:self.passwordField] && self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsWithKeyboard:NO];
    }
    
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
        self.viewIsPulledUpForTextInput = (up ? YES : NO);

    }];

}
 

//Allow user to dismiss keyboard by tapping the View
//TODO: Implement for all Use Cases of Tapping and Entering Return on Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.viewIsPulledUpForTextInput) {
        self.viewIsPulledUpForTextInput = NO;
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self moveLoginFieldsWithKeyboard:NO];
    }


}




#pragma mark - Delegate Methods from Reset Password Modal

- (void) resetPasswordSuccess {
    
    NSLog(@"Success");
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) resetPasswordFailed {
    
    NSLog(@"Failed Reset");

    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) resetPasswordCanceled {
    
    NSLog(@"Canceled Reset");

    [self cleanUpBeforeTransition];

    /*
    [UIView animateWithDuration:1.0f animations:^{
        self.blurViewForModal.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurViewForModal removeFromSuperview];
    }];
     */
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - private methods

- (void) cleanUpBeforeTransition {
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.blurMessage.alpha = 0;
        self.blurOutLogInScreen.alpha = 0;
        self.shimmerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.blurMessage removeFromSuperview];
        [self.blurOutLogInScreen removeFromSuperview];
        [self.shimmerView removeFromSuperview];
        
    }];
    
    
}




@end
