//
//  ActivityVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ActivityVC.h"
#import "ActivityTableCell.h"
#import "EVNConstants.h"
#import "ProfileVC.h"
#import "EventDetailVC.h"
#import "NSDate+NVTimeAgo.h"
#import "UIColor+EVNColors.h"

@implementation ActivityVC

@synthesize sidebarButton;


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Activity Feed";
        self.parseClassName = @"Activities";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        //self.isComingFromNavigation = NO;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFollowActivity:) name:kFollowActivity object:nil];


    
}


- (void)newFollowActivity:(NSNotification *)notification {
    
    if ([notification.object isEqual:self]) {
        NSLog(@"Notification is sent from myself - ignore");
    } else {
        [self loadObjects];
        NSLog(@"Re-loading Objects in tableview");
        
        //TODO : just update objects of type follow
        /*
        for (PFObject *activity in self.objects) {
            
            NSNumber *type = [activity objectForKey:@"type"];
            int value = [type integerValue];
            
            if (value == 1) {
                NSLog(@"Found a cell with follow type - try to reload it");
                //call cell for row at indexpath
            }
        }
         */
    }
    

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSNumber *noNewActivities = 0;
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:noNewActivities forKey:kNumberOfNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}


- (PFQuery *)queryForTable {
    
    PFQuery *queryForActivities = [PFQuery queryWithClassName:@"Activities"];
    [queryForActivities whereKey:@"to" equalTo:[PFUser currentUser]];
    [queryForActivities orderByDescending:@"updatedAt"];
    
    return queryForActivities;
    
}

- (void) objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    //Reset App Badge and Tab Bar Badge
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:[NSDate date] forKey:kLastBackgroundFetchTimeStamp];
    
    
    
}



- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
        
    static NSString *cellIdentifier = @"activityCell";

    ActivityTableCell *activityCell = (ActivityTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    

    
    int activityType = (int)[[object objectForKey:@"type"] integerValue];
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            
            //Update the Cell
            activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
            NSDate *createdAtDate = object.createdAt;
            activityCell.timestampActivity.text = [createdAtDate formattedAsTimeAgo];
            
            PFUser *userWhoFollowedCurrentProfile = object[@"from"];
            
            [userWhoFollowedCurrentProfile fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                
                PFUser *userWhoFollowed = (PFUser *)user;
                
                //Create Content for the Cell
                NSString *username = user[@"username"];
                //Using the AccessibilityHint property to carry the username for taps.
                //activityCell.leftSideImageView.accessibilityHint = user[@"username"];
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = userWhoFollowed;
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                NSString *textForActivityCell = [NSString stringWithFormat:@"%@ followed you.", username];
                activityCell.activityContentTextLabel.text = textForActivityCell;
                
                
                //configure view button on right side
                UIButtonPFExtended *followButton = activityCell.actionButton;
                followButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                activityCell.actionButton.backgroundColor = [UIColor clearColor];
                

                
                
                //Grab the profile pic of the user and set it to the left image
                PFFile *profilePictureFromParse = user[@"profilePicture"];
                [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                    }
                }];
                
                //Determine whether the current user is following this user
                PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
                [followActivity whereKey:@"from" equalTo:[PFUser currentUser]];
                [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
                [followActivity whereKey:@"to" equalTo:userWhoFollowed];
                [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    //TODO - Does this make sense?
                    
                    if (!objects || !objects.count) {
                        [activityCell.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
                        activityCell.actionButton.personToFollow = userWhoFollowed;
                    } else {
                        [activityCell.actionButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                        activityCell.actionButton.personToFollow = userWhoFollowed;
                    }
                    
                    [activityCell.actionButton addTarget:self action:@selector(tappedFollowButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                }];
                
            }];
            
            break;
        }
        case INVITE_ACTIVITY: {
            
            //Update Cell UI
            activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
            NSDate *createdAtDate = object.createdAt;
            activityCell.timestampActivity.text = [createdAtDate formattedAsTimeAgo];

            PFUser *userWhoInvitedCurrentProfile = object[@"from"];
            
            [userWhoInvitedCurrentProfile fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                
                //next line is unneccessary?
                PFUser *userWhoInvited = (PFUser *)user;
                
                NSString *username = userWhoInvited[@"username"];
                
                //attach user to imageview for tap gesture recognizer
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = userWhoInvited;
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                //configure view button on right side
                [activityCell.actionButton setTitle:@"View" forState:UIControlStateNormal];
                activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                activityCell.actionButton.backgroundColor = [UIColor clearColor];
                [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
                
                
                //Grab the profile pic of the user and set it to the left image
                PFFile *profilePictureFromParse = userWhoInvited[@"profilePicture"];
                [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                    }
                }];
                
                PFObject *eventInvitedTo = object[@"activityContent"];
                [eventInvitedTo fetchIfNeededInBackgroundWithBlock:^(PFObject *event, NSError *error) {
                   
                    
                    PFFile *eventCoverPhoto = event[@"coverPhoto"];
                    [eventCoverPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            //activityCell.rightSideImageView.image = [UIImage imageWithData:data];
                         
                            NSString *eventName = event[@"title"];
                            NSString *textForActivityCell = [NSString stringWithFormat:@"%@ invited you to %@", username, eventName];
                            activityCell.activityContentTextLabel.text = textForActivityCell;
                        }
                    }];
                    
                    //attach the event to the cell
                    activityCell.actionButton.eventToView = event;

                    
                    //activityCell.rightSideImageView.userInteractionEnabled = YES;
                    //activityCell.rightSideImageView.objectForImageView = event;
                    //UITapGestureRecognizer *viewEventGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEvent:)];
                    //[activityCell.rightSideImageView addGestureRecognizer:viewEventGR];
   
                    

                }];
                
            }];
            
        }
        default:
            
            NSLog(@"Other");
            break;
    }
    

    return activityCell;
    
}


