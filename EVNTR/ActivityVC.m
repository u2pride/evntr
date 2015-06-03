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
#import "EVNNotifcationsTitleView.h"
#import "EVNUtility.h"
#import "EventDetailVC.h"
#import "MBProgressHUD.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"


@interface ActivityVC ()

@property (nonatomic) EVNNoResultsView *noResultsView;
@property (nonatomic) CGPoint scrollViewOffset;
@property (nonatomic) BOOL userScrolledUp;
@property (nonatomic, strong) NSTimer *timerForAutomaticUpdates;

@property (nonatomic, strong) NSDate *primaryUpdateTimestamp;
@property (nonatomic, strong) NSDate *secondaryUpdateTimestamp;

@property (nonatomic, strong) EVNNotifcationsTitleView *activityTitleText;
@property (nonatomic, strong) MBProgressHUD *loadingIndicator;

@end

@implementation ActivityVC

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Activity";
        self.parseClassName = @"Activities";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.userForActivities = [EVNUser currentUser];
        self.objectsPerPage = 15;
        _typeOfActivityView = ACTIVITIES_ALL;
        _userScrolledUp = NO;
    }
    
    return self;
    
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCellsDueToFollow:) name:kNewFollow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCellsDueToUnfollow:) name:kNewUnfollow object:nil];

    
    self.scrollViewOffset = self.tableView.contentOffset;
    self.timerForAutomaticUpdates = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(backgroundActivityUpdate) userInfo:nil repeats:YES];
    self.refreshControl.tintColor = [UIColor orangeThemeColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kPrimaryUpdateTimestamp]) {
        self.primaryUpdateTimestamp = (NSDate *) [userDefaults objectForKey:kPrimaryUpdateTimestamp];
    } else {
        self.primaryUpdateTimestamp = [NSDate date];
    }
    
    if ([userDefaults objectForKey:kSecondaryUpdateTimestamp]) {
        self.secondaryUpdateTimestamp = (NSDate *) [userDefaults objectForKey:kSecondaryUpdateTimestamp];
    } else {
        self.secondaryUpdateTimestamp = [NSDate date];
    }
    
    //Needed for Dynamic Cell Heights
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
            
    self.activityTitleText = [[EVNNotifcationsTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    self.activityTitleText.backgroundColor = [UIColor clearColor];
    self.activityTitleText.titleText = @"Notifications";
    self.navigationItem.titleView = self.activityTitleText;
            
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterActivityTable)];
    tapgr.numberOfTapsRequired = 1;
    tapgr.numberOfTouchesRequired = 1;
    tapgr.delegate = self;
    [self.navigationItem.titleView addGestureRecognizer:tapgr];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.timerForAutomaticUpdates invalidate];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    self.userScrolledUp = NO;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}





- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Start Background Timer for Updates
    self.timerForAutomaticUpdates = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(backgroundActivityUpdate) userInfo:nil repeats:YES];
    
}


#pragma mark - Custom Getters

- (NSTimer *) timerForAutomaticUpdates {
    
    if (!_timerForAutomaticUpdates) {
        
        _timerForAutomaticUpdates = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:60] interval:15 target:self selector:@selector(backgroundActivityUpdate) userInfo:nil repeats:YES];
    }
    
    return _timerForAutomaticUpdates;
}



#pragma mark - New Follow Notiification

- (void) checkCellsDueToFollow:(NSNotification *)followNotification {
    
    if (followNotification.object != self) {
        
        NSString *followUserID = [followNotification.userInfo objectForKey:kFollowedUserObjectId];
        
        for (PFObject *activityObject in self.objects) {
            
            if ([[activityObject objectForKey:@"type"] intValue] == FOLLOW_ACTIVITY) {
                
                PFObject *objectForKeyID = (PFObject *) [activityObject objectForKey:@"userFrom"];
                
                if ([objectForKeyID.objectId isEqualToString:followUserID]) {
                    
                    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:activityObject] inSection:0];
                    
                    ActivityTableCell *cell = (ActivityTableCell *) [self.tableView cellForRowAtIndexPath:cellIndexPath];
                    
                    cell.actionButton.titleText = kFollowingString;
                    [cell.actionButton setIsSelected:YES];
                    
                }
            }
        }
    }
}


