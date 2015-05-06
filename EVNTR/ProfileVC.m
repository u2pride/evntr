//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ActivityVC.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "EditProfileVC.h"
#import "HomeScreenVC.h"
#import "LogInVC.h"
#import "PeopleVC.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import "NSDate+NVTimeAgo.h"

#import <QuartzCore/QuartzCore.h>


@interface ProfileVC ()

@property (nonatomic, strong) EVNUser *userForProfileView;
@property (nonatomic) int profileType;
@property (nonatomic, strong) NSData *userPictureData;

//Structure Related Views
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItemWithSettingsBarItem;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundView;

//User Information
@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *instagramIcon;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (strong, nonatomic) IBOutlet UILabel *userHometownLabel;
@property (strong, nonatomic) IBOutlet UILabel *userSinceLabel;

//Buttons For Actions On Profile
@property (strong, nonatomic) IBOutlet EVNButton *followButton;
@property (strong, nonatomic) IBOutlet EVNButton *editProfileButton;



//Timer For Edit Profile Modal
@property (nonatomic) BOOL isDismissedAlreadyCancel;
@property (nonatomic) BOOL isDismissedAlreadyUpdate;

- (IBAction)followUser:(id)sender;
- (IBAction)viewMyEvents:(id)sender;
- (IBAction)viewFollowers:(id)sender;
- (IBAction)viewFollowing:(id)sender;


@end


@implementation ProfileVC

//TODO: note: this is called before you would programmatically set variables in prepareforsegue when creating this viewcontroller.
//ideally we pass in the user for this view, however some views will not have access to the full user... just the name.  For example, an attributed text label.
//instagram doesn't update the view if already in stack,

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //initial values
        self.userForProfileView = [EVNUser currentUser];
        self.userObjectID = [EVNUser currentUser].objectId;
        _isDismissedAlreadyCancel = NO;
        _isDismissedAlreadyUpdate = NO;
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Name Label Fits Text Dynamically
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    //Style Buttons
    self.followButton.buttonColor = [UIColor orangeThemeColor];
    self.followButton.font = [UIFont fontWithName:@"Lato-Regular" size:21];
    self.followButton.isRounded = YES;
    self.followButton.hasBorder = YES;
    
    self.editProfileButton.buttonColor = [UIColor orangeThemeColor];
    self.editProfileButton.font = [UIFont fontWithName:@"Lato-Regular" size:21];
    self.editProfileButton.isRounded = YES;
    self.editProfileButton.hasBorder = YES;
    self.editProfileButton.titleText = @"edit profile";
    
    
    //Setup the View
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.editProfileButton.hidden = YES;
    self.followButton.hidden  = YES;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // image respects tint color
    self.instagramIcon.image = [[UIImage imageNamed:@"instagram"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.twitterIcon.image = [[UIImage imageNamed:@"twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.editProfileButton.hidden = YES;
    self.followButton.hidden = YES;
    
    self.colorBackgroundView.backgroundColor = [UIColor orangeThemeColor];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    
    //navigationBar.barTintColor = [UIColor orangeThemeColor];
    //navigationBar.backgroundColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = NO;

    
    //self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.alpha = 0.5;
    //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    //self.navigationController.view.backgroundColor = [UIColor clearColor];

    
    //Update Font and Color of NavBar in Case of Moving Directly from Event Detail Page
    //[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:nil];
    
    /*
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    */

    
    
    //Navigation Bar Font & Color
    //NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    //self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
    //Query Parse for the User.
    PFQuery *usernameQuery = [EVNUser query];
    [usernameQuery whereKey:@"objectId" equalTo:self.userObjectID];
    [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.userForProfileView = (EVNUser *)object;
        
        self.userHometownLabel.text = self.userForProfileView.hometown;
        NSString *dateJoined = [self.userForProfileView.createdAt formattedAsTimeAgo];
        self.userSinceLabel.text = [NSString stringWithFormat:@"Joined %@", dateJoined];
        
        //Register to Know when New Follows Have Happened and Refresh Profile View with Database Values
        //TODO: Separate out what actually needs to be updated from database instead of updating all with updateUIWithUser
        // make sure to include follow status and following and followers counts.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIDueToNewFollow:) name:kFollowActivity object:nil];
        
        if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
            self.profileType = CURRENT_USER_PROFILE;
            
            //Register for Notifications when Current User Creates a New Event
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventCount) name:kEventCreated object:nil];
            
        } else {
            self.profileType = OTHER_USER_PROFILE;
            self.navigationItemWithSettingsBarItem.rightBarButtonItems = nil;
            
        }
        
        [self updateUIAll];
        
    }];
    
}



- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    //self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    //self.navigationController.navigationBar.translucent = NO;
    
}


- (void) updateUIAll {

    switch (self.profileType) {
        case CURRENT_USER_PROFILE: {

            self.followButton.hidden = YES;
            self.editProfileButton.hidden = NO;
            [self.editProfileButton addTarget:self action:@selector(editUserProfile) forControlEvents:UIControlEventTouchUpInside];
            
            self.title = @"Profile";
            self.navigationItem.title = [@"@" stringByAppendingString:self.userForProfileView.username];
            
            break;
        }
        case OTHER_USER_PROFILE: {
            

            //setup follow state and set picture button
            self.followButton.hidden = NO;
            self.editProfileButton.hidden = YES;
            
            self.navigationItem.title = [@"@" stringByAppendingString:self.userForProfileView.username];
            
            //Determine whether the current user is following this user
            PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
            [followActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
            [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [followActivity whereKey:@"to" equalTo:self.userForProfileView];
            [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                //TODO - Does this make sense?
                
                if (!objects || !objects.count) {
                    self.followButton.titleText = @"Follow";
                    
                } else {
                    self.followButton.titleText = @"Following";
                    self.followButton.isSelected = YES;
    
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
    
    
    //Profile Picture
    PFFile *profilePictureFromParse = self.userForProfileView[@"profilePicture"];
    self.profileImageView.file = profilePictureFromParse;
    [self.profileImageView loadInBackground:^(UIImage *image, NSError *error) {
        self.userPictureData = UIImagePNGRepresentation(image);
    }];
    
    
    //Use Username for Real Name if no Real Name Chosen Yet
    if (self.userForProfileView.realName) {
        self.nameLabel.text = self.userForProfileView.realName;
    } else {
        self.nameLabel.text = self.userForProfileView.username;
    }
    

    //If Social Media Handles Exist, Setup with Handles and Tap Gestures
    if (self.userForProfileView[@"twitterHandle"]) {
        
        self.twitterIcon.userInteractionEnabled = YES;
        self.twitterIcon.tag = 1;
        
        UITapGestureRecognizer *twitterTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
        
        [self.twitterIcon addGestureRecognizer:twitterTapGesture];
        
    }
    
    if (self.userForProfileView[@"instagramHandle"]) {
        
        self.instagramIcon.userInteractionEnabled = YES;
        self.instagramIcon.tag = 2;
        
        UITapGestureRecognizer *instagramTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialMediaTap:)];
        
        [self.instagramIcon addGestureRecognizer:instagramTapGesture];
        
    }

    
    //TODO - self.numberEventsLabel.text = userForProfileView[@"Events_Created"];
    
    PFQuery *countEventsQuery = [PFQuery queryWithClassName:@"Events"];
    [countEventsQuery whereKey:@"parent" equalTo:self.userForProfileView];
    [countEventsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
    PFQuery *countFollowersQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowersQuery whereKey:@"to" equalTo:self.userForProfileView];
    [countFollowersQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numberFollowersLabel.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
    PFQuery *countFollowingQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowingQuery whereKey:@"from" equalTo:self.userForProfileView];
    [countFollowingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", number];
        }
    }];
    
}




#pragma mark - ProfileActions

//TOOD: do i need to distinguish between my profile and another user's profile?
- (IBAction)viewMyEvents:(id)sender {
    
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
        NSLog(@"Current user events from profile page");
        eventVC.typeOfEventTableView = CURRENT_USER_EVENTS;
        eventVC.userForEventsQuery = [EVNUser currentUser];
    } else {
        NSLog(@"Other user events from profile page");
        eventVC.typeOfEventTableView = OTHER_USER_EVENTS;
        eventVC.userForEventsQuery = self.userForProfileView;
    }
    
    [self.navigationController pushViewController:eventVC animated:YES];

}

- (IBAction)viewFollowers:(id)sender {
    
    PeopleVC *viewFollowersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowersVC.typeOfUsers = VIEW_FOLLOWERS;
    viewFollowersVC.userProfile = self.userForProfileView;
    
    [self.navigationController pushViewController:viewFollowersVC animated:YES];
    
}

- (IBAction)viewFollowing:(id)sender {
    
    PeopleVC *viewFollowingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowingVC.typeOfUsers = VIEW_FOLLOWING;
    viewFollowingVC.userProfile = self.userForProfileView;
    
    [self.navigationController pushViewController:viewFollowingVC animated:YES];
    
}

- (IBAction)viewPendingAccessRequests:(id)sender {
    
    ActivityVC *viewPendingRequests = [self.storyboard instantiateViewControllerWithIdentifier:@"activityViewController"];
    
    viewPendingRequests.typeOfActivityView = ACTIVITIES_REQUESTS_TO_ME;
    viewPendingRequests.userForActivities = [EVNUser currentUser];
    
    [self.navigationController pushViewController:viewPendingRequests animated:YES];

}


- (IBAction)viewEventsAttending:(id)sender {
    
    ActivityVC *eventsAttended = (ActivityVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"activityViewController"];
    eventsAttended.typeOfActivityView = ACTIVITIES_ATTENDED;
    eventsAttended.userForActivities = self.userForProfileView;
    eventsAttended.title = @"Events Attended";
    
    [self.navigationController pushViewController:eventsAttended animated:YES];
    
}

- (IBAction)viewInvites:(id)sender {
    
    ActivityVC *inviteActivity = (ActivityVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"activityViewController"];
    inviteActivity.typeOfActivityView = ACTIVITIES_INVITES;
    inviteActivity.title = @"Invites";
    
    [self.navigationController pushViewController:inviteActivity animated:YES];
    
    
}

- (IBAction)viewMyRequestStatus:(id)sender {
    
    ActivityVC *viewMyRequests = [self.storyboard instantiateViewControllerWithIdentifier:@"activityViewController"];
    
    viewMyRequests.typeOfActivityView = ACTIVITIES_MY_REQUESTS_STATUS;
    viewMyRequests.userForActivities = [EVNUser currentUser];
    
    [self.navigationController pushViewController:viewMyRequests animated:YES];
    
}




#pragma mark - Follow User


- (IBAction)followUser:(id)sender {
    
    self.followButton.enabled = NO;
    [self.followButton startedTask];
    
    if ([self.followButton.titleText isEqualToString:@"Follow"]) {
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        newFollowActivity[@"from"] = [EVNUser currentUser];
        newFollowActivity[@"to"] = self.userForProfileView;
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                self.followButton.titleText = @"Following";

                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                
            } else {
                NSLog(@"Error in Saved");
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Report This Error to aryan@evntr.co" message:error.description delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                [errorAlert show];

            }
            
            self.followButton.enabled = YES;
            [self.followButton endedTask];
        }];
        
        
    } else if ([self.followButton.titleText isEqualToString:@"Following"]) {
                
        UIAlertController *unfollowSheet = [UIAlertController alertControllerWithTitle:self.userForProfileView.username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *unfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
            
            [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [findFollowActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
            [findFollowActivity whereKey:@"to" equalTo:self.userForProfileView];
            
            [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFObject *previousFollowActivity = [objects firstObject];
                [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        self.followButton.titleText = @"Follow";
                        
                        //Notify View Controllers of a New Follow
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                    } else {
                        
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Report This Error to aryan@evntr.co" message:error.description delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                        
                        [errorAlert show];
                        
                    }
                    
                    self.followButton.enabled = YES;
                    [self.followButton endedTask];
                    
                }];
            }];

            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            self.followButton.enabled = YES;
            [self.followButton endedTask];
            
        }];
        
        
        [unfollowSheet addAction:unfollow];
        [unfollowSheet addAction:cancelAction];
                
        [self presentViewController:unfollowSheet animated:YES completion:nil];
        
                
    } else {
        NSLog(@"Weird error - need to notify user");
        self.followButton.enabled = YES;
        [self.followButton endedTask];
    }
    
}