#pragma mark - 
#pragma mark - Target-Action Method Implementations

//View User Profile When Profile Image on Left Side is Selected
- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    NSLog(@"Username: %@", tappedImage.objectForImageView);
    NSString *username = [tappedImage.objectForImageView objectForKey:@"username"];
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userNameForProfileView = username;
    [self.navigationController pushViewController:followerProfileVC animated:YES];
}

- (void)viewEvent:(id)sender {
    
    UIButtonPFExtended *viewButton = (UIButtonPFExtended *)sender;
    PFObject *eventToView = viewButton.eventToView;
    
    EventDetailVC *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    eventDetailsVC.eventObject = eventToView;
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
    
}

- (void)tappedFollowButton:(id)sender {
    
    UIButtonPFExtended *followButton = (UIButtonPFExtended *)sender;
    PFUser *userToChangeFollowState = followButton.personToFollow;
    
    followButton.enabled = NO;
    
    NSString *followState = followButton.titleLabel.text;
    
    //Follow User or Unfollow User Depending on Current Button State
    if ([followState isEqualToString:@"Unfollow"]) {

        //Find and Delete Old Follow Activity
        PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [findFollowActivity whereKey:@"from" equalTo:[PFUser currentUser]];
        [findFollowActivity whereKey:@"to" equalTo:userToChangeFollowState];
        
        [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *previousFollowActivity = [objects firstObject];
            [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                if (succeeded){
                    [followButton setTitle:@"Follow" forState:UIControlStateNormal];
                    
                    //Notify Profile View of Update
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
        
                    
                } else {
                    NSLog(@"Error Deletin Follow Activity");
                }
                
                //Re-Enable Button
                followButton.enabled = YES;
                
            }];
        }];
        
        
    } else {
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        newFollowActivity[@"from"] = [PFUser currentUser];
        newFollowActivity[@"to"] = userToChangeFollowState;
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                
                //Notify Profile View of Update
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                
            } else {
                NSLog(@"Error Saving New Follow: %@", error);
            }
            
            //Re-Enable Button
            followButton.enabled = YES;
            
        }];
    }
}


@end

