//
//  SignUpVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "Amplitude/Amplitude.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "LogInVC.h"
#import "SignUpVC.h"
#import "UIColor+EVNColors.h"
#import "UIImage+EVNEffects.h"

#import <Parse/Parse.h>

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

@property (strong, nonatomic) IBOutlet EVNButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *connectWithFacebookButton;

@property (nonatomic) BOOL userPickedProfileImage;

- (IBAction)signUpWithFacebook:(id)sender;
- (IBAction)signUp:(id)sender;

@end


@implementation SignUpVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialization
    self.userPickedProfileImage = NO;
    
    //UITextFields
    self.usernameField.text = nil;
    self.usernameField.placeholder = @"username";
    
    self.passwordField.text = nil;
    self.passwordField.placeholder = @"password";
    
    self.emailField.text = nil;
    self.emailField.placeholder = @"email";
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    
    //Buttons
    self.registerButton.titleText = @"Register";
    self.registerButton.isSelected = YES;
    self.registerButton.isStateless = YES;
    self.registerButton.font = [UIFont fontWithName:@"Lato-Light" size:21];
    self.registerButton.isRounded = NO;
    self.registerButton.hasBorder = NO;
    self.registerButton.backgroundColor = [UIColor orangeThemeColor];
    
    self.connectWithFacebookButton.layer.cornerRadius = 5.0f;
    
    //Views
    self.backgroundView.layer.cornerRadius = 20;
    self.backgroundView.layer.borderWidth = 1.0f;
    self.backgroundView.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefaultAdd"];
    self.profileImageView.backgroundColor = [UIColor clearColor];
    
    //Actions
    UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentImagePicker)];
    tapToAddPhoto.delegate = self;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:tapToAddPhoto];

}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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


#pragma mark - Registration And Navigation

- (IBAction)signUpWithFacebook:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Signing Up..."];
    
    [self loginThruFacebook];
    
}


- (void) signUp:(id)sender {
    
    [self blurViewDuringLoginWithMessage:@"Signing Up..."];
    
    EVNUser *newUser = (EVNUser *)[EVNUser object];
    newUser.username = self.usernameField.text;
    //newUser.canonicalUsername = self.usernameField.text.lowercaseString;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    
    NSString *submittedUsername = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *submittedPassword = self.passwordField.text;
    NSString *submittedEmail = self.emailField.text;
    
    
    if (submittedUsername.length >= MIN_USERNAME_LENGTH && submittedUsername.length <= MAX_USERNAME_LENGTH && submittedPassword.length >= MIN_PASSWORD_LENGTH && submittedEmail.length > 0 && [self validUsername:submittedUsername]) {
        
        if (!self.userPickedProfileImage) {
            self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
        }
        
        UIImage *fullyMaskedForData = [UIImage imageWithView:self.profileImageView];
        NSData *pictureDataForParse = UIImagePNGRepresentation(fullyMaskedForData);
        
        PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:pictureDataForParse];
        
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                newUser[@"profilePicture"] = profilePictureFile;
                
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [[Amplitude instance] setUserId:newUser.objectId];
                        [[Amplitude instance] logEvent:@"Signed Up"];
                        
                        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                        [standardDefaults setBool:NO forKey:kIsGuest];
                        [standardDefaults synchronize];
                        
                        [self performSegueWithIdentifier:@"SignUpToOnBoard" sender:self];
                        
                    } else {
                        
                        switch ((TBParseError)error.code) {
                                
                            case TBParseError_InvalidEmailAddress: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose a valid email address." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            case TBParseError_UserEmailMissing: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose an email." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            case TBParseError_UserEmailTaken: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please use another email." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            case TBParseError_UsernameMissing: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose a username." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            case TBParseError_UsernameTaken: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Already taken. Please choose another username." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            case TBParseError_UserPasswordMissing: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please choose a password." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            default: {
                                                                
                                NSString *errorMessage = [error.userInfo objectForKey:@"error"];
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:errorMessage delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                                
                        }
                        
                        [self cleanUpBeforeTransition];
                        
                    }
                    
                }];
                
            } else {
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Profile Picture" message:@"Looks like we had trouble saving your profile picture.  Try again and if it still doesn't work, send us a tweet @EvntrApp." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                
                [errorAlert show];
                
                [self cleanUpBeforeTransition];
            }
            
        }];
        
    } else {
        
        if (self.emailField.text.length < 1) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Email" message:@"Add your email before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.usernameField.text.length < MIN_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is at least %d characters", (MIN_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.usernameField.text.length > MAX_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is %d characters or shorter", (MAX_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.passwordField.text.length < MIN_PASSWORD_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Password" message:[NSString stringWithFormat:@"Please choose a password that is at least %d characters", (MIN_PASSWORD_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (![self validUsername:submittedUsername]) {
          
            NSArray *characterSets = [submittedUsername componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *correctedUsername = [characterSets componentsJoinedByString:@""];
            
            self.usernameField.text = correctedUsername;
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Username" message:[NSString stringWithFormat:@"Let us help you out some.  We've removed the spaces in your username.  Go ahead and click register again."] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Issue" message:@"Please make sure to fill in all fields before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
        [self cleanUpBeforeTransition];
        
    }
    
    
}


#pragma mark - Overriden Delegate Method for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [super imagePickerController:picker didFinishPickingMediaWithInfo:info];
    
    self.userPickedProfileImage = YES;
    self.profileImageView.backgroundColor = [UIColor clearColor];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedFullyImage) {
        
        self.profileImageView.image = maskedFullyImage;
        
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


#pragma mark - Helper Methods

- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    [super moveLoginFieldsUp:up withKeyboardSize:distance];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.registerButton.alpha = (up ? 0 : 1);
        self.profileImageView.alpha = (up ? 0 : 1);
        self.connectWithFacebookButton.alpha = (up ? 0 : 1);
        
    } completion:^(BOOL finished) {
    
    }];
    
}

- (BOOL) validUsername:(NSString *)username {
    
    if ([[username componentsSeparatedByString:@" "] count] > 1) {
        return NO;
    } else {
        return YES;
    }
    
}



@end