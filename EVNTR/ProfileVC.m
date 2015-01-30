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
#import "PeopleVC.h"
#import "EVNConstants.h"

@interface ProfileVC ()

@property (nonatomic, strong) PFUser *userForProfileView;

@end

@implementation ProfileVC

@synthesize profileImageView, nameLabel, twitterLabel, instagramLabel, numberEventsLabel, numberFollowersLabel, numberFollowingLabel, userNameForProfileView, userForProfileView, followButton, setPictureButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Some Minor UI Adjustments
    self.navigationController.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillAppear:(BOOL)animated {
    
    //TODO - Change this.  Navigation Menu will set username to navigation
    //BUG - Click on my events in the profile.  Hamburger Menu Icon disappears.
    //Determine whether to show the Navigation Hamburger Menu Icon
    

    
    if ([userNameForProfileView isEqualToString:@"navigation"]) {
        
        SWRevealViewController *revealViewController = self.revealViewController;
        
        if (revealViewController) {
            [self.sidebarButton setTarget: self.revealViewController];
            [self.sidebarButton setAction: @selector(revealToggle:)];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
        
        userNameForProfileView = [PFUser currentUser][@"username"];
        
    } else {
        NSLog(@"Nil out the sidebarbutton");
        self.sidebarButton = nil;
        self.navigationItem.leftBarButtonItems = nil;
    }
    
    
    //Query Parse for the User.
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:userNameForProfileView];
    [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userForProfileView = (PFUser *)object;
        [self updateUIWithUser];

    }];
    
   }

- (void)updateUIWithUser {
    
    //Profile Types:
    //1 - Current User
    //2 - Another User
    //3 - Sponsored or VIP User
    int profileType;
    
    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        profileType = 1;
    } else {
        profileType = 2;
    }
    
    
    
    switch (profileType) {
        case CURRENT_USER_PROFILE: {
            //hide follow and set picture button
            followButton.hidden = YES;
            setPictureButton.hidden = NO;
            
            break;
        }
        case OTHER_USER_PROFILE: {
            //setup follow state and set picture button
            followButton.hidden = NO;
            setPictureButton.hidden = YES;
            
            NSLog(@"Other user profile");
            
            //determine whether the current user is following this other user
            PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
            [followActivity whereKey:@"from" equalTo:[PFUser currentUser]];
            [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [followActivity whereKey:@"to" equalTo:userForProfileView];
            [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                //TODO - Does this make sense?
                
                if (!objects || !objects.count) {
                    //followButton.titleLabel.text = @"Follow";
                    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                    NSLog(@"Changing String to Follow because objects: %@", objects);
                } else {
                    //followButton.titleLabel.text = @"Following";
                    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                    NSLog(@"Changing String to Following because objects: %@", objects);
                }
            }];
            
            break;
        }
        case SPONSORED_PROFILE: {
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
    self.twitterLabel.text = userForProfileView[@"twitterHandle"];
    self.instagramLabel.text = [PFUser currentUser][@"instagramHandle"];
    
    //TODO - self.numberEventsLabel.text = userForProfileView[@"Events_Created"];
    //NSArray *numberOfFollowers = (NSArray *)userForProfileView[@"followers"];
    //NSArray *numberOfFollowing = (NSArray *)userForProfileView[@"following"];
    
    //self.numberFollowersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowers.count];
    //self.numberFollowingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowing.count];
    
    
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




#pragma mark - ProfileActions  
//Taking a New Profile Picture - Accessing Events - Accessing Followers/Following

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
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
    
    
}

- (IBAction)viewMyEvents:(id)sender {
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    // 1 - normal event view - 2 - user events 3 - top user profile (keep navigation)
    //do i need to distinguish between my profile and another user's profile?
    eventVC.typeOfEventTableView = 2;
    
    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        eventVC.typeOfEventTableView = 2;
        eventVC.userForEventsQuery = [PFUser currentUser];
    } else {
        eventVC.typeOfEventTableView = 2;
        eventVC.userForEventsQuery = userForProfileView;
    }
    
    if (self.sidebarButton) {
        eventVC.typeOfEventTableView = 3;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController addChildViewController:eventVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)viewFollowers:(id)sender {
    
    PeopleVC *viewFollowersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowersVC.typeOfUsers = VIEW_FOLLOWERS;
    viewFollowersVC.profileUsername = userForProfileView;
    
    NSLog(@"Heading over to View this Profile's Followers:  %d and %@", viewFollowersVC.typeOfUsers, viewFollowersVC.profileUsername);
    
    [self.navigationController pushViewController:viewFollowersVC animated:YES];
    
    //[self presentViewController:viewFollowersVC animated:YES completion:nil];
    
}

- (IBAction)viewFollowing:(id)sender {
    
    PeopleVC *viewFollowingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowingVC.typeOfUsers = VIEW_FOLLOWING;
    viewFollowingVC.profileUsername = userForProfileView;
    
    [self.navigationController pushViewController:viewFollowingVC animated:YES];

    //[self presentViewController:viewFollowingVC animated:YES completion:nil];
    
    
}

- (IBAction)followUser:(id)sender {
    
    NSLog(@"Clicked Follow User");
    
    if ([followButton.titleLabel.text isEqualToString:@"Follow"]) {
        
        NSLog(@"Follow the User");
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        
        newFollowActivity[@"from"] = [PFUser currentUser];
        newFollowActivity[@"to"] = userForProfileView;
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            followButton.titleLabel.text = @"Following";
            
            if (succeeded) {
                NSLog(@"Saved");

            } else {
                NSLog(@"Error in Saved");

            }

        }];
        

        
    } else if ([followButton.titleLabel.text isEqualToString:@"Following"]) {
        
        NSLog(@"Unfollow the User");
        
        PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [findFollowActivity whereKey:@"from" equalTo:userForProfileView];
        
        [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *previousFollowActivity = [objects firstObject];
            [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"DELETED" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
            }];
            
        }];
        
        
        
    }
         
    
}


- (void) returnToProfile {

    
}

//Responds to the selection of a social media link and switches to the native app or web view.
- (void)socialMediaTap:(UITapGestureRecognizer *)tapgr {
    UILabel *tappedLabel = (UILabel *)tapgr.view;
    NSInteger tag = tappedLabel.tag;
    
    switch (tag) {
        case 1: {
            NSString *twitterNativeURLString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", self.twitterLabel.text];
            NSString *twitterWebURLString = [NSString stringWithFormat:@"https://twitter.com/%@", self.twitterLabel.text];
            
            if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterNativeURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterWebURLString]];
            }
            break;
        }
        case 2: {
            NSString *instagramNativeURLString = [NSString stringWithFormat:@"instagram://user?username=%@", self.instagramLabel.text];
            NSString *instagramWebURLString = [NSString stringWithFormat:@"https://instagram.com/%@", self.instagramLabel.text];
            
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramNativeURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramWebURLString]];
            }
            
            break;
        }
        default: {
            
            break;
        }
    }
    
}


#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.profileImageView.image = chosenPicture;

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



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




@end
