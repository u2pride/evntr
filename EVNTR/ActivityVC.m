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
#import "SWRevealViewController.h"
#import "ProfileVC.h"
#import "EventDetailVC.h"

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
    
    //Setup Navigation
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
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
    
    return queryForActivities;
    
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    NSLog(@"Object for Activity Table View Controller: %@", object);
    
    static NSString *cellIdentifier = @"activityCell";

    ActivityTableCell *activityCell = (ActivityTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    int activityType = (int)[[object objectForKey:@"type"] integerValue];
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            NSLog(@"Follow %@", object);
            
            //Update the Cell
            activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
            

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
                [followActivity whereKey:@"to" equalTo:userWhoFollowedCurrentProfile];
                [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    //TODO - Does this make sense?
                    
                    if (!objects || !objects.count) {
                        activityCell.rightSideImageView.image = [UIImage imageNamed:@"FollowIcon"];
                        //activityCell.rightSideImageView.accessibilityHint = user[@"username"];
                        activityCell.rightSideImageView.userInteractionEnabled = YES;
                        activityCell.rightSideImageView.objectForImageView = userWhoFollowed;
                        UITapGestureRecognizer *tapFollow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followUser:)];
                        [activityCell.rightSideImageView addGestureRecognizer:tapFollow];
                    } else {
                        activityCell.rightSideImageView.image = [UIImage imageNamed:@"UnfollowIcon"];
                        activityCell.rightSideImageView.userInteractionEnabled = YES;
                        activityCell.rightSideImageView.objectForImageView = userWhoFollowed;
                        UITapGestureRecognizer *tapUnFollow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unFollowUser:)];
                        [activityCell.rightSideImageView addGestureRecognizer:tapUnFollow];
                    }
                }];
                
            }];
            
            break;
        }
        case INVITE_ACTIVITY: {
            NSLog(@"Invite %@", object);
            
            activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
            activityCell.rightSideImageView.image = [UIImage imageNamed:@"EventDefault"];

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
                            activityCell.rightSideImageView.image = [UIImage imageWithData:data];
                         
                            NSString *eventName = event[@"title"];
                            NSString *textForActivityCell = [NSString stringWithFormat:@"%@ invited you to %@", username, eventName];
                            activityCell.activityContentTextLabel.text = textForActivityCell;
                        }
                    }];
                    
                    activityCell.rightSideImageView.userInteractionEnabled = YES;
                    activityCell.rightSideImageView.objectForImageView = event;
                    UITapGestureRecognizer *viewEventGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEvent:)];
                    [activityCell.rightSideImageView addGestureRecognizer:viewEventGR];
   


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
- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    NSLog(@"Username: %@", tappedImage.objectForImageView);
    NSString *username = [tappedImage.objectForImageView objectForKey:@"username"];
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userNameForProfileView = username;
    [self.navigationController pushViewController:followerProfileVC animated:YES];
}

- (void)viewEvent:(UITapGestureRecognizer *)tapgr {
    ImageViewPFExtended *tappedImageView = (ImageViewPFExtended *)tapgr.view;
    NSLog(@"Event: %@", tappedImageView.objectForImageView);
    PFObject *eventTapped = tappedImageView.objectForImageView;
    
    EventDetailVC *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    eventDetailsVC.eventObject = eventTapped;
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
    
}

- (void)followUser:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedIconView = (ImageViewPFExtended *)tapgr.view;
    tappedIconView.image = [UIImage imageNamed:@"UnfollowIcon"];
    
    NSLog(@"Username Follow: %@", [tappedIconView.objectForImageView objectForKey:@"username"]);
    
    PFUser *userToFollow = (PFUser *)tappedIconView.objectForImageView;
    
    PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
    newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
    newFollowActivity[@"from"] = [PFUser currentUser];
    newFollowActivity[@"to"] = userToFollow;
    [newFollowActivity saveInBackground];
    
    //Remove old tap gesture recognizers
    for (UIGestureRecognizer *gr in tappedIconView.gestureRecognizers) {
        [tappedIconView removeGestureRecognizer:gr];
    }
    
    //Add back a gesture recognizer for unfollow user
    UITapGestureRecognizer *tapUnFollow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unFollowUser:)];
    [tappedIconView addGestureRecognizer:tapUnFollow];
    
}

- (void)unFollowUser:(UITapGestureRecognizer *)tapgr {
    
    NSLog(@"tapgr -- %@", tapgr);
    
    ImageViewPFExtended *tappedIconView = (ImageViewPFExtended *)tapgr.view;
    tappedIconView.image = [UIImage imageNamed:@"FollowIcon"];
    
    NSLog(@"Username Unfollow: %@", [tappedIconView.objectForImageView objectForKey:@"username"]);
    
    PFUser *userToUnfollow = (PFUser *)tappedIconView.objectForImageView;
    
    //Find and Delete Old Follow Activity
    PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
    
    [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [findFollowActivity whereKey:@"from" equalTo:[PFUser currentUser]];
    [findFollowActivity whereKey:@"to" equalTo:userToUnfollow];
    
    [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"Objects Found: %@", objects);
        
        PFObject *previousFollowActivity = [objects firstObject];
        [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Inside the delete part");
            
            //Update the Button....
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unfollow" message:@"deleted" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert show];
        }];
        
    }];
    
    //Remove old tap gesture recognizers
    for (UIGestureRecognizer *gr in tappedIconView.gestureRecognizers) {
        [tappedIconView removeGestureRecognizer:gr];
    }
    
    //Add back a gesture recognizer for unfollow user
    UITapGestureRecognizer *tapFollow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followUser:)];
    [tappedIconView addGestureRecognizer:tapFollow];

    
}


@end
