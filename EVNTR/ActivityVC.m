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
                
                //Create Content for the Cell
                NSString *username = user[@"username"];
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
                        activityCell.leftSideImageView.image = [UIImage imageNamed:@"FollowIcon"];
                    } else {
                        activityCell.rightSideImageView.image = [UIImage imageNamed:@"UnfollowIcon"];
                    }
                }];
                
                
                
            }];
            
            break;
        }
        case INVITE_ACTIVITY: {
            NSLog(@"Invite %@", object);
            activityCell.activityContentTextLabel.text = @"Invite Activity";
        }
        default:
            
            NSLog(@"Other");
            break;
    }
    
    return activityCell;
    
}


@end
