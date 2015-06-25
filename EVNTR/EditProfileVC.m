//
//  EditProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "EditProfileVC.h"
#import "UIColor+EVNColors.h"
#import "UIImage+EVNEffects.h"

#import <Accounts/Accounts.h>
#import <Parse/Parse.h>

typedef enum {
    TBParseError_UsernameMissing = 200, // Username is missing or empty
    TBParseError_UsernameTaken = 202, // Username has already been taken
    TBParseError_SessionError = 206,
    
} TBParseError;

@interface EditProfileVC ()

@property (nonatomic, strong) NSDictionary *persistedUserValues;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hometownCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bioCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileImageCell;

@property (weak, nonatomic) IBOutlet UITextField *realNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *hometownTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (nonatomic) BOOL newProfilePictureChosen;

- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)finishedEditProfile:(id)sender;

@end


@implementation EditProfileVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    self.newProfilePictureChosen = NO;
    
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.profileImageView.userInteractionEnabled = YES;
    self.profileImageView.backgroundColor = [UIColor clearColor]; /* Cleared for masking */
    
    if (self.pictureData) {
        self.profileImageView.image = [UIImage imageWithData:self.pictureData];
    }
    
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateProfilePicture)];
    [self.profileImageView addGestureRecognizer:tapgr];
    
    //Populate Edit Profile Screen with Values Passed From Profile VC
    self.realNameTextField.text = self.realName;
    self.hometownTextField.text = self.hometown;
    self.usernameTextField.text = self.username;
    self.bioTextView.text = self.bio;
    
    self.realNameTextField.delegate = self;
    self.hometownTextField.delegate = self;
    self.usernameTextField.delegate = self;

}


- (void) setupNavigationBar {
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                   nil]
                                                         forState:UIControlStateNormal];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil]
                                                          forState:UIControlStateNormal];

}


#pragma mark - TextField & TextView Delegate Method to Dismiss Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0: {
            return 5;
            break;
        }
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                return self.nameCell;
                break;
            }
            case 1: {
                return self.hometownCell;
                break;
            }
            case 2: {
                return self.usernameCell;
                break;
            }
            case 3: {
                return self.bioCell;
                break;
            }
            case 4: {
                return self.profileImageCell;
                break;
            }
            default:
                return self.nameCell;
                break;
        }
        
    } else {
        return self.nameCell;
    }
    
}


#pragma mark - Image Picker & Delegates

- (void)updateProfilePicture {
    
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
        imagePicker.navigationBar.tintColor = [UIColor orangeThemeColor];
        imagePicker.navigationController.navigationBar.tintColor = [UIColor orangeThemeColor];
        
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
    
    self.persistedUserValues = [NSDictionary dictionaryWithObjectsAndKeys:self.realNameTextField.text, @"realName", self.hometownTextField.text, @"hometown", self.usernameTextField.text, @"username", self.bioTextView.text, @"bio", nil];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}


#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }];
    
    self.newProfilePictureChosen = YES;
    
    self.profileImageView.backgroundColor = [UIColor clearColor]; /* Clear Background for Masking */

    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
       
        self.profileImageView.image = maskedImage;
        
        UIImage *fullyMaskedImageForData = [UIImage imageWithView:self.profileImageView];
        
        self.pictureData = UIImagePNGRepresentation(fullyMaskedImageForData);
        
    }];
    
    [self restoreSavedValues];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    }];

    [self restoreSavedValues];
    
}



#pragma mark - User Actions

- (IBAction)cancelEditProfile:(id)sender {
    
    self.navigationItem.leftBarButtonItem.enabled = NO;

    id<ProfileEditDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEditingProfile)]) {
        
        [strongDelegate canceledEditingProfile];
    }
    
}

