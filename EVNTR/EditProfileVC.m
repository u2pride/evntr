//
//  EditProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EditProfileVC.h"
#import <Parse/Parse.h>
#import "EVNUtility.h"
#import <Accounts/Accounts.h>
#import "UIColor+EVNColors.h"

@interface EditProfileVC ()

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

//Actions to Cancel And Finish Editing
- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)finishedEditProfile:(id)sender;

//For TextField Persistnce
@property (nonatomic, strong) NSDictionary *userInputtedValues;

- (IBAction)connectWithTwitter:(id)sender;

@end

@implementation EditProfileVC



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //change font color of title to white
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    //default profile image
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.profileImageView.userInteractionEnabled = YES;
    
    //Add Tap Gesture Recognizer to UIImageView to Update Profile Picture
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateProfilePicture)];
    [self.profileImageView addGestureRecognizer:tapgr];
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;

    
    //Populate Edit Profile Screen with Values Passed From Profile VC
    self.realNameTextField.text = self.realName;
    self.hometownTextField.text = self.hometown;
    self.usernameTextField.text = self.username;
    self.bioTextField.text = self.bio;
    
    self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:self.pictureData] withMask:[UIImage imageNamed:@"MaskImage"]];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                NSLog(@"Returned thru default");
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


#pragma mark - Update Profile Picture

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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    
    //Store Current User Inputs From Each Text Field
    self.userInputtedValues = [NSDictionary dictionaryWithObjectsAndKeys:self.realNameTextField.text, @"realName", self.hometownTextField.text, @"hometown", self.usernameTextField.text, @"username", self.bioTextField.text, @"bio", nil];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}



#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    self.profileImageView.image = [EVNUtility maskImage:chosenPicture withMask:[UIImage imageNamed:@"MaskImage"]];
    
    self.pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:self.pictureData];
    
    [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            [PFUser currentUser][@"profilePicture"] = profilePictureFile;
            [[PFUser currentUser] saveInBackground];
        }
    }];
    
    
    //Restore Values That the User Has Inputted
    NSString *usernameStored = [self.userInputtedValues objectForKey:@"username"];
    NSString *realNameStored = [self.userInputtedValues objectForKey:@"realName"];
    NSString *hometownStored = [self.userInputtedValues objectForKey:@"hometown"];
    NSString *bioStored = [self.userInputtedValues objectForKey:@"bio"];
    
    self.usernameTextField.text = usernameStored;
    self.realNameTextField.text = realNameStored;
    self.hometownTextField.text = hometownStored;
    self.bioTextField.text = bioStored;
    
    NSLog(@"usernamed stored; %@", usernameStored);
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
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
    
    //Image Data is in self.pictureData
    //Package up new string values in NSDictionary
    
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



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.accountType);
                
                [PFUser currentUser][@"twitterHandle"] = twitterAccount.username;
                [[PFUser currentUser] saveInBackground];
                
            }
        }
    }];
}
@end