#pragma mark - Social Media Actions

- (void)socialMediaTap:(UITapGestureRecognizer *)tapgr {
    UIImageView *tappedImageView = (UIImageView *)tapgr.view;
    NSInteger tag = tappedImageView.tag;
    
    switch (tag) {
        case 1: {
            NSString *twitterNativeURLString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", self.userForProfileView[@"twitterHandle"]];
            NSString *twitterWebURLString = [NSString stringWithFormat:@"https://twitter.com/%@", self.userForProfileView[@"twitterHandle"]];
            
            if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterNativeURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterWebURLString]];
            }
            break;
        }
        case 2: {
            NSString *instagramNativeURLString = [NSString stringWithFormat:@"instagram://user?username=%@", self.userForProfileView[@"instagramHandle"]];
            NSString *instagramWebURLString = [NSString stringWithFormat:@"https://instagram.com/%@", self.userForProfileView[@"instagramHandle"]];
            
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
    
    NSLog(@"cancel - self.isDismissedAlready: %@", [NSNumber numberWithBool: self.isDismissedAlreadyCancel]);
    
    if (!self.isDismissedAlreadyCancel) {
        
        self.isDismissedAlreadyCancel = YES;
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            NSLog(@"completion - self.isDismissedAlready: %@", [NSNumber numberWithBool:self.isDismissedAlreadyCancel]);
            self.isDismissedAlreadyCancel = NO;
            
        }];

    }
    
}


