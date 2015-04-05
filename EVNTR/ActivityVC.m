//
//  ActivityVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ActivityTableCell.h"
#import "ActivityVC.h"
#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EventDetailVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

@interface ActivityVC ()

@property (nonatomic) EVNNoResultsView *noResultsView;

@end

@implementation ActivityVC

//TODO: move to viewDidLoad? - Doesn't depend on view though.
//Only properties that will be available are ones in the super class (PFQueryTableViewController).  Only can access my instance variables.
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Activity";
        self.parseClassName = @"Activities";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.userForActivities = [PFUser currentUser];
        _typeOfActivityView = ACTIVITIES_ALL;
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO:  ONLY FOR ALL ACTIVITIES
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFollowActivity:) name:kFollowActivity object:nil];

    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    switch (self.typeOfActivityView) {
        case ACTIVITIES_ALL: {
            self.navigationItem.title = @"Notifications";
            break;
        }
        case ACTIVITIES_INVITES: {
            self.navigationItem.title = @"Invites";
            break;
        }
        case ACTIVITIES_REQUESTS_TO_ME: {
            self.navigationItem.title = @"Access Requests";
            break;
        }
        case ACTIVITIES_ATTENDED: {
            self.navigationItem.title = @"Events Attended";
            break;
        }
        case ACTIVITIES_MY_REQUESTS_STATUS: {
            self.navigationItem.title = @"Access Responses";
            break;
        }
        default:
            
            break;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //TODO:  ONLY FOR ALL ACTIVITIES
    NSNumber *noNewActivities = 0;
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:noNewActivities forKey:kNumberOfNotifications];
    [standardDefaults synchronize];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}


#pragma mark - New Follow Notiification

//Method that gets called when a new follow notification is posted
//Used to update whether the current user is following/not following in the notification table.
//TODO:  only reloads follow activities - eventually the notification should contain the username and the tableview should only update that one cell.  Need to add for requests maybe
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



#pragma mark - Parse UITableView Methods

- (PFQuery *)queryForTable {
    
    PFQuery *queryForActivities = [PFQuery queryWithClassName:@"Activities"];
    
    //Build the query for the table
    switch (self.typeOfActivityView) {
        case ACTIVITIES_ALL: {
            //[queryForActivities whereKey:@"type" notEqualTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_INVITES: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_REQUESTS_TO_ME: {
            //list of people that want access to your events
            //query activities where
            
            //Get all events by User
            PFQuery *innerQueryForAuthor = [PFQuery queryWithClassName:@"Events"];
            [innerQueryForAuthor whereKey:@"parent" equalTo:[PFUser currentUser]];
            
            //Get all request access activities
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            
            //now find access activities that are from the current user
            [queryForActivities whereKey:@"activityContent" matchesQuery:innerQueryForAuthor];
            
            [queryForActivities orderByDescending:@"updatedAt"];

            
            break;
        }
        case ACTIVITIES_ATTENDED: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_MY_REQUESTS_STATUS: {
            
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        default:
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
    }
    
    return queryForActivities;
    
}

- (void) objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0) {
        
        [self showNoResultsView];
        
        NSLog(@"No Results - Add a No Results View");
        
    } else {
        
        self.noResultsView.hidden = YES;
    }
    
    //Reset App Badge and Tab Bar Badge
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:[NSDate date] forKey:kLastBackgroundFetchTimeStamp];
    
}

- (void) showNoResultsView {
    
    if (!self.noResultsView) {
        self.noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
    }
    
    self.noResultsView.headerText = @"Where is Everyone?";
    self.noResultsView.subHeaderText = @"Looks like there's no activity yet.  Once you start attending and creating events, you'll see your activity in here.";
    
    [self.view addSubview:self.noResultsView];
    
    
}

- (void) hideNoResultsView {
    
    [self.noResultsView removeFromSuperview];
    
}
    



- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
        
    static NSString *cellIdentifier = @"activityCell";

    ActivityTableCell *activityCell = (ActivityTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    int activityType = (int) [[object objectForKey:@"type"] integerValue];

    if (activityType == FOLLOW_ACTIVITY) {
        NSLog(@"Follow Activity");
    } else if (activityType == INVITE_ACTIVITY) {
        NSLog(@"Invite Activity");
    } else if (activityType == REQUEST_ACCESS_ACTIVITY) {
        NSLog(@"Request Access Activity");
    } else if (activityType == ATTENDING_ACTIVITY) {
        NSLog(@"Attending Activity");
    } else {
        NSLog(@"Activity Type Not Found");
    }
    
    //Update Cell UI
    activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
    NSDate *createdAtDate = object.createdAt;
    activityCell.timestampActivity.text = [createdAtDate formattedAsTimeAgo];
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            
            PFUser *userWhoFollowedCurrentProfile = object[@"from"];
            
            //TODO - Use includeKey: in original query. Therefore you don't need to do fetchIfNeeded a ton.
            [userWhoFollowedCurrentProfile fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                
                PFUser *userWhoFollowed = (PFUser *)user;
                
                //Create Content for the Cell
                NSString *username = user[@"username"];
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = userWhoFollowed;
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                NSString *textForActivityCell = [NSString stringWithFormat:@"%@ followed you.", username];
                activityCell.activityContentTextLabel.text = textForActivityCell;
                
                //configure view button on right side
                //UIButtonPFExtended *followButton = activityCell.actionButton;
                //followButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                //activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                //activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                //activityCell.actionButton.backgroundColor = [UIColor clearColor];
                
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
                        activityCell.actionButton.titleText = @"Follow";
                        activityCell.actionButton.personToFollow = userWhoFollowed;
                    } else {
                        activityCell.actionButton.titleText = @"Following";
                        [activityCell.actionButton setIsSelected:YES];
                        activityCell.actionButton.personToFollow = userWhoFollowed;
                    }
                    
                    [activityCell.actionButton addTarget:self action:@selector(tappedFollowButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                }];
                
            }];
            
            break;
        }
        case INVITE_ACTIVITY: {
            
            PFUser *userWhoInvitedCurrentProfile = object[@"from"];
            __block NSString *username;

            [userWhoInvitedCurrentProfile fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                
                //next line is unneccessary?
                //TOOD: is this causing the error?
                PFObject *userWhoInvited = user;
                
                username = userWhoInvited[@"username"];
                
                //attach user to imageview for tap gesture recognizer
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = userWhoInvited;
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                //configure view button on right side
                activityCell.actionButton.titleText = @"View";
                //[activityCell.actionButton setTitle:@"View" forState:UIControlStateNormal];
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
                NSLog(@"eventInvitedTo: %@", eventInvitedTo);
                [eventInvitedTo fetchInBackgroundWithBlock:^(PFObject *eventRetrieved, NSError *error) {
                    
                    EventObject *event = (EventObject *) eventRetrieved;
                    
                    //TODO: Add error catching to other activity types.
                    if (!error) {
                        NSString *eventName = [event objectForKey:@"title"];
                        NSString *textForActivityCell = [NSString stringWithFormat:@"%@ invited you to %@", username, eventName];
                        activityCell.activityContentTextLabel.text = textForActivityCell;
                        
                        //attach the event to the cell
                        activityCell.actionButton.eventToView = event;
                        
                    } else {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"ERROR IN GETTING EVENT THRU FETCH" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [errorAlert show];
                    }
                    
                }];
                
            }];
            
            break;
        }
        case REQUEST_ACCESS_ACTIVITY: {
            
            PFUser *userRequestedAccess = object[@"from"];

            [userRequestedAccess fetchInBackgroundWithBlock:^(PFObject *userRequesting, NSError *error) {
                
                PFObject *eventRequestingAccessTo = object[@"activityContent"];
                
                //Grab the profile pic of the user and set it to the left image
                PFFile *profilePictureFromParse = userRequesting[@"profilePicture"];
                [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                    }
                }];
                
                //configure view button on right side
                activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                activityCell.actionButton.backgroundColor = [UIColor clearColor];

                [eventRequestingAccessTo fetchInBackgroundWithBlock:^(PFObject *eventRetrieved, NSError *error) {
                    
                    EventObject *event = (EventObject *) eventRetrieved;
                    
                    //Determine if the user has been granted access yet.
                    PFQuery *grantedActivity = [PFQuery queryWithClassName:@"Activities"];
                    [grantedActivity whereKey:@"from" equalTo:[PFUser currentUser]];
                    [grantedActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
                    [grantedActivity whereKey:@"to" equalTo:userRequesting];
                    [grantedActivity whereKey:@"activityContent" equalTo:event];
                    [grantedActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (!objects || !objects.count) {
                            activityCell.actionButton.titleText = kGrantAccess;
                            //[activityCell.actionButton setTitle:kGrantAccess forState:UIControlStateNormal];
                        } else {
                            activityCell.actionButton.titleText = kRevokeAccess;
                            [activityCell.actionButton setIsSelected:YES];
                            //[activityCell.actionButton setTitle:kRevokeAccess forState:UIControlStateNormal];
                        }
                        
                        [activityCell.actionButton addTarget:self action:@selector(grantAccess:) forControlEvents:UIControlEventTouchUpInside];
                        
                    }];
                    
                    activityCell.actionButton.personToGrantAccess = (PFUser *)userRequesting;
                    activityCell.actionButton.eventToGrantAccess = event;
                    
                    NSString *descriptionString = [NSString stringWithFormat:@"%@ requested access to %@", userRequesting[@"username"], event[@"title"]];
                    activityCell.activityContentTextLabel.text = descriptionString;
                    
                }];
                
            }];
            
            break;
        }
        case ATTENDING_ACTIVITY: {
            
            PFFile *profilePicture = [[PFUser currentUser] objectForKey:@"profilePicture"];
            [profilePicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            
            EventObject *eventAttending = object[@"activityContent"];
            [eventAttending fetchInBackgroundWithBlock:^(PFObject *objectRetrieved, NSError *error) {
                
                EventObject *object = (EventObject *) objectRetrieved;
                
                if (!error) {
                    
                    NSString *activityDescriptionString;
                    
                    NSDate *dateOfEvent = object[@"dateOfEvent"];
                    NSDate *currentDate = [NSDate date];
                    NSComparisonResult dateComparison = [currentDate compare:dateOfEvent];
                    
                    //Build the description string based off Time of Event and User
                    if ([self.userForActivities.objectId isEqualToString:[PFUser currentUser].objectId] ) {
                    
                        if (dateComparison == NSOrderedAscending) {
                            activityDescriptionString = [NSString stringWithFormat:@"You're going to %@", object[@"title"]];
                            
                        } else if (dateComparison == NSOrderedDescending) {
                            activityDescriptionString = [NSString stringWithFormat:@"You went to %@", object[@"title"]];
                            
                        } else {
                            
                        }
                        
                    } else {
                        
                        if (dateComparison == NSOrderedAscending) {
                            activityDescriptionString = [NSString stringWithFormat:@"%@ is going to %@", self.userForActivities[@"username"], object[@"title"]];
                            
                        } else if (dateComparison == NSOrderedDescending) {
                            activityDescriptionString = [NSString stringWithFormat:@"%@ went to %@", self.userForActivities[@"username"], object[@"title"]];
                            
                        } else {
                            
                        }
                        
                        
                    }

                    activityCell.activityContentTextLabel.text = activityDescriptionString;
                    
                    
                    //configure view button on right side
                    activityCell.actionButton.titleText = @"View";
                    //[activityCell.actionButton setTitle:@"View" forState:UIControlStateNormal];
                    activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                    activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                    activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                    activityCell.actionButton.backgroundColor = [UIColor clearColor];
                    activityCell.actionButton.eventToView = object;
                    
                    [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
                }
                
            }];
            
            break;
        }
        case ACCESS_GRANTED_ACTIVITY: {
            
            PFUser *userThatGrantedAccess = object[@"from"];
            
            [userThatGrantedAccess fetchInBackgroundWithBlock:^(PFObject *userThatGranted, NSError *error) {
                
                PFObject *eventGivenAccessTo = object[@"activityContent"];
                
                //Grab the profile pic of the user and set it to the left image
                PFFile *profilePictureFromParse = userThatGranted[@"profilePicture"];
                [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    if (!error) {
                        activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                    }
                }];
                
                //configure view button on right side
                activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
                activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
                activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
                activityCell.actionButton.backgroundColor = [UIColor clearColor];
                
                [eventGivenAccessTo fetchInBackgroundWithBlock:^(PFObject *eventRetrieved, NSError *error) {
                    
                    EventObject *event = (EventObject *) eventRetrieved;
                    
                    activityCell.actionButton.titleText = @"View";
                    //[activityCell.actionButton setTitle:@"View" forState:UIControlStateNormal];
                    [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
                    
                    activityCell.actionButton.eventToView = event;
                    
                    NSString *descriptionString = [NSString stringWithFormat:@"%@ let you in to %@", userThatGranted[@"username"], event[@"title"]];
                    activityCell.activityContentTextLabel.text = descriptionString;
                    
                }];
                
            }];

            break;
        }
        default:
            
            NSLog(@"DEFAULT Activity SWITCH");

            break;
    }
    

    return activityCell;
    
}


