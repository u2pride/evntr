//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ProfileVC.h"
#import "SWRevealViewController.h"
@import UIKit;

@interface ProfileVC ()

@end

//CREATE A PROPERTY OF PFUSER AND PASS IN THE CURRENT USER... SO YOU DONT HAVE TO DO SO MANY CURRENTUSER CALLS.

@implementation ProfileVC

@synthesize profileImageView, nameLabel, twitterLabel, instagramLabel, numberEventsLabel, numberFollowersLabel, numberFollowingLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    
    //Populate Profile Page with Details from Parse
    PFFile *profilePictureFromParse = [PFUser currentUser][@"profilePicture"];
    [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            self.profileImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    self.nameLabel.text = [PFUser currentUser][@"username"];
    
    self.twitterLabel.text = [PFUser currentUser][@"Twitter"];
    self.instagramLabel.text = [PFUser currentUser][@"Instagram"];
    
    self.numberEventsLabel.text = [PFUser currentUser][@"Events_Created"];
    NSArray *numberOfFollowers = (NSArray *)[PFUser currentUser][@"Followers"];
    NSArray *numberOfFollowing = (NSArray *)[PFUser currentUser][@"Following"];
    
    self.numberFollowersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowers.count];
    
    self.numberFollowingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowing.count];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}


///Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenPicture;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSData *profilePictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:profilePictureData];
    
    [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            [PFUser currentUser][@"profilePicture"] = profilePictureFile;
            [[PFUser currentUser] saveInBackground];
        }
    }];
    
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}




@end
