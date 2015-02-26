//
//  SignUpVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SignUpVC.h"
#import <Parse/Parse.h>
#import "EVNUtility.h"
#import "UIColor+EVNColors.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "LogInVC.h"


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

@end



@implementation SignUpVC

@synthesize usernameField, passwordField, emailField;
@synthesize backgroundView, profileImageView, pictureData;


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
        NSLog(@"facebook presentation");
        
        [self grabUserDetailsFromFacebook];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}



- (void)grabUserDetailsFromFacebook {
    
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
            //NSString *gender = userData[@"gender"];
            //NSString *birthday = userData[@"birthday"];
            // NSString *relationship = userData[@"relationship_status"];
            
            
            NSLog(@"%@", [NSString stringWithFormat:@"ID: %@ - Name: %@ - Location: %@ - firstName: %@", facebookID, name, location, firstName]);
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {

                     UIImage *profileImage2 = [UIImage imageWithData:data];
                     
                     NSLog(@"ABOUT TO GET THE PROFILE IMAGE DATA with data - %@", data);
                     
                     NSData *pictureData = UIImageJPEGRepresentation(profileImage2, 0.5);
                     
                     PFFile *profileImage = [PFFile fileWithName:@"profilepic.jpg" data:pictureData];
                     [profileImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             NSLog(@"YAY");
                             [[PFUser currentUser] setValue:profileImage forKey:@"profilePicture"];
                         }
                         
                     }];
                 }
                 
                 [[PFUser currentUser] setObject:firstName forKey:@"username"];
                 [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
                 [[PFUser currentUser] setObject:name forKey:@"realName"];
                 [[PFUser currentUser] setObject:location forKey:@"hometown"];
                 
                 //Update UI with FB Details
                 //self.usernameField.text = firstName;
                 //self.passwordField.text
                 
                 
                 //Save User Details to Parse
                 [[PFUser currentUser] saveInBackground];
                 
                 
             }];
            
            
            
        }
    }];
    
}




#pragma mark - Sign Up New User

- (void)signUp:(id)sender {
    
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
                PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:pictureData];
                
                [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        newUser[@"profilePicture"] = profilePictureFile;
                        [newUser saveInBackground];
                    }
                }];
                
                [self performSegueWithIdentifier:@"SignUpToOnBoard" sender:self];
                
            } else {
                
                //TODO : Incoporate Error Checking to Give User Better Idea of Problem Signing Up
                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Already Taken" message:@"Please choose another username" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                
                [failureAlert show];
                
            }
        }];
        
    } else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure to fill in all fields and that your username and password are greater than three characters." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        
        [errorAlert show];
    }

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
