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
#import "NSDate+NVTimeAgo.h"
#import "PeopleVC.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import <QuartzCore/QuartzCore.h>


@interface ProfileVC ()

@property (nonatomic, strong) EVNUser *profileUser;
@property (nonatomic) int profileType;

//Structure Related Views
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundView;

//User Information
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *eventsHeaderButton;
@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UIButton *followersHeaderButton;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingHeaderButton;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *instagramIcon;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIcon;
@property (strong, nonatomic) IBOutlet UILabel *userHometownLabel;
@property (strong, nonatomic) IBOutlet UILabel *userSinceLabel;

//Buttons For Actions On Profile
@property (strong, nonatomic) IBOutlet EVNButton *followButton;
@property (strong, nonatomic) IBOutlet EVNButton *editProfileButton;


- (IBAction)followUser:(id)sender;

@end


@implementation ProfileVC

//TODO: note: this is called before you would programmatically set variables in prepareforsegue when creating this viewcontroller.
//ideally we pass in the user for this view, however some views will not have access to the full user... just the name.  For example, an attributed text label.
//instagram doesn't update the view if already in stack,

#pragma mark - View Controller Lifecycle

- (id)initWithCoder:(NSCoder*)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _profileUser = [EVNUser currentUser];
        _userObjectID = [EVNUser currentUser].objectId;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.colorBackgroundView.backgroundColor = [UIColor orangeThemeColor];

    [self setupButtons];
    [self wireUpTapRecognizers];
    
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = NO;
    
    
    PFQuery *usernameQuery = [EVNUser query];
    [usernameQuery whereKey:@"objectId" equalTo:self.userObjectID];
    [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            self.profileUser = (EVNUser *)object;
            
            self.userHometownLabel.text = [self.profileUser hometownText];
            self.userSinceLabel.text = [NSString stringWithFormat:@"Joined %@", [self.profileUser.createdAt formattedAsTimeAgo]];
            
            if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
                self.profileType = CURRENT_USER_PROFILE;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventCount) name:kEventCreated object:nil];
            } else {
                self.profileType = OTHER_USER_PROFILE;
                self.navigationItem.rightBarButtonItems = nil;
            }
            
            //Register to Know when New Follows Have Happened and Refresh Profile View with Database Values
            //TODO: Separate out what actually needs to be updated from database instead of updating all with updateUIWithUser
            // make sure to include follow status and following and followers counts.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIDueToNewFollow:) name:kFollowActivity object:nil];
            
            [self updateUIAll];
            
            
        } else {
            
            self.navigationItem.rightBarButtonItems = nil;
            self.eventsHeaderButton.hidden = YES;
            self.followingHeaderButton.hidden = YES;
            self.followersHeaderButton.hidden = YES;
            self.numberEventsLabel.hidden = YES;
            self.numberFollowingLabel.hidden = YES;
            self.numberFollowersLabel.hidden = YES;
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"User Missing" message:@"Looks like we can't find this user.  But don't worry!  We'll start a search party for them." delegate:self cancelButtonTitle:@"Phew" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
    }];
    
}



- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}


#pragma mark - Helper Methods for VC Lifecycle

- (void) setupButtons {
    
    self.followButton.buttonColor = [UIColor orangeThemeColor];
    self.followButton.font = [UIFont fontWithName:@"Lato-Regular" size:21];
    self.followButton.isRounded = YES;
    self.followButton.hasBorder = YES;
    
    self.editProfileButton.buttonColor = [UIColor orangeThemeColor];
    self.editProfileButton.font = [UIFont fontWithName:@"Lato-Regular" size:21];
    self.editProfileButton.isRounded = YES;
    self.editProfileButton.hasBorder = YES;
    self.editProfileButton.titleText = @"edit profile";
    self.editProfileButton.isSelected = YES;
    self.editProfileButton.isStateless = YES;
    
    self.editProfileButton.hidden = YES;
    self.followButton.hidden = YES;
    
}


- (void) wireUpTapRecognizers {
    
    UITapGestureRecognizer *viewEvents = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEvents)];
    UITapGestureRecognizer *viewFollowing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewFollowing)];
    UITapGestureRecognizer *viewFollowers = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewFollowers)];
    
    [self.eventsHeaderButton addTarget:self action:@selector(viewEvents) forControlEvents:UIControlEventTouchUpInside];
    
    [self.followingHeaderButton addTarget:self action:@selector(viewFollowing) forControlEvents:UIControlEventTouchUpInside];
    
    [self.followersHeaderButton addTarget:self action:@selector(viewFollowers) forControlEvents:UIControlEventTouchUpInside];
    
    self.numberEventsLabel.userInteractionEnabled = YES;
    self.numberFollowingLabel.userInteractionEnabled = YES;
    self.numberFollowersLabel.userInteractionEnabled = YES;
    
    [self.numberEventsLabel addGestureRecognizer:viewEvents];
    [self.numberFollowingLabel addGestureRecognizer:viewFollowing];
    [self.numberFollowersLabel addGestureRecognizer:viewFollowers];
    
}