- (IBAction)finishedEditProfile:(id)sender {
    
    [self.view endEditing:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *submittedUsername = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *submittedName = self.realNameTextField.text;
    NSString *submittedBio = self.bioTextView.text;
    NSString *submittedHometown = self.hometownTextField.text;

    if (submittedUsername.length >= MIN_USERNAME_LENGTH && submittedUsername.length <= MAX_USERNAME_LENGTH && submittedBio.length <= MAX_BIO_LENGTH && submittedName.length >= MIN_REALNAME_LENGTH && submittedName.length <= MAX_REALNAME_LENGTH && submittedHometown.length <= MAX_HOMETOWN_LENGTH && [self validUsername:submittedUsername]) {
        
        if (self.newProfilePictureChosen) {
                        
            PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:self.pictureData];
            
            [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded){
                    
                    [EVNUser currentUser][@"profilePicture"] = profilePictureFile;

                    [self saveProfileDetails];
                    
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Profile Picture" message:@"We had trouble saving your profile picture.  Try to save it again.  If that doesn't work, contact us through the settings page." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                }
            }];
        
        } else {
            
            [self saveProfileDetails];
            
        }
        
    } else {
        
        if (submittedUsername.length < MIN_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is at least %d characters", (MIN_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (submittedUsername.length > MAX_USERNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Please choose a username that is %d characters or shorter", (MAX_USERNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (submittedName.length < MIN_REALNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Name" message:[NSString stringWithFormat:@"Please choose a name that is at least %d characters", (MIN_REALNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (submittedName.length > MAX_REALNAME_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Name" message:[NSString stringWithFormat:@"Please choose a name that is %d characters or shorter", (MAX_REALNAME_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }  else if (submittedBio.length > MAX_BIO_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bio" message:[NSString stringWithFormat:@"Please use a bio that is %d characters or shorter. You've clearly got a lot to say.  Maybe trying starting a blog?", (MAX_BIO_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (submittedHometown.length > MAX_HOMETOWN_LENGTH) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hometown" message:[NSString stringWithFormat:@"Please use a location that is %d characters or shorter.", (MAX_HOMETOWN_LENGTH)] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else if (![self validUsername:submittedUsername]) {
            
            NSArray *characterSets = [submittedUsername componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *correctedUsername = [characterSets componentsJoinedByString:@""];
            
            self.usernameTextField.text = correctedUsername;
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:[NSString stringWithFormat:@"Let us help you out some.  We've removed the spaces in your username.  Go ahead and click register again."] delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Edit Issue" message:@"Please make sure to fill in all fields before submitting." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }

}


#pragma mark - Helper Methods

- (void) saveProfileDetails {
    
    [[EVNUser currentUser] setUsername:self.usernameTextField.text];
    [[EVNUser currentUser] setValue:self.realNameTextField.text forKey:@"realName"];
    [[EVNUser currentUser] setValue:self.hometownTextField.text forKey:@"hometown"];
    [[EVNUser currentUser] setValue:self.bioTextView.text forKey:@"bio"];
    [[EVNUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            NSDictionary *newUserValues = [NSDictionary dictionaryWithObjectsAndKeys:self.realNameTextField.text, @"realName", self.hometownTextField.text, @"hometown", self.usernameTextField.text, @"username", self.bioTextView.text, @"bio", nil];
            
            id<ProfileEditDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(saveProfileWithNewInformation:withImageData:)]) {
                
                [strongDelegate saveProfileWithNewInformation:newUserValues withImageData:self.pictureData];
            }
            
        } else {
            
            switch ((TBParseError)error.code) {
                    
                case TBParseError_UsernameMissing: {
                    
                    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"Please choose a username." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
                    
                    [failureAlert show];
                    
                    break;
                }
                case TBParseError_UsernameTaken: {
                    
                    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Username" message:@"Please choose another username." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
                    
                    [failureAlert show];
                    
                    break;
                }
                case TBParseError_SessionError: {
                    
                    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you somehow got logged out.  Press cancel and then sign out (settings icon is on the top right of your profile) and log back in to fix this.  You have permission to be frustrated and send us angry tweets." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
                    
                    [failureAlert show];
                    
                    break;
                }
                default: {
                    
                    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Error Saving User" message:@"Try again and if it continues, press cancel and then logout and log back in." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                   
                    [failureAlert show];

                    break;
                }
            }
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        }
    }];

}


- (void) restoreSavedValues {
    
    NSString *usernameStored = [self.persistedUserValues objectForKey:@"username"];
    NSString *realNameStored = [self.persistedUserValues objectForKey:@"realName"];
    NSString *hometownStored = [self.persistedUserValues objectForKey:@"hometown"];
    NSString *bioStored = [self.persistedUserValues objectForKey:@"bio"];
    
    self.usernameTextField.text = usernameStored;
    self.realNameTextField.text = realNameStored;
    self.hometownTextField.text = hometownStored;
    self.bioTextView.text = bioStored;
    
}


- (BOOL) validUsername:(NSString *)username {
    
    if ([[username componentsSeparatedByString:@" "] count] > 1) {
        return NO;
    } else {
        return YES;
    }
    
}



@end
