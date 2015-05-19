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

@property (nonatomic, strong) EVNUser *profileUser;
@property (nonatomic) int profileType;
@property (nonatomic, strong) NSData *userPictureData;

//Structure Related Views
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItemWithSettingsBarItem;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundView;

//User Information
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
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
        self.profileUser = [EVNUser currentUser];
        self.userObjectID = [EVNUser currentUser].objectId;
        _isDismissedAlreadyCancel = NO;
        _isDismissedAlreadyUpdate = NO;
        
    }
    
    return self;
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.colorBackgroundView.backgroundColor = [UIColor orangeThemeColor];

    [self setupButtons];
    
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
                self.navigationItemWithSettingsBarItem.rightBarButtonItems = nil;
            }
            
            //Register to Know when New Follows Have Happened and Refresh Profile View with Database Values
            //TODO: Separate out what actually needs to be updated from database instead of updating all with updateUIWithUser
            // make sure to include follow status and following and followers counts.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIDueToNewFollow:) name:kFollowActivity object:nil];
            
            [self updateUIAll];
            
            
        } else {
            
            //TODO: Handle error.
            
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
    [self.profileImageView loadInBackground:^(UIImage *image, NSError *error) {
        self.userPictureData = UIImagePNGRepresentation(image);
    }];

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

- (IBAction)viewMyEvents:(id)sender {
    
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

- (IBAction)viewFollowers:(id)sender {
    
    PeopleVC *viewFollowersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewFollowersVC.typeOfUsers = VIEW_FOLLOWERS;
    viewFollowersVC.userProfile = self.profileUser;
    
    [self.navigationController pushViewController:viewFollowersVC animated:YES];
    
}

- (IBAction)viewFollowing:(id)sender {
    
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
        
        NSString *realName = [stringDictionary objectForKey:@"realName"];
        
        self.profileImageView.image = [UIImage imageWithData:imageData];
        
        self.nameLabel.text = realName;
        
        self.userObjectID = [EVNUser currentUser].objectId;
        self.profileUser = [EVNUser currentUser];
        
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
    
    if (notification.object != self && self.profileType != CURRENT_USER_PROFILE) {
        
        //Update the Button For Following/Follow
        PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
        [followActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
        [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [followActivity whereKey:@"to" equalTo:self.profileUser];
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
         editProfileView.pictureData = self.userPictureData;
         editProfileView.delegate = self;
         
     }
     
 }



@end