- (void) updateUIAll {

    switch (self.profileType) {
        case CURRENT_USER_PROFILE: {

            self.followButton.hidden = YES;
            self.editProfileButton.hidden = NO;
            [self.editProfileButton addTarget:self action:@selector(editUserProfile) forControlEvents:UIControlEventTouchUpInside];
            
            self.title = @"Profile";
            self.navigationItem.title = [@"@" stringByAppendingString:self.profileUser.username];
            
            break;
        }
        case OTHER_USER_PROFILE: {
            
            self.followButton.hidden = NO;
            self.editProfileButton.hidden = YES;
            
            self.navigationItem.title = [@"@" stringByAppendingString:self.profileUser.username];
            
            [[EVNUser currentUser] isCurrentUserFollowingProfile:self.profileUser completion:^(BOOL isFollowing, BOOL success) {
                
                if (success) {
                    if (isFollowing) {
                        self.followButton.titleText = @"Following";
                        self.followButton.isSelected = YES;
                    } else {
                        self.followButton.titleText = @"Follow";
                    }
                } else {
                    self.followButton.titleText = @"";
                    self.followButton.enabled = NO;
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
    
    
    self.nameLabel.text = [self.profileUser nameText];
    self.bioLabel.text = [self.profileUser bioText];
    
    
    PFFile *profilePictureFromParse = self.profileUser[@"profilePicture"];
    self.profileImageView.file = profilePictureFromParse;
    [self.profileImageView loadInBackground];

    [self.profileUser numberOfEventsWithCompletion:^(int events) {
        self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", events];
    }];
    
    //Update Following / Followers Counts
    [self.profileUser numberOfFollowersWithCompletion:^(int followers) {
        self.numberFollowersLabel.text = [NSString stringWithFormat:@"%d", followers];
    }];
    
    [self.profileUser numberOfFollowingWithCompletion:^(int following) {
        self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", following];
    }];
    

    
}




#pragma mark - ProfileActions

- (void) viewEvents {
    
    HomeScreenVC *eventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
        eventVC.typeOfEventTableView = CURRENT_USER_EVENTS;
        eventVC.userForEventsQuery = [EVNUser currentUser];
    } else {
        eventVC.typeOfEventTableView = OTHER_USER_EVENTS;
        eventVC.userForEventsQuery = self.profileUser;
    }
    
    [self.navigationController pushViewController:eventVC animated:YES];

}

- (void) viewFollowers {
    
    PeopleVC *viewFollowersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowersVC.typeOfUsers = VIEW_FOLLOWERS;
    viewFollowersVC.userProfile = self.profileUser;
    
    [self.navigationController pushViewController:viewFollowersVC animated:YES];
    
}

- (void) viewFollowing {
    
    PeopleVC *viewFollowingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowingVC.typeOfUsers = VIEW_FOLLOWING;
    viewFollowingVC.userProfile = self.profileUser;
    
    [self.navigationController pushViewController:viewFollowingVC animated:YES];
    
}




#pragma mark - Follow User

- (IBAction)followUser:(id)sender {

    [[EVNUser currentUser] followUser:self.profileUser fromVC:self withButton:self.followButton withCompletion:^(BOOL success) { }];
    
}



#pragma mark - ProfileEditDelegate Methods

- (void)canceledEditingProfile {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


-(void)saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData {
    
    NSString *realName = [stringDictionary objectForKey:@"realName"];
    
    self.profileImageView.image = [UIImage imageWithData:imageData];
    self.nameLabel.text = realName;
    self.userObjectID = [EVNUser currentUser].objectId;
    self.profileUser = [EVNUser currentUser];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Responding to Notifications - Updating UI

- (void) updateEventCount {
    
    self.numberEventsLabel.text = [NSString stringWithFormat:@"%d", [self.numberEventsLabel.text intValue] + 1];
    
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

//TODO - Perform this updates in the local cache - or just increment/decrement the right count.  Careful.
- (void)updateUIDueToNewFollow:(NSNotification *)notification {
    
    if (notification.object != self && self.profileType != CURRENT_USER_PROFILE) {
        
        [[EVNUser currentUser] isCurrentUserFollowingProfile:self.profileUser completion:^(BOOL isFollowing, BOOL success) {
            
            if (success) {
                if (isFollowing) {
                    self.followButton.titleText = @"Following";
                    self.followButton.isSelected = YES;
                } else {
                    self.followButton.titleText = @"Follow";
                }
            } else {
                self.followButton.titleText = @"";
                self.followButton.enabled = NO;
            }
        }];
        
    }
    
    //Update Following / Followers Counts
    [self.profileUser numberOfFollowersWithCompletion:^(int followers) {
        self.numberFollowersLabel.text = [NSString stringWithFormat:@"%d", followers];
    }];
    
    [self.profileUser numberOfFollowingWithCompletion:^(int following) {
        self.numberFollowingLabel.text = [NSString stringWithFormat:@"%d", following];
    }];

    
}

#pragma mark - Navigation


- (void) editUserProfile {
    
    [self performSegueWithIdentifier:@"profileToEditProfile" sender:nil];
    
}


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([[segue identifier] isEqualToString:@"profileToEditProfile"]) {
     
         UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
         EditProfileVC *editProfileView = (EditProfileVC *)[[navController childViewControllers] lastObject];
         
         EVNUser *currentUser = [EVNUser currentUser];

         editProfileView.username = currentUser[@"username"];
         editProfileView.realName = currentUser[@"realName"];
         editProfileView.hometown = currentUser[@"hometown"];
         editProfileView.bio = currentUser[@"bio"];
         editProfileView.pictureData = UIImagePNGRepresentation(self.profileImageView.image);
         editProfileView.delegate = self;
         
     }
     
 }



@end
