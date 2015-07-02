//
//  NewUserFacebookVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "FBShimmeringView.h"
#import "NewUserFacebookVC.h"
#import "UIColor+EVNColors.h"
#import "UIImage+EVNEffects.h"

#import <Parse/Parse.h>

typedef enum {
    TBParseError_InvalidEmailAddress = 125, // The email address was invalid.
    TBParseError_UserEmailMissing = 204, // The email is missing, and must be specified
    TBParseError_UserEmailTaken = 203, // Email has already been taken
    TBParseError_UsernameMissing = 200, // Username is missing or empty
    TBParseError_UsernameTaken = 202, // Username has already been taken
    TBParseError_SessionError = 206, //Session expired
    
} TBParseError;

@interface NewUserFacebookVC ()

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *realNameLabel;

@property (strong, nonatomic) IBOutlet EVNButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) NSString *urlForProfilePicture;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *location;

@property (strong, nonatomic) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;

@property (nonatomic) BOOL viewIsPulledUpForTextInput;
@property (nonatomic) BOOL userIsAddingCustomPicture;

- (IBAction)registerWithFBInfo:(id)sender;

@end

@implementation NewUserFacebookVC

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Initialization
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.viewIsPulledUpForTextInput = NO;
    self.userIsAddingCustomPicture = NO;
    
    //Delegates
    self.usernameField.delegate = self;
    self.emailField.delegate = self;
    self.nameField.delegate = self;
    
    //Buttons
    self.continueButton.titleText = @"Continue";
    self.continueButton.isSelected = YES;
    self.continueButton.hasBorder = NO;
    
    //Labels
    self.usernameField.textColor = [UIColor blackColor];
    self.emailField.textColor = [UIColor blackColor];
    self.nameField.textColor = [UIColor blackColor];
    
    //Actions
    UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePhoto)];
    tapToAddPhoto.delegate = self;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:tapToAddPhoto];
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //Prepopulate with Facebook Data
    self.usernameField.text = ([self.informationFromFB objectForKey:@"firstName"]) ? (NSString *)[self.informationFromFB objectForKey:@"firstName"] : @"";
    self.emailField.text = ([self.informationFromFB objectForKey:@"email"]) ? (NSString *)[self.informationFromFB objectForKey:@"email"] : @"";
    self.nameField.text = ([self.informationFromFB objectForKey:@"realName"]) ? (NSString *)[self.informationFromFB objectForKey:@"realName"] : @"";
    
    self.facebookID = ([self.informationFromFB objectForKey:@"ID"]) ? (NSString *)[self.informationFromFB objectForKey:@"ID"] : @"";
    self.firstName = ([self.informationFromFB objectForKey:@"firstName"]) ? (NSString *)[self.informationFromFB objectForKey:@"firstName"] : @"";
    self.location = ([self.informationFromFB objectForKey:@"location"]) ? (NSString *)[self.informationFromFB objectForKey:@"location"] : @"";
        
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Grab Facebook Profile Picture
    if ([self.informationFromFB objectForKey:@"profilePictureURL"]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"profilePictureURL"]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   
                                   if (connectionError == nil && data != nil) {
                                       
                                       [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
                                           
                                           if (!self.userIsAddingCustomPicture) {
                                               self.profileImageView.image = maskedImage;
                                           }
                                           
                                       }];
                                       
                                   }
                               }];
        
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Registration And Navigation

- (IBAction)registerWithFBInfo:(id)sender {
    
    __block EVNUser *currentUser = [EVNUser currentUser];
    
    [self blurViewDuringLoginWithMessage:@"Registering..."];
    
    NSString *submittedUsername = self.usernameField.text;
    NSString *submittedName = self.nameField.text;
    NSString *submittedEmail = self.emailField.text;
    
    if (submittedUsername.length >= MIN_USERNAME_LENGTH && submittedUsername.length <= MAX_USERNAME_LENGTH && submittedName.length >= MIN_REALNAME_LENGTH && submittedName.length <= MAX_REALNAME_LENGTH && submittedEmail.length > 0) {
        
        //Clear Background and Flattening for Parse
        self.profileImageView.backgroundColor = [UIColor clearColor];
        UIImage *fullyMaskedForData = [UIImage imageWithView:self.profileImageView];
        NSData *pictureDataForParse = UIImagePNGRepresentation(fullyMaskedForData);
        
        PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:pictureDataForParse];
        
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                currentUser[@"profilePicture"] = profilePictureFile;
                
                currentUser.username = self.usernameField.text;
                currentUser.email = self.emailField.text;
                currentUser[@"realName"] = self.nameField.text;
                currentUser[@"facebookID"] = [NSString stringWithFormat:@"%@", self.facebookID];
                currentUser[@"hometown"] = [NSString stringWithFormat:@"%@", self.location];
                
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                        [standardDefaults setBool:NO forKey:kIsGuest];
                        [standardDefaults synchronize];
                        
                        [self performSegueWithIdentifier:@"FBRegisterToOnboard" sender:nil];
                        
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
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please use another email." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                                
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
                            case TBParseError_SessionError: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you somehow got logged out already.  This is embarassing.  Contact us - http://evntr.co - and we'll get this fixed for you." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                break;
                            }
                            default: {
                                
                                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:@"Please check your username and email." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                                
                                [failureAlert show];
                                
                                
                                break;
                            }
                        }

                    }
                    
                }];
            
            } else {
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Profile Picture" message:@"Looks like we had trouble saving your profile picture.  Try again and if it still doesn't work, send us a tweet @EvntrApp." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                
                [errorAlert show];
            }
            
            [self cleanUpBeforeTransition];
            
        }];
    

    } else {
        
        if (self.emailField.text.length < 1) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Email" message:@"Add your email before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.usernameField.text.length < MIN_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is at least %d characters", (MIN_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.usernameField.text.length > MAX_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is at most %d characters", (MAX_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (self.nameField.text.length < MIN_REALNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Name" message:[NSString stringWithFormat:@"Please choose a name that is at least %d characters", (MIN_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
        
        } else if (self.nameField.text.length >= MAX_REALNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Name" message:[NSString stringWithFormat:@"Please choose a name that is at most %d characters", (MAX_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Sign Up Issue" message:@"Please make sure to fill in all fields before signing up." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
        
        [self cleanUpBeforeTransition];
        
    }

}


#pragma mark - User Actions

- (void) changePhoto {
    
    self.userIsAddingCustomPicture = YES;
    
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
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}



#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
    
    self.profileImageView.backgroundColor = [UIColor clearColor];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedFullyImage) {
        
        self.profileImageView.image = maskedFullyImage;
        
    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
    
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
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
    
    if (!self.viewIsPulledUpForTextInput && self.nameField.isFirstResponder) {
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
    
    if (self.viewIsPulledUpForTextInput && self.nameField.isFirstResponder) {
        [self moveLoginFieldsUp:NO withKeyboardSize:movement];
        
    }
    
}


//Tap Dismisses Keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /*
    if (self.viewIsPulledUpForTextInput) {
        [self.usernameField resignFirstResponder];
        [self.emailField resignFirstResponder];
        [self.nameField resignFirstResponder];
    }
     */
    
    [self.view endEditing:YES];
}



#pragma mark - Helper Methods

- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    int movement = (up ? -distance : distance);
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        self.usernameField.hidden = (up ? 1 : 0);
        self.emailField.hidden = (up ? 1 : 0);
        self.usernameLabel.hidden = (up ? 1 : 0);
        self.emailLabel.hidden = (up ? 1 : 0);
        
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
    
    } completion:nil];
    
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


@end


