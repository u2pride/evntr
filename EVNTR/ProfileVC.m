//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ActivityVC.h"
#import "EVNConstants.h"
#import "EVNUtility.h"
#import "EditProfileVC.h"
#import "HomeScreenVC.h"
#import "LogInVC.h"
#import "PeopleVC.h"
#import "ProfileVC.h"


@interface ProfileVC ()

@property (nonatomic, strong) PFUser *userForProfileView;
@property (nonatomic) int profileType;
@property (nonatomic, strong) NSData *userPictureData;

//Structure Related Views
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItemWithSettingsBarItem;

//User Information
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *twitterLabel;
@property (strong, nonatomic) IBOutlet UILabel *instagramLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *instagramIcon;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;

//Buttons For Actions On Profile
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *viewEventsAttendedButton;
@property (weak, nonatomic) IBOutlet UIButton *viewInvitesButton;
@property (weak, nonatomic) IBOutlet UIButton *viewAccessRequestsForMyEventsButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMyAccessRequestsButton;


- (IBAction)followUser:(id)sender;
- (IBAction)viewEventsAttending:(id)sender;
- (IBAction)viewInvites:(id)sender;
- (IBAction)viewMyRequestStatus:(id)sender;
- (IBAction)viewMyEvents:(id)sender;
- (IBAction)viewFollowers:(id)sender;
- (IBAction)viewFollowing:(id)sender;
- (IBAction)viewPendingAccessRequests:(id)sender;


@end


@implementation ProfileVC

