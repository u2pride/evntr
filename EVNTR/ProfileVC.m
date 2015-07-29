//
//  ProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "ActivityVC.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "EVNInviteFBFriendsVC.h"
#import "EditProfileVC.h"
#import "HomeScreenVC.h"
#import "LogInVC.h"
#import "NSDate+NVTimeAgo.h"
#import "PeopleVC.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import "EVNGradientView.h"

#import <QuartzCore/QuartzCore.h>


@interface ProfileVC ()

@property (nonatomic, strong) EVNUser *profileUser;
@property (nonatomic) int profileType;

//Structure Related Views
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *colorBackgroundView;
@property (strong, nonatomic) EVNGradientView *gradientView;
@property (strong, nonatomic) NSLayoutConstraint *bioConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pictureBottomConstraint;

//User Information
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *eventsHeaderButton;
@property (strong, nonatomic) IBOutlet UICountingLabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UIButton *followersHeaderButton;
@property (strong, nonatomic) IBOutlet UICountingLabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingHeaderButton;
@property (strong, nonatomic) IBOutlet UICountingLabel *numberFollowingLabel;
@property (strong, nonatomic) IBOutlet UILabel *userHometownLabel;


//Buttons For Actions On Profile
@property (strong, nonatomic) IBOutlet EVNButton *followButton;
@property (strong, nonatomic) IBOutlet EVNButton *editProfileButton;


- (IBAction)followUser:(id)sender;

@end


@implementation ProfileVC

//Note: this is called before you would programmatically set variables in prepareforsegue when creating this viewcontroller.
//ideally we pass in the user for this view, however some views will not have access to the full user... just the name.  For example, an attributed text label.
//instagram doesn't update the view if already in stack.

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
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        
    self.gradientView = [[EVNGradientView alloc] initWithFrame:self.colorBackgroundView.bounds];
    self.gradientView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.gradientView.layer.colors = [NSArray arrayWithObjects:
                                     (id)[UIColor orangeThemeColor].CGColor,
                                     (id)[UIColor orangeThemeColor].CGColor,
                                     (id)[UIColor darkOrangeThemeColor].CGColor,
                                     nil];
    
    self.gradientView.layer.locations = [NSArray arrayWithObjects:
                                         [NSNumber numberWithFloat:0.0f],
                                         [NSNumber numberWithFloat:0.2f],
                                         [NSNumber numberWithFloat:1.0f],
                                         nil];
    
    [self.colorBackgroundView addSubview:self.gradientView];
    
    [self.colorBackgroundView sendSubviewToBack:self.gradientView];
    
    
    [self setupButtons];
    [self wireUpTapRecognizers];
    
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.alwaysBounceVertical = YES;
    
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"";
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    PFQuery *usernameQuery = [EVNUser query];
    [usernameQuery whereKey:@"objectId" equalTo:self.userObjectID];
    [usernameQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            self.profileUser = (EVNUser *)object;
            
            self.userHometownLabel.text = [self.profileUser hometownText];
            
            if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
                self.profileType = CURRENT_USER_PROFILE;
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventCount) name:kUserCreatedNewEvent object:nil];
                
                UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
                
                [self.navigationItem setRightBarButtonItem:settingsButton animated:YES];
                                
                if (self.navigationController.viewControllers.count == 1) {
                    
                    UIBarButtonItem *inviteToApp = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inviteIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showInviteScreen)];
                 
                    [self.navigationItem setLeftBarButtonItem:inviteToApp animated:YES];
                    
                }
                
            } else {
                self.profileType = OTHER_USER_PROFILE;
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromNewFollow:) name:kNewFollow object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromNewUnfollow:) name:kNewUnfollow object:nil];

            [self updateUIAll];
            
        } else {
            
            [PFAnalytics trackEventInBackground:@"ProfileNotFound" block:nil];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance logEvent:@"ProfileNotFound"];

            self.eventsHeaderButton.hidden = YES;
            self.followingHeaderButton.hidden = YES;
            self.followersHeaderButton.hidden = YES;
            self.numberEventsLabel.hidden = YES;
            self.numberFollowingLabel.hidden = YES;
            self.numberFollowersLabel.hidden = YES;
            
            
            UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSettings)];
            self.navigationItem.rightBarButtonItem = settingsButton;
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"User Missing" message:@"Looks like we can't find this user.  But don't worry!  We'll start a search party for them." delegate:self cancelButtonTitle:@"Phew!" otherButtonTitles: nil];
            
            [errorAlert show];
        }
        
        [self updateViewConstraints];
        
    }];
    
}



- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}


- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    //self.bioLabel.text = [self.profileUser bioText];

    CGSize moreSize = CGSizeMake(self.bioLabel.frame.size.width, 9999);
    CGSize anotherSize = [self.bioLabel sizeThatFits:moreSize];
    
    if (!self.bioConstraint) {
        
        float heightConstant = anotherSize.height;
        
        if (heightConstant == 0) {
            heightConstant = 34;
        }
        
        self.bioConstraint = [NSLayoutConstraint constraintWithItem:self.bioLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:heightConstant];
        
        [self.view addConstraint:self.bioConstraint];
        
        
    } else {
        
        self.bioConstraint.constant = anotherSize.height;
        
    }
    
}

#pragma mark - Helper Methods for VC Lifecycle

- (void) setupButtons {
    
    self.followButton.buttonColor = [UIColor darkOrangeThemeColor];
    self.followButton.font = [UIFont fontWithName:@"Lato-Regular" size:21];
    self.followButton.isRounded = YES;
    self.followButton.hasBorder = YES;
    
    self.editProfileButton.buttonColor = [UIColor darkOrangeThemeColor];
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
    UITapGestureRecognizer *viewProfilePicture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resizeProfilePicture)];
    
    [self.eventsHeaderButton addTarget:self action:@selector(viewEvents) forControlEvents:UIControlEventTouchUpInside];
    
    [self.followingHeaderButton addTarget:self action:@selector(viewFollowing) forControlEvents:UIControlEventTouchUpInside];
    
    [self.followersHeaderButton addTarget:self action:@selector(viewFollowers) forControlEvents:UIControlEventTouchUpInside];
    
    self.numberEventsLabel.userInteractionEnabled = YES;
    self.numberFollowingLabel.userInteractionEnabled = YES;
    self.numberFollowersLabel.userInteractionEnabled = YES;
    self.profileImageView.userInteractionEnabled = YES;
    
    [self.numberEventsLabel addGestureRecognizer:viewEvents];
    [self.numberFollowingLabel addGestureRecognizer:viewFollowing];
    [self.numberFollowersLabel addGestureRecognizer:viewFollowers];
    [self.profileImageView addGestureRecognizer:viewProfilePicture];
    
}