#pragma mark - 
#pragma mark - Target-Action Method Implementations

//View User Profile When Profile Image on Left Side is Selected
- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    NSString *username = [tappedImage.objectForImageView objectForKey:@"username"];
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userNameForProfileView = username;
    [self.navigationController pushViewController:followerProfileVC animated:YES];

}

- (void)viewEvent:(id)sender {
    
    UIButtonPFExtended *viewButton = (UIButtonPFExtended *)sender;
    EventObject *object = viewButton.eventToView;
    
    EventDetailVC *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    
    //EVNEvent *eventToView = [[EVNEvent alloc] initWithID:[object objectForKey:@"objectId"] name:[object objectForKey:@"title"] type:[object objectForKey:@"typeOfEvent"] creator:[object objectForKey:@"parent"] coverImage:[object objectForKey:@"coverPhoto"] description:[object objectForKey:@"description"] date:[object objectForKey:@"dateOfEvent"] locationGeoPoint:[object objectForKey:@"locationOfEvent"] locationName:[object objectForKey:@"nameOfLocation"] photos:[object objectForKey:@"eventImages"] invitedUsers:[object objectForKey:@"invitedUsers"] attendees:[object objectForKey:@"attenders"] backingObject:object];
    
    eventDetailsVC.event = object;
    
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
    
    [viewButton endedTask];
    [viewButton setIsSelected:NO];
    
}

