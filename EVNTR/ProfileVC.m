//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ProfileVC.h"
#import "SWRevealViewController.h"
#import "HomeScreenVC.h"
@import UIKit;

@interface ProfileVC ()

@property (nonatomic, strong) PFUser *userForProfileView;

@end

//CREATE A PROPERTY OF PFUSER AND PASS IN THE CURRENT USER... SO YOU DONT HAVE TO DO SO MANY CURRENTUSER CALLS.
//Add to make sure camera is available.
//if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//
//UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                      message:@"Device has no camera"
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles: nil];
//
//[myAlertView show];
//
//}

@implementation ProfileVC

@synthesize profileImageView, nameLabel, twitterLabel, instagramLabel, numberEventsLabel, numberFollowersLabel, numberFollowingLabel, userNameForProfileView, userForProfileView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    //TODO : Update for Allowing Viewing the Profile of Other Users.... pass in username of user to display?
    
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:userNameForProfileView];
    
    NSLog(@"Username: %@  Query Results: %@", userNameForProfileView, [usernameQuery findObjects]);
    userForProfileView = [[usernameQuery findObjects] firstObject];
    
    int profileType = 2;

    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        profileType = 1;
    } else {
        profileType = 2;
    }
    
    
    // 1 - current user --- 2 - username of another user.
    switch (profileType) {
        case 1: {
            NSLog(@"Type 1");
            break;
        }
        case 2: {
            NSLog(@"Type 2");
            self.navigationItem.leftItemsSupplementBackButton = YES;
            //self.navigationController.navigationBar
            break;
        }
        case 3: {
            //Add for sponsored profiles.
            break;
        }
        default:
            break;
    }
    
    
    
    //Populate Profile Page with Details from Parse
    PFFile *profilePictureFromParse = userForProfileView[@"profilePicture"];
    [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            self.profileImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    self.nameLabel.text = userForProfileView[@"username"];
    
    self.twitterLabel.text = userForProfileView[@"Twitter"];
    self.instagramLabel.text = [PFUser currentUser][@"Instagram"];
    
    self.numberEventsLabel.text = userForProfileView[@"Events_Created"];
    NSArray *numberOfFollowers = (NSArray *)userForProfileView[@"Followers"];
    NSArray *numberOfFollowing = (NSArray *)userForProfileView[@"Following"];
    
    self.numberFollowersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowers.count];
    
    self.numberFollowingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowing.count];
    
    
    //Setup Twitter and Instagram to Link to Profiles
    self.twitterLabel.userInteractionEnabled = YES;
    self.twitterLabel.tag = 1;
    UITapGestureRecognizer *twitterTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
    
    [self.twitterLabel addGestureRecognizer:twitterTapGesture];
    
    self.instagramLabel.userInteractionEnabled = YES;
    self.instagramLabel.tag = 2;
    UITapGestureRecognizer *instagramTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
    
    [self.instagramLabel addGestureRecognizer:instagramTapGesture];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Responds to the selection of a social media link and switches to the native app or web view.
- (void)socialMediaTap:(UITapGestureRecognizer *)tapgr {
    UILabel *tappedLabel = (UILabel *)tapgr.view;
    NSInteger tag = tappedLabel.tag;
    
    switch (tag) {
        case 1: {
            NSLog(@"Twitter");
            
            NSString *twitterNativeURLString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", self.twitterLabel.text];
            NSString *twitterWebURLString = [NSString stringWithFormat:@"https://twitter.com/%@", self.twitterLabel.text];
            
            if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterNativeURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterWebURLString]];
            }
            break;
        }
        case 2: {
            NSLog(@"Instagram");
            
            NSString *instagramNativeURLString = [NSString stringWithFormat:@"instagram://user?username=%@", self.instagramLabel.text];
            NSString *instagramWebURLString = [NSString stringWithFormat:@"https://instagram.com/%@", self.instagramLabel.text];
            
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramNativeURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramWebURLString]];
            }
            
            break;
        }
        default: {
            NSLog(@"Default - no social media case");
            break;
        }
    }
    
    

    

    
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
    
    [pictureOptionsMenu addAction:takePhoto];
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
    
    
}

- (IBAction)viewMyEvents:(id)sender {
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    // 1 - normal event view - 2 - user events
    eventVC.typeOfEventTableView = 2;
    
    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        eventVC.typeOfEventTableView = 3;
        eventVC.userForEventsQuery = [PFUser currentUser];
    } else {
        eventVC.typeOfEventTableView = 2;
        eventVC.userForEventsQuery = userForProfileView;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController addChildViewController:eventVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}


- (void) returnToProfile {
    
}


#pragma mark - Delegate Methods for UIImagePickerController

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
