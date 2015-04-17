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
        self.objectsPerPage = 15;
        _typeOfActivityView = ACTIVITIES_ALL;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
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
            [queryForActivities includeKey:@"to"];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_INVITES: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
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
            
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];

            
            break;
        }
        case ACTIVITIES_ATTENDED: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"to"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_MY_REQUESTS_STATUS: {
            
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
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
    } else {
        self.noResultsView.hidden = YES;
    }
    
    //TODO - Badge Values - Reset App Badge and Tab Bar Badge
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
    
    //Remove Old Gestures and Targets from the Cell
    for (UIGestureRecognizer *recognizer in activityCell.leftSideImageView.gestureRecognizers) {
        NSLog(@"Removing Gesture...");
        [activityCell.leftSideImageView removeGestureRecognizer:recognizer];
    }
    
    [activityCell.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            
            PFUser *userFollow = object[@"from"];
            
            //Left Image Thumbnail
            PFFile *profilePictureFromParse = userFollow[@"profilePicture"];
            [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userFollow;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            
            //Main Text Message
            NSString *textForActivityCell = [NSString stringWithFormat:@"%@ followed you.", userFollow.username];
            activityCell.activityContentTextLabel.text = textForActivityCell;
            
            
            //Right Action Button
            PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
            [followActivity whereKey:@"from" equalTo:[PFUser currentUser]];
            [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [followActivity whereKey:@"to" equalTo:userFollow];
            [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!objects || !objects.count) {
                    activityCell.actionButton.titleText = @"Follow";
                    activityCell.actionButton.personToFollow = userFollow;
                    [activityCell.actionButton setIsSelected:NO];
                } else {
                    activityCell.actionButton.titleText = @"Following";
                    [activityCell.actionButton setIsSelected:YES];
                    activityCell.actionButton.personToFollow = userFollow;
                }
                
                [activityCell.actionButton addTarget:self action:@selector(tappedFollowButton:) forControlEvents:UIControlEventTouchUpInside];
                
            }];
            
            
            break;
        }
        case INVITE_ACTIVITY: {
            
            PFUser *userInvite = object[@"from"];
            
            __block NSString *username = userInvite[@"username"];
            
            
            //Left Image Thumbnail
            PFFile *profilePictureFromParse = userInvite[@"profilePicture"];
            [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userInvite;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            
            //Main Text Message
            PFObject *eventInvitedTo = object[@"activityContent"];
            NSLog(@"eventInvitedTo: %@", eventInvitedTo);
            [eventInvitedTo fetchInBackgroundWithBlock:^(PFObject *eventRetrieved, NSError *error) {
                
                EventObject *event = (EventObject *) eventRetrieved;
                
                if (!error) {

                    activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ invited you to %@", username, event.title];
                    activityCell.actionButton.eventToView = event;
                    [activityCell.actionButton setIsSelected:NO];
                    
                } else {
                    
                    //TODO - remove before release
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Send Feedback" message:@"Error in retrieving information from DB.  Contact developer at aryan@evntr.co" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                }
                
            }];
            
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
            activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
            activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
            activityCell.actionButton.backgroundColor = [UIColor clearColor];
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        }
        case REQUEST_ACCESS_ACTIVITY: {
            
            PFUser *userRequestedAccess = object[@"from"];
            EventObject *eventToAccess = (EventObject *) object[@"activityContent"];

            
            //Left Image Thumbnail
            PFFile *profilePictureFromParse = userRequestedAccess[@"profilePicture"];
            [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userRequestedAccess;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            
            //Main Text Message
            activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ requested access to %@", userRequestedAccess.username, eventToAccess.title];
            
            
            //Right Action Button
            activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
            activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
            activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
            activityCell.actionButton.backgroundColor = [UIColor clearColor];
            activityCell.actionButton.personToGrantAccess = userRequestedAccess;
            activityCell.actionButton.eventToGrantAccess = eventToAccess;
            
            
            PFQuery *grantedActivity = [PFQuery queryWithClassName:@"Activities"];
            [grantedActivity whereKey:@"from" equalTo:[PFUser currentUser]];
            [grantedActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [grantedActivity whereKey:@"to" equalTo:userRequestedAccess];
            [grantedActivity whereKey:@"activityContent" equalTo:eventToAccess];
            [grantedActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!objects || !objects.count) {
                    activityCell.actionButton.titleText = kGrantAccess;
                    [activityCell.actionButton setIsSelected:NO];
                    //[activityCell.actionButton setTitle:kGrantAccess forState:UIControlStateNormal];
                } else {
                    activityCell.actionButton.titleText = kRevokeAccess;
                    [activityCell.actionButton setIsSelected:YES];
                    //[activityCell.actionButton setTitle:kRevokeAccess forState:UIControlStateNormal];
                }
                
                [activityCell.actionButton addTarget:self action:@selector(grantAccess:) forControlEvents:UIControlEventTouchUpInside];
                
            }];
            
            break;
        }
        case ATTENDING_ACTIVITY: {
            
            PFUser *userForAttend = object[@"to"];
            EventObject *eventAttending = object[@"activityContent"];

            
            //Left Image Thumbnail
            PFFile *profilePicture = [userForAttend objectForKey:@"profilePicture"];
            [profilePicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userForAttend;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            
            //Main Text Message
            NSString *activityDescriptionString;
            NSDate *currentDate = [NSDate date];
            NSComparisonResult dateComparison = [currentDate compare:eventAttending.dateOfEvent];
            
            //Build the description string based off Time of Event and Current User
            if ([self.userForActivities.objectId isEqualToString:[PFUser currentUser].objectId] ) {
                
                if (dateComparison == NSOrderedAscending) {
                    activityDescriptionString = [NSString stringWithFormat:@"You're going to %@", eventAttending.title];
                    
                } else if (dateComparison == NSOrderedDescending) {
                    activityDescriptionString = [NSString stringWithFormat:@"You went to %@", eventAttending.title];
                    
                } else {
                    activityDescriptionString = @"Failed comparison";
                }
                
            } else {
                
                if (dateComparison == NSOrderedAscending) {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ is going to %@", self.userForActivities[@"username"], eventAttending.title];
                    
                } else if (dateComparison == NSOrderedDescending) {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ went to %@", self.userForActivities[@"username"], eventAttending.title];
                    
                } else {
                    activityDescriptionString = @"Failed comparison2";
                    
                }
                
                
            }
            
            activityCell.activityContentTextLabel.text = activityDescriptionString;
            
            
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            [activityCell.actionButton setIsSelected:NO];
            activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
            activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
            activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
            activityCell.actionButton.backgroundColor = [UIColor clearColor];
            activityCell.actionButton.eventToView = eventAttending;
            
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];

            
            break;
        }
        case ACCESS_GRANTED_ACTIVITY: {
            
            PFUser *userGrantedAccess = object[@"from"];
            EventObject *eventGrantedAccess = (EventObject *) object[@"activityContent"];

            
            //Left Side Thumbnail
            PFFile *profilePictureFromParse = userGrantedAccess[@"profilePicture"];
            [profilePictureFromParse getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    activityCell.leftSideImageView.image = [UIImage imageWithData:data];
                }
            }];
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userGrantedAccess;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            
            //Main Text Message
            activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ let you in to %@", userGrantedAccess.username, eventGrantedAccess.title];
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            [activityCell.actionButton setIsSelected:NO];
            activityCell.actionButton.layer.borderColor = [UIColor orangeThemeColor].CGColor;
            activityCell.actionButton.layer.borderWidth = BUTTON_BORDER_WIDTH;
            activityCell.actionButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
            activityCell.actionButton.backgroundColor = [UIColor clearColor];
            activityCell.actionButton.eventToView = eventGrantedAccess;

            
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        }
        default: {
            
            UIAlertView *errorAlert2 = [[UIAlertView alloc] initWithTitle:@"Error #3" message:@"Please submit feedback with this error number" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert2 show];

            
            break;
        }
    }
    
    [activityCell setSelectionStyle:UITableViewCellSelectionStyleNone];


    return activityCell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSLog(@"Did Select Row at Index Path - %@", indexPath);
    
}


#pragma mark - 
#pragma mark - Target-Action Method Implementations

//View User Profile When Profile Image on Left Side is Selected
- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    PFUser *userProfle = (PFUser *)tappedImage.objectForImageView;
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userObjectID = userProfle.objectId;
    
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