- (void)grantAccess:(id)sender {
    
    UIButtonPFExtended *grantButton = (UIButtonPFExtended *)sender;
    [grantButton startedTask];
    grantButton.enabled = NO;
    
    NSString *grantState = grantButton.titleText;
    
    //Grant Access to User or Revoke Access to User Depending on Current Button State
    if ([grantState isEqualToString:kRevokeAccess]) {
        
        //Find and Delete Old Granted Access Activity
        PFQuery *findGrantActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findGrantActivity whereKey:@"from" equalTo:self.userForActivities];
        [findGrantActivity whereKey:@"to" equalTo:grantButton.personToGrantAccess];
        [findGrantActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
        [findGrantActivity whereKey:@"activityContent" equalTo:grantButton.eventToGrantAccess];
        
        [findGrantActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *previousGrantActivity = [objects firstObject];
            [previousGrantActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded){
                    grantButton.titleText = kGrantAccess;
                    //[grantButton setTitle:kGrantAccess forState:UIControlStateNormal];
                    
                } else {
                    NSLog(@"Error Deleting Grant Access Activity");
                }
                
                //Re-Enable Button
                grantButton.enabled = YES;
                [grantButton endedTask];
                
            }];
        }];
        
        
    } else {
        PFObject *newActivity = [PFObject objectWithClassName:@"Activities"];
        newActivity[@"from"] = self.userForActivities;
        newActivity[@"to"] = grantButton.personToGrantAccess;
        newActivity[@"type"] = [NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY];
        newActivity[@"activityContent"] = grantButton.eventToGrantAccess;
        [newActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                EventObject *event = grantButton.eventToGrantAccess;
                
                PFRelation *attendingRelation = [event relationForKey:@"attenders"];
                [attendingRelation addObject:grantButton.personToGrantAccess];
                [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        grantButton.titleText = kRevokeAccess;

                    } else {
                        NSLog(@"Error saving relation");
                    }
                    
                    grantButton.enabled = YES;
                    [grantButton endedTask];

                    
                }];
                
                
            } else {
                
                NSLog(@"Error Saving New Grant Access Activity: %@", error);
                grantButton.enabled = YES;
                [grantButton endedTask];
            
            }

        }];
        
    }
}


- (void)tappedFollowButton:(id)sender {
    
    UIButtonPFExtended *followButton = (UIButtonPFExtended *)sender;
    [followButton startedTask];
    PFUser *userToChangeFollowState = followButton.personToFollow;
    
    followButton.enabled = NO;
    
    //Follow User or Unfollow User Depending on Current Button State
    if ([followButton.titleText isEqualToString:@"Following"]) {

        //Find and Delete Old Follow Activity
        PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
        [findFollowActivity whereKey:@"from" equalTo:[PFUser currentUser]];
        [findFollowActivity whereKey:@"to" equalTo:userToChangeFollowState];
        
        [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            PFObject *previousFollowActivity = [objects firstObject];
            [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                if (succeeded) {
                    
                    followButton.titleText = @"Follow";
                    
                    //Notify Profile View of Update
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Report This Error to aryan@evntr.co" message:error.description delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                    
                    [errorAlert show];
                }
                
                //Re-Enable Button
                followButton.enabled = YES;
                [followButton endedTask];
                
            }];
        }];
        
    } else if ([followButton.titleText isEqualToString:@"Follow"]) {
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        
        newFollowActivity[@"from"] = [PFUser currentUser];
        newFollowActivity[@"to"] = userToChangeFollowState;
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                followButton.titleText = @"Following";

                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:self userInfo:nil];
                
            } else {
                NSLog(@"Error in Saved");
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Report This Error to aryan@evntr.co" message:error.description delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                
                [errorAlert show];

            }
            
            //Re-Enable Button
            followButton.enabled = YES;
            [followButton endedTask];
        }];
    } else {
        NSLog(@"Weird error - need to notify user");
        followButton.enabled = YES;
        [followButton endedTask];
    }
}


@end

