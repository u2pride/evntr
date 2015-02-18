//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNUtility.h"
#import "EditProfileVC.h"
#import "HomeScreenVC.h"
#import "LogInVC.h"
#import "PeopleVC.h"
#import "ProfileVC.h"
#import "SWRevealViewController.h"

@interface ProfileVC ()
{
    
    NSData *userPictureData;
}

@property (nonatomic, strong) PFUser *userForProfileView;

@end

@implementation ProfileVC

@synthesize profileImageView, nameLabel, twitterLabel, instagramLabel, numberEventsLabel, numberFollowersLabel, numberFollowingLabel, userNameForProfileView, userForProfileView, followButton, setPictureButton, isComingFromNavigation, isComingFromEditProfile;


- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.isComingFromNavigation = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        label.textAlignment = NSTextAlignmentCenter;
        // ^-Use UITextAlignmentCenter for older SDKs.
        label.textColor = [UIColor whiteColor]; // change this color
        self.navigationItem.titleView = label;
        label.text = @"Profile";
        [label sizeToFit];
        
        self.isComingFromEditProfile = NO;        

    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Some Minor UI Adjustments
    //self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.center = self.view.center;
    [self.view addSubview:self.loadingSpinner];
    [self.loadingSpinner startAnimating];
    
    //When presented from Navigation - Keep the Side Reveal Menu Icon in the Top Left
    if (self.isComingFromNavigation) {
        SWRevealViewController *revealViewController = self.revealViewController;
        
        if (revealViewController) {
            [self.sidebarButton setTarget: self.revealViewController];
            [self.sidebarButton setAction: @selector(revealToggle:)];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    } else {
        self.sidebarButton = nil;
        self.navigationItem.leftBarButtonItems = nil;
    }
    
    //Setup the View
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.twitterLabel.text = nil;
    self.instagramLabel.text = nil;
    
    //Update Nav Bar
    //self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    //self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    //ideally we pass in the user for this view, however some views will not have access to the full user... just the name.  For example, an attributed text label.
    //instagram doesn't update the view if already in stack,
    
    //Updates From Edit Screen are Already Populated
    //if (!isComingFromEditProfile) {
        
        //Query Parse for the User.
        PFQuery *usernameQuery = [PFUser query];
        [usernameQuery whereKey:@"username" equalTo:userNameForProfileView];
        [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            userForProfileView = (PFUser *)object;
            [self updateUIWithUser];
            
        }];
        
    //}
}