- (void) updateUIAll {

    switch (self.profileType) {
        case CURRENT_USER_PROFILE: {

            //self.followButton.hidden = YES;
            //self.editProfileButton.hidden = NO;
            
            [self showEditProfileButton];
            
            [self.editProfileButton addTarget:self action:@selector(editUserProfile) forControlEvents:UIControlEventTouchUpInside];
            
            self.title = @"Profile";
            
            //CHANGED
            //self.navigationItem.title = [@"@" stringByAppendingString:self.profileUser.username];
            self.navigationItem.title = [self.profileUser nameText];
            
            break;
        }
        case OTHER_USER_PROFILE: {
            
            //self.followButton.hidden = NO;
            //self.editProfileButton.hidden = YES;
            
            //self.navigationItem.title = [@"@" stringByAppendingString:self.profileUser.username];
            self.navigationItem.title = [self.profileUser nameText];

            [[EVNUser currentUser] isCurrentUserFollowingProfile:self.profileUser completion:^(BOOL isFollowing, BOOL success) {
                
                if (success) {
                    if (isFollowing) {
                        
                        [self showFollowButtonWithText:kFollowingString];
                        self.followButton.isSelected = YES;
                        
                    } else {
                        
                        [self showFollowButtonWithText:kFollowString];
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
    
    self.nameLabel.text = [@"@" stringByAppendingString:self.profileUser.username];
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Regular" size:24];
    
    self.bioLabel.text = [self.profileUser bioText];
    
    PFFile *profilePictureFromParse = self.profileUser[@"profilePicture"];
    self.profileImageView.file = profilePictureFromParse;
    
    [self.profileImageView loadInBackground];

    //Counts on Events, Followers, Following
    if (self.profileUser.numEvents) {
        self.numberEventsLabel.format = @"%d";
        self.numberEventsLabel.method = UILabelCountingMethodEaseOut;
        [self.numberEventsLabel countFromZeroTo:[self.profileUser.numEvents doubleValue] withDuration:1.0f];
    } else {
        self.numberEventsLabel.text = @"0";
    }
    
    if (self.profileUser.numFollowers) {
        self.numberFollowersLabel.format = @"%d";
        self.numberFollowersLabel.method = UILabelCountingMethodEaseOut;
        [self.numberFollowersLabel countFromZeroTo:[self.profileUser.numFollowers doubleValue] withDuration:1.0f];
    } else {
        self.numberFollowersLabel.text = @"0";
    }
    
    
    if (self.profileUser.numFollowing) {
        self.numberFollowingLabel.format = @"%d";
        self.numberFollowingLabel.method = UILabelCountingMethodEaseOut;
        [self.numberFollowingLabel countFromZeroTo:[self.profileUser.numFollowing doubleValue] withDuration:1.0f];
    } else {
        self.numberFollowingLabel.text = @"0";
    }
    

}

- (void) showEditProfileButton {
    
    if (self.editProfileButton.hidden) {
        
        self.editProfileButton.alpha = 0;
        self.editProfileButton.hidden = NO;
        
        [UIView animateWithDuration:0.7 animations:^{
            
            self.editProfileButton.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

- (void) showFollowButtonWithText:(NSString *) followStateString {
    
    self.followButton.titleText = followStateString;
    
    if (self.followButton.hidden) {
        
        self.followButton.alpha = 0;
        self.followButton.hidden = NO;
        
        [UIView animateWithDuration:0.7 animations:^{
            
            self.followButton.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            
        }];
        
    }

}



#pragma mark - ProfileActions

- (void) resizeProfilePicture {
    
    if (self.nameLabel.alpha == 0.0) {
        
        [self.view layoutIfNeeded];
        
        self.pictureBottomConstraint.constant = 4;
        

        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.view layoutIfNeeded];
            
            self.bioLabel.alpha = 1.0;
            self.nameLabel.alpha = 1.0;
            self.userHometownLabel.alpha = 1.0;
            
        } completion:^(BOOL finished) {
        
        }];
        
    } else {
        
        
        [self.view layoutIfNeeded];
        
        float totalIncrease = self.nameLabel.frame.size.height + self.userHometownLabel.frame.size.height + self.bioLabel.frame.size.height;

        self.pictureBottomConstraint.constant -= totalIncrease;
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.view layoutIfNeeded];
            
            self.bioLabel.alpha = 0.0;
            self.nameLabel.alpha = 0.0;
            self.userHometownLabel.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
}

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

- (void) viewSettings {
    
    [self performSegueWithIdentifier:@"profileToSettings" sender:nil];
    
}

- (void) showInviteScreen {
    
    EVNInviteContainerVC *inviteVC = [[EVNInviteContainerVC alloc] init];
    
    inviteVC.viewControllerOne = [EVNInviteFBFriendsVC new];
    inviteVC.viewControllerTwo = [EVNInviteContactsVC new];
    inviteVC.delegate = self;
    
    [self.navigationController pushViewController:inviteVC animated:YES];

    
}


#pragma mark - Delegate Methods

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
    NSLog(@"Success");
    
}

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    
    NSLog(@"Failure");
    
}



#pragma mark - Follow User

- (IBAction)followUser:(id)sender {

    if (self.followButton.titleText.length == 0) {
        
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Well..." message:@"Looks like we can't figure out if you're following this user or not yet... you should probably send us an angry email.  Just go to your profile and tap Settings." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [error show];
        
    } else {
        [[EVNUser currentUser] followUser:self.profileUser fromVC:self withButton:self.followButton withCompletion:^(BOOL success) { }];
    }
    
}



#pragma mark - ProfileEditDelegate Methods

- (void)canceledEditingProfile {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


-(void)saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData {
    
    NSString *username = [stringDictionary objectForKey:@"username"];
    
    self.profileImageView.image = [UIImage imageWithData:imageData];
    self.nameLabel.text = [@"@" stringByAppendingString:username];;
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

- (void) incrementFollowers {
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    NSNumber *followingCount = [numFormat numberFromString:self.numberFollowersLabel.text];
    followingCount = [NSNumber numberWithInt:[followingCount intValue] + 1];
    
    self.numberFollowersLabel.text = [numFormat stringFromNumber:followingCount];
    
}

- (void) decrementFollowers {
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    NSNumber *followingCount = [numFormat numberFromString:self.numberFollowersLabel.text];
    followingCount = [NSNumber numberWithInt:[followingCount intValue] - 1];
    
    self.numberFollowersLabel.text = [numFormat stringFromNumber:followingCount];
    
}


- (void) updateFromNewFollow:(NSNotification *)notification {
    
    NSString *followUserID = [notification.userInfo objectForKey:kFollowedUserObjectId];
    
    if ([followUserID isEqualToString:self.userObjectID]) {
        
        [self incrementFollowers];
        
        self.followButton.titleText = kFollowingString;
        self.followButton.isSelected = YES;
    }
    
    if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {

        [self incrementFollowing];
        
    }

}

- (void) updateFromNewUnfollow:(NSNotification *)notification {
    
    NSString *unFollowUserID = [notification.userInfo objectForKey:kUnfollowedUserObjectId];
    
    if ([unFollowUserID isEqualToString:self.userObjectID]) {
        
        [self decrementFollowers];
        
        self.followButton.titleText = kFollowString;
        self.followButton.isSelected = NO;
    }
    
    if ([self.userObjectID isEqualToString:[EVNUser currentUser].objectId]) {
        
        [self decrementFollowing];
        
    }

}


#pragma mark - EVNInvite Protocol

- (EVNNoResultsView *) contactsInviteMessageWithSelector:(SEL)selector andSender:(id)sender {

    EVNInviteContactsVC *inviteContactsVC = (EVNInviteContactsVC *)sender;
    
    EVNNoResultsView *messageForContactsVC = [[EVNNoResultsView alloc] initWithFrame:inviteContactsVC.view.bounds];
    messageForContactsVC.headerText = @"Text A Friend";
    messageForContactsVC.subHeaderText = @"Click to text your friends an app store link for Evntr.";
    messageForContactsVC.actionButton.titleText = @"Message";
    
    messageForContactsVC.offsetY = 100;
    
    [messageForContactsVC.actionButton addTarget:inviteContactsVC action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return messageForContactsVC;
    
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
         editProfileView.hometown = [self.profileUser hometownText];
         editProfileView.bio = currentUser[@"bio"];
         editProfileView.pictureData = UIImagePNGRepresentation(self.profileImageView.image);
         editProfileView.delegate = self;
         
     } else if ([[segue identifier] isEqualToString:@"profileToSettings"]) {
         //emtpy
     }
     
 }

#pragma mark - Clean Up

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
