//
//  SignUpVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNUtility.h"
#import "LogInVC.h"
#import "SignUpVC.h"
#import "UIColor+EVNColors.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


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


- (IBAction)signUpWithFacebook:(id)sender;

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
    
    self.backgroundView.layer.cornerRadius = 30;
    
    self.profileImageView.image = [EVNUtility maskImage:[UIImage imageNamed:@"PersonDefault"] withMask:[UIImage imageNamed:@"MaskImage"]];
    
    //Allow the User to Tap the Image View to Update their Photo
    UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentProfileImageActions)];
    tapToAddPhoto.delegate = self;
    [self.backgroundView addGestureRecognizer:tapToAddPhoto];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    if ([self.presentingViewController isKindOfClass:[LogInVC class]]) {
        
        [self grabUserDetailsFromFacebook];
    }
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
                
                
            } else {
                NSLog(@"User with facebook logged in!");
                NSLog(@"User is already signed up, send them to home page.");
                
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
                
                [UIView animateWithDuration:1.0 animations:^{
                    loginInTextLabel.alpha = 1;
                } completion:^(BOOL finished) {
                    
                    [self performSegueWithIdentifier:@"SignUpToHomeView" sender:self];
                    
                }];
            }
            
        }
        
        self.blurOutLogInScreen.alpha = 0;
        [self.blurOutLogInScreen removeFromSuperview];
        
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
            NSLog(@"FB User Data: %@", result);
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *firstName = userData[@"first_name"];
            NSString *email = userData[@"email"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSDictionary *userDetailsForFBRegistration = [NSDictionary dictionaryWithObjectsAndKeys:facebookID, @"ID", name, @"realName", location, @"location", firstName, @"firstName", email, @"email", pictureURL, @"profilePictureURL", nil];
            
            
            id<NewUserFacebookSignUpDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetailsFromSignUp:)]) {
                
                [strongDelegate createFBRegisterVCWithDetailsFromSignUp:userDetailsForFBRegistration];
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
    if (self.usernameField.text.length > 3 && self.passwordField.text.length > 3 && self.emailField.text.length > 0) {
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Signed Up" message:@"Welcome to EVNTR." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                
                [successAlert show];
                
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
                
                [self performSegueWithIdentifier:@"SignUpToOnBoard" sender:self];
                
                
            } else {
                
                //TODO : Incoporate Error Checking to Give User Better Idea of Problem Signing Up
                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Already Taken" message:@"Please choose another username" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                
                [failureAlert show];
            }
            
            self.blurOutLogInScreen.alpha = 0;
            [self.blurOutLogInScreen removeFromSuperview];

            
        }];
        
    } else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure to fill in all fields and that your username and password are greater than three characters." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        
        [errorAlert show];
    }

}

- (void) blurViewDuringLoginWithMessage:(NSString *)message {
    
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurOutLogInScreen = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.blurOutLogInScreen.alpha = 0;
    self.blurOutLogInScreen.frame = self.view.bounds;
    [self.view addSubview:self.blurOutLogInScreen];
    
    UILabel *loginInTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    loginInTextLabel.alpha = 0;
    loginInTextLabel.text = message;
    loginInTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:24];
    loginInTextLabel.textAlignment = NSTextAlignmentCenter;
    loginInTextLabel.textColor = [UIColor whiteColor];
    loginInTextLabel.center = self.view.center;
    [self.view addSubview:loginInTextLabel];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.blurOutLogInScreen.alpha = 1;
        loginInTextLabel.alpha = 1;
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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}



#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    self.profileImageView.image = [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"]];
    self.pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}


//Ensure that the ProfileImageView Receives Touch Events
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint touchSpot = [touch locationInView:self.backgroundView];
    return CGRectContainsPoint(self.profileImageView.frame, touchSpot);
}



@end



