//
//  EditProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "EVNConstants.h"
#import "EditProfileVC.h"
#import "UIColor+EVNColors.h"
#import "UIImage+EVNEffects.h"

#import <Accounts/Accounts.h>
#import <Parse/Parse.h>

@interface EditProfileVC ()

//For TextField Persistnce
@property (nonatomic, strong) NSDictionary *userInputtedValues;

//Custom Cells
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hometownCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bioCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileImageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *socialTwitterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *socialFacebookCell;

//Editable Text Fields
@property (weak, nonatomic) IBOutlet UITextField *realNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *hometownTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *bioTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (strong, nonatomic) IBOutlet UIButton *connectWithTwitterButton;
@property (strong, nonatomic) IBOutlet UIButton *connectWithFacebookButton;

- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)finishedEditProfile:(id)sender;
- (IBAction)connectWithTwitter:(id)sender;

@end



@implementation EditProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;

    //change font color of title to white
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
    //Bar Button Item Text Attributes
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

    //default profile image
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.profileImageView.userInteractionEnabled = YES;
    //clear for transparency/masking
    self.profileImageView.backgroundColor = [UIColor clearColor];
    
    //Add Tap Gesture Recognizer to UIImageView to Update Profile Picture
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateProfilePicture)];
    [self.profileImageView addGestureRecognizer:tapgr];
    
    //Populate Edit Profile Screen with Values Passed From Profile VC
    self.realNameTextField.text = self.realName;
    self.hometownTextField.text = self.hometown;
    self.usernameTextField.text = self.username;
    self.bioTextField.text = self.bio;
    
    if (self.pictureData) {
        self.profileImageView.image = [UIImage imageWithData:self.pictureData];
    }
    
    self.realNameTextField.delegate = self;
    self.hometownTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.bioTextField.delegate = self;

}


#pragma mark - TextField Delegate Method to Dismiss Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0: {
            return 5;
            break;
        }
        case 1: {
            return 2;
            break;
        }
        default:
            return 2;
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
                NSLog(@"Returned default");
                return self.nameCell;
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                return self.socialTwitterCell;
                break;
            }
            case 1: {
                return self.socialFacebookCell;
                break;
            }
            default:
                NSLog(@"Returned thru default");
                return self.nameCell;
                break;
        }
        
    } else {
        NSLog(@"Returned thru else statement");
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
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    //Store Current User Inputs From Each Text Field for persistence
    self.userInputtedValues = [NSDictionary dictionaryWithObjectsAndKeys:self.realNameTextField.text, @"realName", self.hometownTextField.text, @"hometown", self.usernameTextField.text, @"username", self.bioTextField.text, @"bio", nil];
    
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}


#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }];
    
    self.profileImageView.backgroundColor = [UIColor clearColor];

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


- (void) restoreSavedValues {
    
    //Restore Values That the User Has Inputted
    NSString *usernameStored = [self.userInputtedValues objectForKey:@"username"];
    NSString *realNameStored = [self.userInputtedValues objectForKey:@"realName"];
    NSString *hometownStored = [self.userInputtedValues objectForKey:@"hometown"];
    NSString *bioStored = [self.userInputtedValues objectForKey:@"bio"];
    
    self.usernameTextField.text = usernameStored;
    self.realNameTextField.text = realNameStored;
    self.hometownTextField.text = hometownStored;
    self.bioTextField.text = bioStored;
}



#pragma mark - IBActions for Cancel and Finish Editing

- (IBAction)cancelEditProfile:(id)sender {

    id<ProfileEditDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEditingProfile)]) {
        
        [strongDelegate canceledEditingProfile];
    }
    
}

- (IBAction)finishedEditProfile:(id)sender {
    
    PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:self.pictureData];
    
    [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            [PFUser currentUser][@"profilePicture"] = profilePictureFile;

            [[PFUser currentUser] setUsername:self.usernameTextField.text];
            [[PFUser currentUser] setValue:self.realNameTextField.text forKey:@"realName"];
            [[PFUser currentUser] setValue:self.hometownTextField.text forKey:@"hometown"];
            [[PFUser currentUser] setValue:self.bioTextField.text forKey:@"bio"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    NSDictionary *newUserValues = [NSDictionary dictionaryWithObjectsAndKeys:self.realNameTextField.text, @"realName", self.hometownTextField.text, @"hometown", self.usernameTextField.text, @"username", self.bioTextField.text, @"bio", nil];
                    
                    id<ProfileEditDelegate> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(saveProfileWithNewInformation:withImageData:)]) {
                        
                        [strongDelegate saveProfileWithNewInformation:newUserValues withImageData:self.pictureData];
                    }
                    
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable To Update" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                }
            }];
        }
    }];
    
    
    
}


//TODO: Add connection with instagram - just use textfield. On viewDidLoad, check for existing Connections.
//TODO: Update profile images based on if connection was established.
//Assumes only one twitter account for the user.
- (IBAction)connectWithTwitter:(id)sender {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //TODO: Remove - this is only because I have already given access to my Twitter Account.
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    
    if ([accountsArray count] > 0) {
        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
        [PFUser currentUser][@"twitterHandle"] = twitterAccount.username;
        [[PFUser currentUser] saveInBackground];
    }
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                [PFUser currentUser][@"twitterHandle"] = twitterAccount.username;
                [[PFUser currentUser] saveInBackground];
                
                self.connectWithTwitterButton.titleLabel.text = @"Connected With Twitter";
                
            }
        }
    }];
}
@end