- (void) checkCellsDueToUnfollow:(NSNotification *)unFollowNotification {
    
    if (unFollowNotification.object != self) {
        
        NSString *unFollowUserID = [unFollowNotification.userInfo objectForKey:kUnfollowedUserObjectId];
        
        for (PFObject *activityObject in self.objects) {
            
            if ([[activityObject objectForKey:@"type"] intValue] == FOLLOW_ACTIVITY) {
                
                PFObject *objectForKeyID = (PFObject *) [activityObject objectForKey:@"userFrom"];
                
                if ([objectForKeyID.objectId isEqualToString:unFollowUserID]) {
                    
                    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:activityObject] inSection:0];
                    
                    ActivityTableCell *cell = (ActivityTableCell *) [self.tableView cellForRowAtIndexPath:cellIndexPath];
                    
                    cell.actionButton.titleText = kFollowString;
                    [cell.actionButton setIsSelected:NO];
                }
            }
        }
    }
}


#pragma mark - Parse UITableView Methods

- (PFQuery *)queryForTable {
    
    PFQuery *queryForActivities = [PFQuery queryWithClassName:@"Activities"];
    [queryForActivities orderByDescending:@"updatedAt"];

    switch (self.typeOfActivityView) {
        case ACTIVITIES_ALL: {
            
            PFQuery *coreActivities = [PFQuery queryWithClassName:@"Activities"];
            [coreActivities whereKey:@"userTo" equalTo:self.userForActivities];
            
            PFQuery *requestsToEvents = [PFQuery queryWithClassName:@"Activities"];
            [requestsToEvents whereKey:@"userFrom" equalTo:self.userForActivities];
            [requestsToEvents whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            
            queryForActivities = [PFQuery orQueryWithSubqueries:@[coreActivities,requestsToEvents]];
            [queryForActivities includeKey:@"userTo"];
            [queryForActivities includeKey:@"userFrom"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        case ACTIVITIES_INVITES: {
            
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
            [queryForActivities whereKey:@"userTo" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"userFrom"];
            [queryForActivities includeKey:@"activityContent"];
            
            break;
        }
        case ACTIVITIES_REQUESTS_TO_ME: {
            
            //Get all events by User
            PFQuery *innerQueryForAuthor = [PFQuery queryWithClassName:@"Events"];
            [innerQueryForAuthor whereKey:@"parent" equalTo:[EVNUser currentUser]];
            
            //Get all request access activities
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            [queryForActivities whereKey:@"userTo" equalTo:self.userForActivities];
            
            //now find access activities that are from the current user
            [queryForActivities whereKey:@"activityContent" matchesQuery:innerQueryForAuthor];
            
            [queryForActivities includeKey:@"userFrom"];
            [queryForActivities includeKey:@"activityContent"];

            break;
        }
        case ACTIVITIES_ATTENDED: {
            
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForActivities whereKey:@"userTo" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"userTo"];
            [queryForActivities includeKey:@"activityContent"];
            
            break;
        }
        case ACTIVITIES_MY_REQUESTS_STATUS: {
            
            PFQuery *grantedAccessActivities = [PFQuery queryWithClassName:@"Activities"];
            [grantedAccessActivities whereKey:@"userTo" equalTo:self.userForActivities];
            [grantedAccessActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            
            PFQuery *requestsToEvents = [PFQuery queryWithClassName:@"Activities"];
            [requestsToEvents whereKey:@"userFrom" equalTo:self.userForActivities];
            [requestsToEvents whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            
            queryForActivities = [PFQuery orQueryWithSubqueries:@[grantedAccessActivities,requestsToEvents]];
            [queryForActivities includeKey:@"userTo"];
            [queryForActivities includeKey:@"userFrom"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            break;
        }
        default:
            
            [queryForActivities whereKey:@"userTo" equalTo:self.userForActivities];
            
            break;
    }
    
    
    return queryForActivities;
    
}

- (void) objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    [self stopLoadingIndicator];
    
    if (self.objects.count == 0) {
        [self showNoResultsView];
    } else {
        self.noResultsView.hidden = YES;
    }
    
    //Update App Delegate of Latest Activity Pull
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setValue:[NSDate date] forKey:kLastBackgroundFetchTimeStamp];
    
    //Table Load Performed in Background
    if (self.timerForAutomaticUpdates.valid) {
        
        int newObjectsCount = 0;
        for (PFObject *notificationObject in self.objects) {
            
            NSComparisonResult dateCompare = [notificationObject.createdAt compare:self.secondaryUpdateTimestamp];
            
            if (dateCompare == NSOrderedDescending) {
                newObjectsCount++;
            }
        }
        
        if (newObjectsCount == 0) {
            [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];

        } else {
            [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d", newObjectsCount]];
        }
    }
    
}


#pragma mark - Helper Methods

- (void) showNoResultsView {
    
    if (!self.noResultsView) {
        self.noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
        self.noResultsView.headerText = @"A Little Empty...";
        self.noResultsView.subHeaderText = @"Looks like there's no activity yet.  Once you start attending and creating events, you'll see your activity in here.";
        self.noResultsView.actionButton.hidden = YES;
        
        [self.view addSubview:self.noResultsView];
    }
    
    self.noResultsView.hidden = NO;
}

- (void) hideNoResultsView {
    
    [self.noResultsView removeFromSuperview];
    
}

- (void) startLoadingIndicator {
    
    if (!self.loadingIndicator) {
        
        self.loadingIndicator = [[MBProgressHUD alloc] init];
        self.loadingIndicator.removeFromSuperViewOnHide = YES;
        self.loadingIndicator.center = self.view.center;
        self.loadingIndicator.dimBackground = NO;
        [self.view addSubview:self.loadingIndicator];
        
    }
    
    [self.loadingIndicator show:YES];
    
}

- (void) stopLoadingIndicator {
    
    if (self.loadingIndicator) {
        [self.loadingIndicator hide:YES];
    }
    
}

- (void) backgroundActivityUpdate {
    
    self.typeOfActivityView = ACTIVITIES_ALL;
    [self loadObjects];
    
}


- (void) updateRefreshTimestampWithDate:(NSDate *)updatedDate {
    
    self.secondaryUpdateTimestamp = self.primaryUpdateTimestamp;
    
    self.primaryUpdateTimestamp = updatedDate;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.primaryUpdateTimestamp forKey:kPrimaryUpdateTimestamp];
    [userDefaults setObject:self.secondaryUpdateTimestamp forKey:kSecondaryUpdateTimestamp];
    
    [userDefaults synchronize];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint newScrollOffset = scrollView.contentOffset;
    
    if (newScrollOffset.y > self.scrollViewOffset.y) {
        //empty
    } else {
        self.userScrolledUp = YES;
        [self updateRefreshTimestampWithDate:[NSDate date]];
        
    }
    
    self.scrollViewOffset = newScrollOffset;
    
}
    

#pragma mark - UITableView Datasource Methods

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"activityCell";

    ActivityTableCell *activityCell = (ActivityTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //Initial Cell Configuration
    activityCell.leftSideImageView.image = [UIImage imageNamed:@"PersonDefault"];
    NSDate *createdAtDate = object.createdAt;
    activityCell.timestampActivity.text = [createdAtDate formattedAsTimeAgo];
    activityCell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);

    //Determine if Cell Should be Highlighted as a New Notification
    NSComparisonResult dateCompare = [createdAtDate compare:self.secondaryUpdateTimestamp];
    if (dateCompare == NSOrderedDescending && !self.userScrolledUp) {
        [activityCell highlightCellForNewNotification];
    }
    
    //Remove Old Gestures and Targets from the Cell
    for (UIGestureRecognizer *recognizer in activityCell.leftSideImageView.gestureRecognizers) {
        [activityCell.leftSideImageView removeGestureRecognizer:recognizer];
    }
    [activityCell.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    
    int activityType = (int) [[object objectForKey:@"type"] integerValue];
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            
            EVNUser *userFollow = object[@"userFrom"];
            
            //Left Image Thumbnail
            activityCell.leftSideImageView.file = userFollow[@"profilePicture"];
            [activityCell.leftSideImageView loadInBackground];
            
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userFollow;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            //Main Text Message
            NSString *textForActivityCell = [NSString stringWithFormat:@"%@ followed you.", userFollow.username];
            activityCell.activityContentTextLabel.text = textForActivityCell;
            
            //Right Action Button
            PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
            [followActivity whereKey:@"userFrom" equalTo:[EVNUser currentUser]];
            [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [followActivity whereKey:@"userTo" equalTo:userFollow];
            [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if ([objects count] == 0 || error) {
                    activityCell.actionButton.titleText = kFollowString;
                    activityCell.actionButton.personToFollow = userFollow;
                    [activityCell.actionButton setIsSelected:NO];
                    
                } else {
                    activityCell.actionButton.titleText = kFollowingString;
                    [activityCell.actionButton setIsSelected:YES];
                    activityCell.actionButton.personToFollow = userFollow;
                    
                }
                
                if (!error) {
                    [activityCell.actionButton addTarget:self action:@selector(tappedFollowButton:) forControlEvents:UIControlEventTouchUpInside];
                }
                
            }];
        
            
            break;
        }
        case INVITE_ACTIVITY: {
            
            EVNUser *userInvite = (EVNUser *) object[@"userFrom"];
            
            __block NSString *username = userInvite[@"username"];
            
            //Left Image Thumbnail
            activityCell.leftSideImageView.file = userInvite[@"profilePicture"];
            [activityCell.leftSideImageView loadInBackground];
            
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userInvite;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            //Main Text Message
            EventObject *eventInvitedTo = (EventObject *) object[@"activityContent"];
            activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ invited you to %@", username, eventInvitedTo.title];
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            activityCell.actionButton.eventToView = eventInvitedTo;
            [activityCell.actionButton setIsSelected:NO];
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            
            break;
        }
        case REQUEST_ACCESS_ACTIVITY: {
            
            EVNUser *fromUser = object[@"userFrom"];
            
            //Current User is On the Standby List
            if ([fromUser.objectId isEqualToString:[EVNUser currentUser].objectId]) {
                
                EventObject *eventToAccess = (EventObject *) object[@"activityContent"];
                
                //Left Image Thumbnail
                activityCell.leftSideImageView.file = [EVNUser currentUser][@"profilePicture"];
                [activityCell.leftSideImageView loadInBackground];
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = [EVNUser currentUser];
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                //Main Text Message
                activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"You showed interest in %@", eventToAccess.title];
                
                //Right Button Configuration
                activityCell.actionButton.eventToView = eventToAccess;
                activityCell.actionButton.titleText = @"View";
                [activityCell.actionButton setIsSelected:NO];
                [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
                
        
            //Current User Has a Request for Access to An Event
            } else {
                
                EVNUser *userRequestedAccess = (EVNUser *) object[@"userFrom"];
                EventObject *eventToAccess = (EventObject *) object[@"activityContent"];
                
                //Left Image Thumbnail
                activityCell.leftSideImageView.file = userRequestedAccess[@"profilePicture"];
                [activityCell.leftSideImageView loadInBackground];
                
                activityCell.leftSideImageView.userInteractionEnabled = YES;
                activityCell.leftSideImageView.objectForImageView = userRequestedAccess;
                UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
                [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
                
                //Main Text Message
                activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ requested access to %@", userRequestedAccess.username, eventToAccess.title];
                
                //Right Button Configuration
                activityCell.actionButton.personToGrantAccess = userRequestedAccess;
                activityCell.actionButton.eventToGrantAccess = eventToAccess;
                
                PFQuery *grantedActivity = [PFQuery queryWithClassName:@"Activities"];
                [grantedActivity whereKey:@"userFrom" equalTo:[EVNUser currentUser]];
                [grantedActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
                [grantedActivity whereKey:@"userTo" equalTo:userRequestedAccess];
                [grantedActivity whereKey:@"activityContent" equalTo:eventToAccess];
                [grantedActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if ([objects count] == 0 || error) {
                        activityCell.actionButton.titleText = kGrantAccess;
                        [activityCell.actionButton setIsSelected:NO];
                    } else {
                        activityCell.actionButton.titleText = kRevokeAccess;
                        [activityCell.actionButton setIsSelected:YES];
                    }
                    
                    if (!error) {
                        [activityCell.actionButton addTarget:self action:@selector(grantAccess:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                }];

            }
            
            break;
        }
        case ATTENDING_ACTIVITY: {
            
            EVNUser *userAttend = object[@"userTo"];
            EventObject *eventToAttend = object[@"activityContent"];

            //Left Image Thumbnail
            activityCell.leftSideImageView.file = userAttend[@"profilePicture"];
            [activityCell.leftSideImageView loadInBackground];
            
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userAttend;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            //Main Text Message
            NSString *activityDescriptionString;
            NSDate *currentDate = [NSDate date];
            NSComparisonResult dateComparison = [currentDate compare:eventToAttend.dateOfEvent];
            
            //Build the description string based off Time of Event and Current User
            if ([self.userForActivities.objectId isEqualToString:[EVNUser currentUser].objectId] ) {
                
                if (dateComparison == NSOrderedAscending) {
                    activityDescriptionString = [NSString stringWithFormat:@"You're going to %@", eventToAttend.title];
                    
                } else {
                    activityDescriptionString = [NSString stringWithFormat:@"You went to %@", eventToAttend.title];
                }
                
            } else {
                
                if (dateComparison == NSOrderedAscending) {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ is going to %@", self.userForActivities[@"username"], eventToAttend.title];
                    
                } else {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ went to %@", self.userForActivities[@"username"], eventToAttend.title];
                }
            
            }
            
            activityCell.activityContentTextLabel.text = activityDescriptionString;
            
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            activityCell.actionButton.eventToView = eventToAttend;
            [activityCell.actionButton setIsSelected:NO];
            
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            
            break;
        }
        case ACCESS_GRANTED_ACTIVITY: {
            
            EVNUser *userGrantedAccess = (EVNUser *) object[@"userFrom"];
            EventObject *eventGrantedAccess = (EventObject *) object[@"activityContent"];
            
            //Left Side Thumbnail
            activityCell.leftSideImageView.file = userGrantedAccess[@"profilePicture"];
            [activityCell.leftSideImageView loadInBackground];
            
            activityCell.leftSideImageView.userInteractionEnabled = YES;
            activityCell.leftSideImageView.objectForImageView = userGrantedAccess;
            UITapGestureRecognizer *tapProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile:)];
            [activityCell.leftSideImageView addGestureRecognizer:tapProfileImage];
            
            //Main Text Message
            activityCell.activityContentTextLabel.text = [NSString stringWithFormat:@"%@ let you in to %@", userGrantedAccess.username, eventGrantedAccess.title];
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            activityCell.actionButton.eventToView = eventGrantedAccess;
            [activityCell.actionButton setIsSelected:NO];
            
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
        
            break;
        }
        default: {
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"That's Weird" message:@"Looks like something broke.  Send us an email/tweet and we'll help you figure out what happened." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [message show];
            
            break;
        }
    }
    
    
    [activityCell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return activityCell;
    
}


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
}


#pragma mark - Filter Activity Table Type

- (void) filterActivityTable {
    
    UIAlertController *filterOptions = [UIAlertController alertControllerWithTitle:@"Notification Types" message:@"Select the notifications you want to see" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *eventsAttendedAction = [UIAlertAction actionWithTitle:@"Events Attended" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_ATTENDED;
        self.activityTitleText.titleText = @"Attended";
        [self startLoadingIndicator];
        [self loadObjects];
    }];
    
    UIAlertAction *accessRequestsAction = [UIAlertAction actionWithTitle:@"Requests to Your Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_REQUESTS_TO_ME;
        self.activityTitleText.titleText = @"Requests";
        [self startLoadingIndicator];
        [self loadObjects];
    }];
    
    UIAlertAction *accessResponsesAction = [UIAlertAction actionWithTitle:@"Your Requests to Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_MY_REQUESTS_STATUS;
        self.activityTitleText.titleText = @"Responses";
        [self startLoadingIndicator];
        [self loadObjects];
    }];
    
    UIAlertAction *invitationsAction = [UIAlertAction actionWithTitle:@"Invitations to Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_INVITES;
        self.activityTitleText.titleText = @"Invites";
        [self startLoadingIndicator];
        [self loadObjects];
    }];
    
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"All Notifications" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_ALL;
        self.activityTitleText.titleText = @"Notifications";
        [self startLoadingIndicator];
        [self loadObjects];
    }];
    
    [filterOptions addAction:eventsAttendedAction];
    [filterOptions addAction:accessRequestsAction];
    [filterOptions addAction:accessResponsesAction];
    [filterOptions addAction:invitationsAction];
    [filterOptions addAction:allAction];
    
    filterOptions.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:filterOptions animated:YES completion:nil];
    
}


