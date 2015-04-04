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

    //Setting Up TextFields and Other Elements
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
    
    //Allow the User to Tap the Image View to Update their Photo
    UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentProfileImageActions)];
    tapToAddPhoto.delegate = self;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:tapToAddPhoto];
    
    
    self.registerButton.titleText = @"Register";
    self.registerButton.isSelected = YES;
    self.registerButton.isStateless = YES;
    self.registerButton.font = [UIFont fontWithName:@"Lato-Light" size:21];
    self.registerButton.isRounded = NO;
    
    self.viewIsPulledUpForTextInput = NO;

    
    
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
    
    //TODO:  Needed?
    if ([self.presentingViewController isKindOfClass:[LogInVC class]]) {
        
        [self grabUserDetailsFromFacebook];
    }
    
    if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    if ([self.emailField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    if ([self.passwordField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.8] }];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



- (IBAction)signUpWithFacebook:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Signing Up..."];
    
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
                NSLog(@"User is already signed up, send them to home page.");
                
                /*
                UILabel *loginInTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
                loginInTextLabel.alpha = 0;
                loginInTextLabel.text = @"WELCOME to EVNTR";
                loginInTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:26];
                loginInTextLabel.textAlignment = NSTextAlignmentCenter;
                loginInTextLabel.textColor = [UIColor whiteColor];
                loginInTextLabel.center = self.view.center;
                [self.view addSubview:loginInTextLabel];
                */
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
            
            
            id<NewUserFacebookSignUpDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetailsFromSignUp:)]) {
                
                [strongDelegate createFBRegisterVCWithDetailsFromSignUp:[NSDictionary dictionaryWithDictionary:userDetailsForFBRegistration]];
            }
            
            
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
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure to fill in all fields and that your username and password are greater than three characters." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        
        [errorAlert show];
        
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
        //empt
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

//Adjust View When The User Starts Inputting Credentials
/*
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
*/

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSLog(@"KEYBOARDWILL SHOW");
    
    //NSValue * keyboardEndFrame;
    CGRect    screenRect;
    CGRect    windowRect;
    CGRect    viewRect;
    
    // determine's keyboard height
    screenRect    = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect    = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect      = [self.view        convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (!self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:YES withKeyboardSize:movement];
        
    }
    
    
    /*
     NSTimeInterval  duration;
     CGRect          frame;
     
     // determine length of animation
     duration  = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
     
     // resize the view
     frame              = self.view.frame;
     frame.size.height -= viewRect.size.height;
     
     // animate view resize with the keyboard movement
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationBeginsFromCurrentState:YES];
     [UIView setAnimationDuration:duration];
     self.view.frame = frame;
     [UIView commitAnimations];
     */
    
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSLog(@"KEYBOARDWILL HIDE");
    
    //NSValue * keyboardEndFrame;
    CGRect    screenRect;
    CGRect    windowRect;
    CGRect    viewRect;
    
    // determine's keyboard height
    screenRect    = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect    = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect      = [self.view        convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:NO withKeyboardSize:movement];
        
    }
    
}


- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    //TODO : Adjust According to Keyboard of System
    
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
//TODO: Implement for all Use Cases of Tapping and Entering Return on Keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.viewIsPulledUpForTextInput) {
        //self.viewIsPulledUpForTextInput = NO;
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self.emailField resignFirstResponder];
        //[self moveLoginFieldsWithKeyboard:NO];
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


-(void)dealloc
{
    NSLog(@"signupvc is being deallocated");
    
}

@end