//After User is Fetched From Parse - Update the UI
- (void)updateUIWithUser {

    int profileType;
    
    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        profileType = CURRENT_USER_PROFILE;
    } else {
        profileType = OTHER_USER_PROFILE;
    }
    
    switch (profileType) {
        case CURRENT_USER_PROFILE: {
            //hide follow and set picture button
            followButton.hidden = YES;
            setPictureButton.hidden = NO;
            
            self.title = @"My Profile";
            
            break;
        }
        case OTHER_USER_PROFILE: {
            //setup follow state and set picture button
            followButton.hidden = NO;
            setPictureButton.hidden = YES;
            
            self.title = userForProfileView[@"username"];
            
            //Determine whether the current user is following this user
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
            userPictureData = data;
            self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskImage"]];
        }
    }];
    
    
    self.nameLabel.text = userForProfileView[@"username"];

    //If Social Media Handles Exist, Setup with Handles and Tap Gestures
    if (userForProfileView[@"twitterHandle"]) {
        self.twitterLabel.text = userForProfileView[@"twitterHandle"];
        
        self.twitterLabel.userInteractionEnabled = YES;
        self.twitterLabel.tag = 1;
        UITapGestureRecognizer *twitterTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
        
        [self.twitterLabel addGestureRecognizer:twitterTapGesture];
    } else {
        self.twitterLabel.text = @"Not Connected";
    }
    
    if (userForProfileView[@"instagramHandle"]) {
        self.instagramLabel.text = userForProfileView[@"instagramHandle"];
        
        self.instagramLabel.userInteractionEnabled = YES;
        self.instagramLabel.tag = 2;
        UITapGestureRecognizer *instagramTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
        
        [self.instagramLabel addGestureRecognizer:instagramTapGesture];
        
    } else {
        self.instagramLabel.text = @"Not Connected";
    }
    
    [self.loadingSpinner stopAnimating];

    
    //Query the Activity Table.
    
    //TODO - self.numberEventsLabel.text = userForProfileView[@"Events_Created"];
    //NSArray *numberOfFollowers = (NSArray *)userForProfileView[@"followers"];
    //NSArray *numberOfFollowing = (NSArray *)userForProfileView[@"following"];
    
    //self.numberFollowersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowers.count];
    //self.numberFollowingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)numberOfFollowing.count];

    
    PFQuery *countEventsQuery = [PFQuery queryWithClassName:@"Events"];
    [countEventsQuery whereKey:@"parent" equalTo:userForProfileView];
    [countEventsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
    PFQuery *countFollowersQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowersQuery whereKey:@"to" equalTo:userForProfileView];
    [countFollowersQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberFollowersLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
    PFQuery *countFollowingQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowingQuery whereKey:@"from" equalTo:userForProfileView];
    [countFollowingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - ProfileActions

- (IBAction)viewMyEvents:(id)sender {
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    // 1 - normal event view - 2 - user events 3 - top user profile (keep navigation)
    //do i need to distinguish between my profile and another user's profile?
    //eventVC.typeOfEventTableView = 2;
    
    if ([userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        NSLog(@"Current user events from profile page");
        eventVC.typeOfEventTableView = CURRENT_USER_EVENTS;
        eventVC.userForEventsQuery = [PFUser currentUser];
    } else {
        NSLog(@"Other user events from profile page");
        eventVC.typeOfEventTableView = OTHER_USER_EVENTS;
        eventVC.userForEventsQuery = userForProfileView;
    }
    
    //What is this for? - need to set userNameForProfileView in navigation controller.
    //if (self.sidebarButton) {
    //    eventVC.typeOfEventTableView = CURRENT_USER_EVENTS;
    //}
    
    [self.navigationController pushViewController:eventVC animated:YES];
    
    //UINavigationController *navigationController = [[UINavigationController alloc] init];
    //[navigationController addChildViewController:eventVC];
    
    //[self presentViewController:navigationController animated:YES completion:nil];
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
        
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        newFollowActivity[@"from"] = [PFUser currentUser];
        newFollowActivity[@"to"] = userForProfileView;
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (succeeded) {
                NSLog(@"Saved");
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];


            } else {
                NSLog(@"Error in Saved");

            }

        }];
        

        
    } else if ([followButton.titleLabel.text isEqualToString:@"Following"]) {
        
        NSLog(@"Unfollow the User");
        
        PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [findFollowActivity whereKey:@"from" equalTo:[PFUser currentUser]];
        [findFollowActivity whereKey:@"to" equalTo:userForProfileView];
        
        [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSLog(@"Objects Found: %@", objects);
            
            PFObject *previousFollowActivity = [objects firstObject];
            [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Inside the delete part");
                
                [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];

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






#pragma mark - ProfileEditDelegate Methods

- (void)canceledEditingProfile {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData {

    
    NSString *username = [stringDictionary objectForKey:@"username"];
    //NSString *realName = [stringDictionary objectForKey:@"realName"];
    //NSString *hometown = [stringDictionary objectForKey:@"hometown"];
    //NSString *bio = [stringDictionary objectForKey:@"bio"];
    
    self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:imageData] withMask:[UIImage imageNamed:@"MaskImage"]];
    self.nameLabel.text = username;

    self.isComingFromEditProfile = YES;
    self.userNameForProfileView = username;
    self.userForProfileView = [PFUser currentUser];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
// Remember that at this point the view hasn't loaded.... so you can't set UI element properties.
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([[segue identifier] isEqualToString:@"profileToEditProfile"]) {
     
         UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
         EditProfileVC *editProfileView = (EditProfileVC *)[[navController childViewControllers] lastObject];
         
         PFUser *currentUser = [PFUser currentUser];
         NSLog(@"PFUSER on PROFILE SIDE: %@", currentUser);

         editProfileView.username = currentUser[@"username"];
         editProfileView.realName = currentUser[@"realName"];
         editProfileView.hometown = currentUser[@"hometown"];
         editProfileView.bio = currentUser[@"bio"];
         editProfileView.pictureData = userPictureData;
         editProfileView.delegate = self;
         
     }
     
 }





@end
