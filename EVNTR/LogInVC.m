//
//  LogInVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "FBShimmeringView.h"
#import "FacebookSDK/FacebookSDK.h"
#import "HomeScreenVC.h"
#import "IDTransitioningDelegate.h"
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
@property (weak, nonatomic) IBOutlet EVNButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (weak, nonatomic) IBOutlet UILabel *textSeparator;
@property (weak, nonatomic) IBOutlet UIView *separatorLineLeft;
@property (weak, nonatomic) IBOutlet UIView *separatorLineRight;

@property (nonatomic, strong) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic) BOOL isNewUserFromFacebook;
@property (nonatomic) BOOL viewIsPulledUpForTextInput;

- (IBAction)resetUserPassword:(id)sender;
- (IBAction)login:(id)sender;

@end


@implementation LogInVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    //Initialization
    self.isNewUserFromFacebook = NO;
    self.viewIsPulledUpForTextInput = NO;
    self.transitioningDelegateForModal = [[IDTransitioningDelegate alloc] init];
    
    self.usernameField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    
    self.fbLoginButton.layer.cornerRadius = 4.0;

    self.loginButton.titleText = @"Log In";
    self.loginButton.font = [UIFont fontWithName:EVNFontRegular size:21];
    self.loginButton.isRounded = NO;
    self.loginButton.isSelected = YES;
    self.loginButton.isStateless = YES;

    //Delegates
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    }
    
    if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.6 alpha:0.6] }];
    }
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



#pragma mark - Login Requests

- (void)login:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Logging you in..."];
    
    [EVNUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        
        if (user) {
            
            NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
            [standardDefaults setBool:NO forKey:kIsGuest];
            [standardDefaults synchronize];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
                [self cleanUpBeforeTransition];
            });
            
        } else {

            UIAlertView *loginIssue = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you mistyped your username or password." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [loginIssue show];
            
            [self cleanUpBeforeTransition];
            
        }

    }];
    
}


- (IBAction)loginWithFacebook:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Logging you in..."];
    
    // TODO:  Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            
            [self cleanUpBeforeTransition];
            
            // Handles cases like Facebook password change or unverified Facebook accounts.
            NSString *alertMessage, *alertTitle;
            
            if ([FBErrorUtility shouldNotifyUserForError:error]) {
                alertTitle = [FBErrorUtility userTitleForError:error];
                alertMessage = [FBErrorUtility userMessageForError:error];
                
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                alertTitle = @"Session Error";
                alertMessage = @"Your current session is no longer valid. Please log in again.";
                
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"user cancelled login");
                
            } else {
                alertTitle  = @"Something went wrong";
                alertMessage = @"Please try again later.";
                NSLog(@"Unexpected error:%@", error);
            }
            
            if (alertMessage) {
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertMessage
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            
            
        } else {
            
            if (user.isNew) {
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self grabUserDetailsFromFacebookWithUser:(EVNUser *)user];
                    [self cleanUpBeforeTransition];

                });
                
            } else {
                
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"LoginToHomeView" sender:self];
                    [self cleanUpBeforeTransition];

                });
                    

            }
            
        }
        

        
    }];
    
    
}


- (void) grabUserDetailsFromFacebookWithUser:(EVNUser *)newUser {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            [activityIndicator stopAnimating];
            
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *userDetailsForFBRegistration = [[NSMutableDictionary alloc] init];
            
            if (userData[@"id"]) {
                [userDetailsForFBRegistration setObject:userData[@"id"] forKey:@"ID"];
            }
            
            if (userData[@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"name"] forKey:@"realName"];
            }
            
            if (userData[@"location"][@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"location"][@"name"] forKey:@"location"];
            }
            
            if (userData[@"first_name"]) {
                [userDetailsForFBRegistration setObject:userData[@"first_name"] forKey:@"firstName"];
            }
            
            if (userData[@"email"]) {
                [userDetailsForFBRegistration setObject:userData[@"email"] forKey:@"email"];
            }
            
            if (userData[@"id"]) {
                
                NSString *facebookID = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                
                [userDetailsForFBRegistration setObject:pictureURL forKey:@"profilePictureURL"];
            }
            
            //Submit Initial User Info In Case they Quit the Process Before Finishing Evntr Register Process
            if (userData[@"email"]) {
                newUser[@"email"] = (NSString *) userData[@"email"];
            }
            
            if (userData[@"first_name"]) {
                newUser[@"username"] = (NSString *) userData[@"first_name"];
            } else {
                newUser[@"username"] = @"Evntr User";
            }
            
            if (userData[@"id"]) {
                newUser[@"facebookID"] = userData[@"id"];
            }
            
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                id<NewUserFacebookDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetails:)]) {
                    
                    [strongDelegate createFBRegisterVCWithDetails:[NSDictionary dictionaryWithDictionary:userDetailsForFBRegistration]];
                }
                
            }];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hmmmm" message:@"Looks like we had trouble retrieving your Facebook details.  Send us a tweet at 'EvntrApp' if you continue to have issues." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
    
    }];
    
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RestartMoviePlayer" object:nil];
    
}


#pragma mark - Reset User Password Modal

//Present Modal View for Resetting Password
- (IBAction)resetUserPassword:(id)sender {
    
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    resetPasswordModal.delegate = self;
    
    [self blurViewDuringLoginWithMessage:@""];
    
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


- (void) keyboardWillShow:(NSNotification *)notification {
    
    CGRect    screenRect;
    CGRect    windowRect;
    CGRect    viewRect;
    
    screenRect    = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect    = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect      = [self.view        convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (!self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:YES withKeyboardSize:movement];
    }
}


- (void) keyboardWillHide:(NSNotification *)notification {
    
    CGRect screenRect;
    CGRect windowRect;
    CGRect viewRect;
    
    screenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect = [self.view convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:NO withKeyboardSize:movement];
    }
}
 

//Tap To Dismiss Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.viewIsPulledUpForTextInput) {
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
    }

}



#pragma mark - Delegate Methods from Reset Password Modal

- (void) resetPasswordSuccess {
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) resetPasswordFailed {
    
    [self cleanUpBeforeTransition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) resetPasswordCanceled {
    
    [self cleanUpBeforeTransition];

    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Helper Methods

- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    int movement = (up ? -distance : distance);
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        self.fbLoginButton.alpha = (up ? 0 : 1);
        self.forgotPasswordButton.alpha = (up ? 0 : 1);
        self.textSeparator.alpha = (up ? 0 : 1);
        self.loginButton.alpha = (up ? 0 : 1);
        self.separatorLineLeft.alpha = (up ? 0 : 1);
        self.separatorLineRight.alpha = (up ? 0 : 1);
        
    } completion:^(BOOL finished) {
        self.viewIsPulledUpForTextInput = (up ? YES : NO);
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
    self.blurMessage.font = [UIFont fontWithName:EVNFontRegular size:24];
    self.blurMessage.textAlignment = NSTextAlignmentCenter;
    self.blurMessage.textColor = [UIColor whiteColor];
    self.blurMessage.center = self.view.center;
    
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


#pragma mark - Clean Up

- (void) dealloc {
    NSLog(@"loginvc is being deallocated");
}


@end