-(void)saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData {

    NSLog(@"cancel2 - self.isDismissedAlready: %@", [NSNumber numberWithBool: self.isDismissedAlreadyCancel]);
    
    if (!self.isDismissedAlreadyCancel) {
        
        self.isDismissedAlreadyCancel = YES;
        
        
        PFFile *newProfilePicture = [PFFile fileWithData:imageData];
        [newProfilePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            
        }];
        
        //NSString *username = [stringDictionary objectForKey:@"username"];
        NSString *realName = [stringDictionary objectForKey:@"realName"];
        //NSString *hometown = [stringDictionary objectForKey:@"hometown"];
        //NSString *bio = [stringDictionary objectForKey:@"bio"];
        
        self.profileImageView.image = [UIImage imageWithData:imageData];
        
        self.nameLabel.text = realName;
        
        self.userObjectID = [EVNUser currentUser].objectId;
        self.userForProfileView = [EVNUser currentUser];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            NSLog(@"completion2 - self.isDismissedAlready: %@", [NSNumber numberWithBool:self.isDismissedAlreadyCancel]);
            self.isDismissedAlreadyCancel = NO;
            
        }];
        
    }
    
    

    
}






#pragma mark - Responding to Notifications - Updating UI

- (void) updateEventCount {
    
    self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", [self.numberEventsLabel.text intValue] + 1 ];
    
}

- (void) incrementFollowing {
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    NSNumber *followingCount = [numFormat numberFromString:self.numberFollowingLabel.text];
    followingCount = [NSNumber numberWithInt:[followingCount intValue] + 1];
    
    self.numberFollowingLabel.text = [numFormat stringFromNumber:followingCount];
    
}


- (void) decrementFollowing {
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    NSNumber *followingCount = [numFormat numberFromString:self.numberFollowingLabel.text];
    followingCount = [NSNumber numberWithInt:[followingCount intValue] - 1];
    
    self.numberFollowingLabel.text = [numFormat stringFromNumber:followingCount];
    
}

//TODO - Perform this updates in the local cache - or just increment/decrement the right count.
- (void)updateUIDueToNewFollow:(NSNotification *)notification {
    
    if (self.profileType != CURRENT_USER_PROFILE) {
        
        //Update the Button For Following/Follow
        PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
        [followActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
        [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [followActivity whereKey:@"to" equalTo:self.userForProfileView];
        [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //TODO - Does this make sense?
            
            if (!objects || !objects.count) {
                self.followButton.titleText = @"Follow";
            } else {
                self.followButton.titleText = @"Following";
            }
        }];
    }
    
    //Update Following / Followers Counts
    PFQuery *countFollowersQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowersQuery whereKey:@"to" equalTo:self.userForProfileView];
    [countFollowersQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberFollowersLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
    PFQuery *countFollowingQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowingQuery whereKey:@"from" equalTo:self.userForProfileView];
    [countFollowingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
}

#pragma mark - Navigation


- (void) editUserProfile {
    
    [self performSegueWithIdentifier:@"profileToEditProfile" sender:nil];
    
}


// Remember that at this point the view hasn't loaded.... so you can't set UI element properties.
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([[segue identifier] isEqualToString:@"profileToEditProfile"]) {
     
         UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
         EditProfileVC *editProfileView = (EditProfileVC *)[[navController childViewControllers] lastObject];
         
         EVNUser *currentUser = [EVNUser currentUser];

         editProfileView.username = currentUser[@"username"];
         editProfileView.realName = currentUser[@"realName"];
         editProfileView.hometown = currentUser[@"hometown"];
         editProfileView.bio = currentUser[@"bio"];
         editProfileView.pictureData = self.userPictureData;
         editProfileView.delegate = self;
         
     }
     
 }



@end