//TODO: note: this is called before you would programmatically set variables in prepareforsegue when creating this viewcontroller.
//ideally we pass in the user for this view, however some views will not have access to the full user... just the name.  For example, an attributed text label.
//instagram doesn't update the view if already in stack,

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //initial values
        self.userForProfileView = [PFUser currentUser];
        self.userNameForProfileView = [PFUser currentUser][@"username"];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];

    
    //Setup the View
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.twitterLabel.text = nil;
    self.instagramLabel.text = nil;
    self.editProfileButton.hidden = YES;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // image respects tint color
    self.instagramIcon.image = [[UIImage imageNamed:@"instagram"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.twitterIcon.image = [[UIImage imageNamed:@"twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Query Parse for the User.
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:self.userNameForProfileView];
    [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.userForProfileView = (PFUser *)object;
        
        //Register to Know when New Follows Have Happened and Refresh Profile View with Database Values
        //TODO: Separate out what actually needs to be updated from database instead of updating all with updateUIWithUser
        // make sure to include follow status and following and followers counts.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIDueToNewFollow:) name:kFollowActivity object:nil];
        
        if ([self.userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
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



- (void) updateUIAll {

    switch (self.profileType) {
        case CURRENT_USER_PROFILE: {

            self.followButton.hidden = YES;
            self.editProfileButton.hidden = NO;
            self.title = @"Profile";
            
            break;
        }
        case OTHER_USER_PROFILE: {
            
            //setup follow state and set picture button
            self.followButton.hidden = NO;
            self.editProfileButton.hidden = YES;
            
            self.title = self.userForProfileView[@"username"];
            
            //Determine whether the current user is following this user
            PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
            [followActivity whereKey:@"from" equalTo:[PFUser currentUser]];
            [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [followActivity whereKey:@"to" equalTo:self.userForProfileView];
            [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                //TODO - Does this make sense?
                
                if (!objects || !objects.count) {
                    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                } else {
                    [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                }
            }];
            
            //Hide Buttons
            self.viewAccessRequestsForMyEventsButton.hidden = YES;
            self.viewMyAccessRequestsButton.hidden = YES;
            self.viewInvitesButton.hidden = YES;
            
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
    [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            self.userPictureData = data;
            self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskImageSelected"]];
        }
    }];
    
    
    self.nameLabel.text = self.userForProfileView[@"username"];

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
        self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", number];
    }];
    
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




#pragma mark - ProfileActions

//TOOD: do i need to distinguish between my profile and another user's profile?
- (IBAction)viewMyEvents:(id)sender {
    
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    if ([self.userNameForProfileView isEqualToString:[PFUser currentUser][@"username"]]) {
        NSLog(@"Current user events from profile page");
        eventVC.typeOfEventTableView = CURRENT_USER_EVENTS;
        eventVC.userForEventsQuery = [PFUser currentUser];
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
    viewFollowersVC.profileUsername = self.userForProfileView;
    
    [self.navigationController pushViewController:viewFollowersVC animated:YES];
    
}

- (IBAction)viewFollowing:(id)sender {
    
    PeopleVC *viewFollowingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowingVC.typeOfUsers = VIEW_FOLLOWING;
    viewFollowingVC.profileUsername = self.userForProfileView;
    
    [self.navigationController pushViewController:viewFollowingVC animated:YES];
    
}

- (IBAction)viewPendingAccessRequests:(id)sender {
    
    ActivityVC *viewPendingRequests = [self.storyboard instantiateViewControllerWithIdentifier:@"activityViewController"];
    
    viewPendingRequests.typeOfActivityView = ACTIVITIES_REQUESTS_TO_ME;
    viewPendingRequests.userForActivities = [PFUser currentUser];
    
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
    viewMyRequests.userForActivities = [PFUser currentUser];
    
    [self.navigationController pushViewController:viewMyRequests animated:YES];
    
}




#pragma mark - Follow User

- (IBAction)followUser:(id)sender {
    
    self.followButton.enabled = NO;
    
    if ([self.followButton.titleLabel.text isEqualToString:@"Follow"]) {
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        newFollowActivity[@"from"] = [PFUser currentUser];
        newFollowActivity[@"to"] = self.userForProfileView;
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (succeeded) {
                
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];

            } else {
                NSLog(@"Error in Saved");
            }
            
            self.followButton.enabled = YES;

        }];
        

        
    } else if ([self.followButton.titleLabel.text isEqualToString:@"Following"]) {
        
        PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [findFollowActivity whereKey:@"from" equalTo:[PFUser currentUser]];
        [findFollowActivity whereKey:@"to" equalTo:self.userForProfileView];
        
        [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *previousFollowActivity = [objects firstObject];
            [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                //Notify View Controllers of a New Follow
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                
                [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];

                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"DELETED" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                
                self.followButton.enabled = YES;
            }];
            
        }];
        
        
        
    } else {
        NSLog(@"Weird error - need to notify user");
        self.followButton.enabled = YES;
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData {

    PFFile *newProfilePicture = [PFFile fileWithData:imageData];
    [newProfilePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        
    }];
    
    NSString *username = [stringDictionary objectForKey:@"username"];
    //NSString *realName = [stringDictionary objectForKey:@"realName"];
    //NSString *hometown = [stringDictionary objectForKey:@"hometown"];
    //NSString *bio = [stringDictionary objectForKey:@"bio"];
    
    self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:imageData] withMask:[UIImage imageNamed:@"MaskImageSelected"]];
    self.nameLabel.text = username;

    self.userNameForProfileView = username;
    self.userForProfileView = [PFUser currentUser];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
        [followActivity whereKey:@"from" equalTo:[PFUser currentUser]];
        [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [followActivity whereKey:@"to" equalTo:self.userForProfileView];
        [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //TODO - Does this make sense?
            
            if (!objects || !objects.count) {
                [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            } else {
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
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
 
// Remember that at this point the view hasn't loaded.... so you can't set UI element properties.
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([[segue identifier] isEqualToString:@"profileToEditProfile"]) {
     
         UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
         EditProfileVC *editProfileView = (EditProfileVC *)[[navController childViewControllers] lastObject];
         
         PFUser *currentUser = [PFUser currentUser];

         editProfileView.username = currentUser[@"username"];
         editProfileView.realName = currentUser[@"realName"];
         editProfileView.hometown = currentUser[@"hometown"];
         editProfileView.bio = currentUser[@"bio"];
         editProfileView.pictureData = self.userPictureData;
         editProfileView.delegate = self;
         
     }
     
 }



@end