#pragma mark - User Performed Actions

- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    EVNUser *userProfle = (EVNUser *)tappedImage.objectForImageView;
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userObjectID = userProfle.objectId;
    
    [self.navigationController pushViewController:followerProfileVC animated:YES];

}

- (void)viewEvent:(id)sender {
    
    EVNButtonExtended *viewButton = (EVNButtonExtended *)sender;
    EventObject *object = viewButton.eventToView;
    
    EventDetailVC *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    
    eventDetailsVC.event = object;
    
    [self.navigationController pushViewController:eventDetailsVC animated:YES];
    
    [viewButton setIsSelected:NO];
    
}

- (void)tappedFollowButton:(id)sender {
    
    EVNButtonExtended *followButton = (EVNButtonExtended *)sender;
    
    [[EVNUser currentUser] followUser:followButton.personToFollow fromVC:self withButton:followButton withCompletion:^(BOOL success) {}];
    
}

- (void)grantAccess:(id)sender {
        
    EVNButtonExtended *grantButton = (EVNButtonExtended *)sender;
    [grantButton startedTask];
    
    NSString *grantState = grantButton.titleText;
    
    //Grant Access to User or Revoke Access to User Depending on Current Button State
    if ([grantState isEqualToString:kRevokeAccess]) {
        
        //Find and Delete Old Granted Access Activity
        PFQuery *findGrantActivity = [PFQuery queryWithClassName:@"Activities"];
        
        [findGrantActivity whereKey:@"userFrom" equalTo:self.userForActivities];
        [findGrantActivity whereKey:@"userTo" equalTo:grantButton.personToGrantAccess];
        [findGrantActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
        [findGrantActivity whereKey:@"activityContent" equalTo:grantButton.eventToGrantAccess];
        
        [findGrantActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error && [objects count] > 0) {
                
                PFObject *previousGrantActivity = [objects firstObject];
                [previousGrantActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded){
                        
                        grantButton.titleText = kGrantAccess;
                        [grantButton endedTask];
                        
                    } else {
                        [grantButton endedTaskWithButtonEnabled:NO];
                    }
                    
                }];
            
            } else  {
                
                [grantButton endedTaskWithButtonEnabled:NO];
                
            }
        
        }];
        
    } else {
        
        PFObject *newActivity = [PFObject objectWithClassName:@"Activities"];
        newActivity[@"userFrom"] = self.userForActivities;
        newActivity[@"userTo"] = grantButton.personToGrantAccess;
        newActivity[@"type"] = [NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY];
        newActivity[@"activityContent"] = grantButton.eventToGrantAccess;
        [newActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                grantButton.titleText = kRevokeAccess;
                [grantButton endedTask];
                
            } else {
                
                [PFAnalytics trackEventInBackground:@"GrantAccessIssue" block:nil];

                grantButton.alpha = 0.3;
                [grantButton endedTaskWithButtonEnabled:NO];
            }

        }];
        
    }
}



#pragma mark - CleanUp

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timerForAutomaticUpdates invalidate];
}

@end

