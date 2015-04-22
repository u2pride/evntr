//
//  SignUpVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUtility.h"
#import "FBShimmeringView.h"
#import "LogInVC.h"
#import "SignUpVC.h"
#import "UIColor+EVNColors.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


typedef enum {
    TBParseError_InvalidEmailAddress = 125, // The email address was invalid.
    TBParseError_UserEmailMissing = 204, // The email is missing, and must be specified
    TBParseError_UserEmailTaken = 203, // Email has already been taken
    TBParseError_UsernameMissing = 200, // Username is missing or empty
    TBParseError_UsernameTaken = 202, // Username has already been taken
    TBParseError_UserPasswordMissing = 201, // Password is missing or empty
    
} TBParseError;


@interface SignUpVC ()

//User Entered Info
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;

//Background View for Fake Table Appearance - ImageView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

//Users Picture Data
@property (nonatomic, strong) NSData *pictureData;

@property (strong, nonatomic) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;

@property (strong, nonatomic) IBOutlet EVNButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *connectWithFacebookButton;

@property (nonatomic) BOOL viewIsPulledUpForTextInput;

- (IBAction)signUpWithFacebook:(id)sender;
- (IBAction)signUp:(id)sender;

@end


@implementation SignUpVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    self.usernameField.text = nil;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = nil;
    self.passwordField.placeholder = @"password";
    
    self.emailField.text = nil;
    self.emailField.placeholder = @"email";
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.backgroundView.layer.cornerRadius = 20;
    self.backgroundView.layer.borderWidth = 1.0f;
    self.backgroundView.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    
    self.profileImageView.image = [EVNUtility maskImage:[UIImage imageNamed:@"PersonDefault"] withMask:[UIImage imageNamed:@"MaskImage"]];
    
    UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentProfileImageActions)];
    tapToAddPhoto.delegate = self;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:tapToAddPhoto];
    
    self.registerButton.titleText = @"Register";
    self.registerButton.isSelected = YES;
    self.registerButton.isStateless = YES;
    self.registerButton.font = [UIFont fontWithName:@"Lato-Light" size:21];
    self.registerButton.isRounded = NO;
    self.registerButton.backgroundColor = [UIColor orangeThemeColor];
    
    self.viewIsPulledUpForTextInput = NO;
    
    self.connectWithFacebookButton.layer.cornerRadius = 5.0f;

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
    
    
    if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    }
    
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    }
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (IBAction)signUpWithFacebook:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Signing Up..."];
    
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
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
                NSLog(@"User with facebook signed up and logged in!");
                
                double delayInSeconds = 3.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self grabUserDetailsFromFacebookWithUser:user];
                    [self cleanUpBeforeTransition];
                    
                });
                
            } else {
                NSLog(@"User with facebook logged in!");
                NSLog(@"User is already signed up, send them to home page.");
                
                //Set isGuest Object
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                double delayInSeconds = 3.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"SignUpToHomeView" sender:self];
                    [self cleanUpBeforeTransition];
                    
                });
                
                
            }
            
        }
        
    }];

    
}


- (void) grabUserDetailsFromFacebookWithUser:(PFUser *)newUser {
    
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
            
            NSLog(@"User Before New Data: %@", newUser);
            
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
            
            NSLog(@"User After New Data Before Save: %@", newUser);
            
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                NSLog(@"Finished Saving in Background - %@", [NSNumber numberWithBool:succeeded]);
                
                id<NewUserFacebookSignUpDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetailsFromSignUp:)]) {
                    
                    [strongDelegate createFBRegisterVCWithDetailsFromSignUp:[NSDictionary dictionaryWithDictionary:userDetailsForFBRegistration]];
                }
                
            }];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to retrieve Facebook details." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
        
    }];
    
}

#pragma mark - Sign Up New User

- (void)signUp:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Signing Up..."];
    
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    
    //Validate that the user has submitted a user name and password
    if (self.usernameField.text.length > 3 && self.passwordField.text.length > 3 && self.emailField.text.length > 0 && self.pictureData) {
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                
                //Create user then save profile picture and other information.
                PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:self.pictureData];
                
                [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        newUser[@"profilePicture"] = profilePictureFile;
                        [newUser saveInBackground];
                    }
                }];
                
                //Set isGuest Object
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"SignUpToOnBoard" sender:self];
                    [self cleanUpBeforeTransition];
                });

                
                
            } else {
                
                switch ((TBParseError)error.code) {
                        
                    case TBParseError_InvalidEmailAddress: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose another email address." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    case TBParseError_UserEmailMissing: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose an email." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    case TBParseError_UserEmailTaken: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose another email." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    case TBParseError_UsernameMissing: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose a username." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    case TBParseError_UsernameTaken: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose another username." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    case TBParseError_UserPasswordMissing: {
                        
                        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose a password." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [failureAlert show];
                        
                        break;
                    }
                    default:
                        break;
                }
                
                
                [self cleanUpBeforeTransition];

            }
            

            
        }];
        
    } else {
        
        if (!self.pictureData) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Profile Picture" message:@"Click on the photo to choose a profile picture." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.emailField.text.length < 1) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Email" message:@"Add your email before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.usernameField.text.length <= 3) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"Please choose a username that is greater than three characters" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.passwordField.text.length <= 3) {
        
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Password" message:@"Please choose a password that is greater than three characters" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Issue" message:@"Please make sure to fill in all fields before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
        
        [self cleanUpBeforeTransition];

    }

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


#pragma mark - Upload Image Sheet

- (void) presentProfileImageActions {
    
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.view.tintColor = [UIColor orangeThemeColor];

        [self presentViewController:imagePicker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            
            
        }];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:^{
        
    }];
    
}



#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    self.profileImageView.image = [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"]];
    self.pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];

}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameField]) {
        [self.emailField becomeFirstResponder];
    } else if ([textField isEqual:self.emailField]) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect screenRect;
    CGRect windowRect;
    CGRect viewRect;
    
    screenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect = [self.view        convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (!self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:YES withKeyboardSize:movement];
        
    }
    
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
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


- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    int movement = (up ? -distance : distance);
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        self.registerButton.alpha = (up ? 0 : 1);
        self.profileImageView.alpha = (up ? 0 : 1);
        self.connectWithFacebookButton.alpha = (up ? 0 : 1);
        
    } completion:^(BOOL finished) {
        self.viewIsPulledUpForTextInput = (up ? YES : NO);
        
    }];
    
}


//Allow user to dismiss keyboard by tapping the View
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.viewIsPulledUpForTextInput) {
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self.emailField resignFirstResponder];
    }
    
    
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


-(void)dealloc {
    NSLog(@"signupvc is being deallocated");
}

@end



