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
#import "SignUpVC.h"
#import "EVNConstants.h"

@interface LogInVC ()
{
    BOOL isNewUserFromFacebook;
    BOOL viewIsPulledUpForTextInput;
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


- (void)viewDidLoad {
    [super viewDidLoad];

    //Initializing Variables and Objects
    isNewUserFromFacebook = NO;
    viewIsPulledUpForTextInput = NO;
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
            
            //Animation For Logging In
            UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurOutLogInScreen = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
            blurOutLogInScreen.alpha = 0;
            blurOutLogInScreen.frame = self.view.bounds;
            [self.view addSubview:blurOutLogInScreen];
            //[self.view bringSubviewToFront:blurOutLogInScreen];
            
            UILabel *loginInTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
            loginInTextLabel.alpha = 0;
            loginInTextLabel.text = @"Logging you in...";
            loginInTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:24];
            loginInTextLabel.textAlignment = NSTextAlignmentCenter;
            loginInTextLabel.textColor = [UIColor whiteColor];
            loginInTextLabel.center = self.view.center;
            [self.view addSubview:loginInTextLabel];
            
            //Set isGuest Object
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setBool:NO forKey:kIsGuest];
            [standardDefaults synchronize];
            
            [UIView animateWithDuration:2.0 animations:^{
                blurOutLogInScreen.alpha = 1;
                loginInTextLabel.alpha = 1;
            } completion:^(BOOL finished) {
                
                NSLog(@"Finished");
                [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];

            }];
            
            
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
                
                [self grabUserDetailsFromFacebook];
                
                /*
                isNewUserFromFacebook = YES;
                
                //Create a Sign Up page and populate it with Facebook Details.  Have the user verify.  Also helps funnel users through onboading. Maybe have guests go through onboarding as well? yeah.
                SignUpVC *signUpVC = (SignUpVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
                [self presentViewController:signUpVC animated:YES completion:nil];
                
                id<NewUserFacebookDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetails:)]) {
                    
                    [strongDelegate createFBRegisterVCWithDetails:nil];
                }
                 */
                
                
            } else {
                NSLog(@"User with facebook logged in!");
                
                UILabel *loginInTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
                loginInTextLabel.alpha = 0;
                loginInTextLabel.text = @"WELCOME to EVNTR";
                loginInTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:26];
                loginInTextLabel.textAlignment = NSTextAlignmentCenter;
                loginInTextLabel.textColor = [UIColor whiteColor];
                loginInTextLabel.center = self.view.center;
                [self.view addSubview:loginInTextLabel];
                
                //Set isGuest Object
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                [UIView animateWithDuration:0.64 animations:^{
                    loginInTextLabel.alpha = 1;
                } completion:^(BOOL finished) {
                    
                    NSLog(@"Finished");
                    [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
                    
                }];
            }
            

            
        }
    }];
    
    // TODO: Start Activity Indicator
    
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurOutLogInScreen = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    blurOutLogInScreen.alpha = 0;
    blurOutLogInScreen.frame = self.view.bounds;
    [self.view addSubview:blurOutLogInScreen];
    //[self.view bringSubviewToFront:blurOutLogInScreen];
    
    [UIView animateWithDuration:0.3 animations:^{
        blurOutLogInScreen.alpha = 1;
    } completion:^(BOOL finished) {
        
        NSLog(@"Finished");
        
    }];
    
    
}



- (void) grabUserDetailsFromFacebook {
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSLog(@"FB User Data: %@", result);
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *firstName = userData[@"first_name"];
            NSString *email = userData[@"email"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSDictionary *userDetailsForFBRegistration = [NSDictionary dictionaryWithObjectsAndKeys:facebookID, @"ID", name, @"realName", location, @"location", firstName, @"firstName", email, @"email", pictureURL, @"profilePictureURL", nil];
            
            
            id<NewUserFacebookDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetails:)]) {
                
                [strongDelegate createFBRegisterVCWithDetails:userDetailsForFBRegistration];
            }
            
        }
    }];
    
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
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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
    
    if ([textField isEqual:self.usernameField])
    {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return YES;
}

//Adjust View When The User Starts Inputting Credentials
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 
    if (!viewIsPulledUpForTextInput) {
        [self moveLoginFieldsWithKeyboard:YES];
    }

    return YES;
}
 
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 
    if ([textField isEqual:self.passwordField] && viewIsPulledUpForTextInput) {
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
        viewIsPulledUpForTextInput = (up ? YES : NO);

    }];

}
 

//Allow user to dismiss keyboard by tapping the View
//TODO: Implement for all Use Cases of Tapping and Entering Return on Keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (viewIsPulledUpForTextInput) {
        viewIsPulledUpForTextInput = NO;
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self moveLoginFieldsWithKeyboard:NO];
    }


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
        //tabController.isNewUserWithFacebookLogin = isNewUserFromFacebook;
    }
     
}


@end
