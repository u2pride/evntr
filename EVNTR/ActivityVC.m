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
#import "EVNUtility.h"
#import "EventDetailVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import "EVNNotifcationsTitleView.h"


@interface ActivityVC ()

@property (nonatomic) EVNNoResultsView *noResultsView;
@property (nonatomic, strong) NSString *navigationBarTitleText;
@property (nonatomic, strong) UILabel *titleLabel;

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
        self.userForActivities = [EVNUser currentUser];
        self.objectsPerPage = 15;
        _typeOfActivityView = ACTIVITIES_ALL;
        
    }
    
    return self;
    
}


- (void) setNavigationBarTitleText:(NSString *)navigationBarTitleText {
    
    UIFont *boldFont = [UIFont fontWithName:@"Lato-Bold" size:kFontSize];
    UIFont *regularFont = [UIFont fontWithName:@"Lato-Regular" size:kFontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    // Create the attributes
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    //NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
    //                          [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
    //                          boldFont, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    //const NSRange range = NSMakeRange(14, 1);
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  v", navigationBarTitleText] attributes:attrs];
    //[attributedText setAttributes:subAttrs range:range];
    
    // Set it in our UILabel and we are done!
    [self.titleLabel setAttributedText:attributedText];
    [self.titleLabel sizeToFit];

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
            
            self.titleLabel = [UILabel new];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.navigationBarTitleText = @"Notifications";

            self.titleLabel.userInteractionEnabled = YES;
            //self.navigationItem.titleView = self.titleLabel;
            
            
            EVNNotifcationsTitleView *titleForNotifications = [[EVNNotifcationsTitleView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
            titleForNotifications.backgroundColor = [UIColor clearColor];
            self.navigationItem.titleView = titleForNotifications;
            
            
            UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterActivityTable)];
            tapgr.numberOfTapsRequired = 1;
            tapgr.numberOfTouchesRequired = 1;
            tapgr.delegate = self;
            [self.navigationItem.titleView addGestureRecognizer:tapgr];
            
            
            /* sample code
             
             NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
             [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"test "
             attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)}]];
             [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"s"
             attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
             NSBackgroundColorAttributeName: [UIColor clearColor]}]];
             [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"tring"]];
             */
            
            
            
            /*
            NSString *baseString = @"Notifications ";
            //NSString *fullString = [baseString stringByAppendingString:@"\u25BC"];
            

            
            NSDictionary *moreAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                             NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:kFontSize],
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            
            
            NSAttributedString *downCarrot = [[NSAttributedString alloc] initWithString:@"v" attributes:moreAttributes];
            
            
            NSString *fullString = [baseString stringByAppendingString:downCarrot.string];
            
            
            
            titleLabel.text = fullString;
            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleLabel.text attributes:attributes];
            [titleLabel sizeToFit];
            self.navigationItem.titleView = titleLabel;
            */
            
            //NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
            //[attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Notifications" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];

            
            //NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            
            //NSString *notificationsTitle = @"Notifications";
            //NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:notificationsTitle attributes:underlineAttribute];
            //self.navigationItem.title = attributedString.string;
            //self.navigationItem.title = @"Notifications";
            break;
        }
        case ACTIVITIES_INVITES: {
            
            /*
            UILabel *titleLabel = [UILabel new];
            titleLabel.text = @"Invites";
            NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                         NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:20.0],
                                         NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title attributes:attributes];
            [titleLabel sizeToFit];
            self.navigationItem.titleView = titleLabel;
            */
            
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
    
    //TODO - use dot notation to fetch further objects for example... from.profilePicture so we don't have to do this later..

    NSLog(@"Building the query");
    
    PFQuery *queryForActivities = [PFQuery queryWithClassName:@"Activities"];
    [queryForActivities orderByDescending:@"updatedAt"];

    //Build the query for the table
    switch (self.typeOfActivityView) {
        case ACTIVITIES_ALL: {
            //[queryForActivities whereKey:@"type" notEqualTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            
            PFQuery *coreActivities = [PFQuery queryWithClassName:@"Activities"];
            [coreActivities whereKey:@"to" equalTo:self.userForActivities];
            //[coreActivities includeKey:@"to"];
            //[coreActivities includeKey:@"from"];
            //[coreActivities includeKey:@"activityContent"];
            
            PFQuery *requestsToEvents = [PFQuery queryWithClassName:@"Activities"];
            [requestsToEvents whereKey:@"from" equalTo:self.userForActivities];
            [requestsToEvents whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            //[requestsToEvents includeKey:@"to"];
            //[requestsToEvents includeKey:@"from"];
            //[requestsToEvents includeKey:@"activityContent"];

            
            //PFQuery *coreActivities = [PFQuery queryWithClassName:@"Activities"];
            //[queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            //[queryForActivities includeKey:@"to"];
            //[queryForActivities includeKey:@"from"];
            //[queryForActivities includeKey:@"activityContent"];
            
            
            queryForActivities = [PFQuery orQueryWithSubqueries:@[coreActivities,requestsToEvents]];
            [queryForActivities includeKey:@"to"];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];

            
            // 3 - {from} requested that {to} give access to {activityContent}

            // {to} - current user therefore Michael has requested access to Camping {}
            // {from} - current user therefore You were added to the Standby list for Hiking
            
            break;
        }
        case ACTIVITIES_INVITES: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
            
            break;
        }
        case ACTIVITIES_REQUESTS_TO_ME: {
            //list of people that want access to your events
            //query activities where
            
            //TODO - Unnecessarily complex query
            
            //Get all events by User
            PFQuery *innerQueryForAuthor = [PFQuery queryWithClassName:@"Events"];
            [innerQueryForAuthor whereKey:@"parent" equalTo:[EVNUser currentUser]];
            
            //Get all request access activities
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            
            //now find access activities that are from the current user
            [queryForActivities whereKey:@"activityContent" matchesQuery:innerQueryForAuthor];
            
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];

            
            break;
        }
        case ACTIVITIES_ATTENDED: {
            [queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            [queryForActivities includeKey:@"to"];
            [queryForActivities includeKey:@"activityContent"];
            
            break;
        }
        case ACTIVITIES_MY_REQUESTS_STATUS: {
            
            PFQuery *grantedAccessActivities = [PFQuery queryWithClassName:@"Activities"];
            [grantedAccessActivities whereKey:@"to" equalTo:self.userForActivities];
            [grantedAccessActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            
            
            PFQuery *requestsToEvents = [PFQuery queryWithClassName:@"Activities"];
            [requestsToEvents whereKey:@"from" equalTo:self.userForActivities];
            [requestsToEvents whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];

            
            
            queryForActivities = [PFQuery orQueryWithSubqueries:@[grantedAccessActivities,requestsToEvents]];
            [queryForActivities includeKey:@"to"];
            [queryForActivities includeKey:@"from"];
            [queryForActivities includeKey:@"activityContent"];
            [queryForActivities orderByDescending:@"updatedAt"];
            
            //[queryForActivities whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            //[queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            //[queryForActivities includeKey:@"from"];
            //[queryForActivities includeKey:@"activityContent"];
            
            break;
        }
        default:
            [queryForActivities whereKey:@"to" equalTo:self.userForActivities];
            
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
    self.noResultsView.actionButton.hidden = YES;
    
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
    
    activityCell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    //Remove Old Gestures and Targets from the Cell
    for (UIGestureRecognizer *recognizer in activityCell.leftSideImageView.gestureRecognizers) {
        NSLog(@"Removing Gesture...");
        [activityCell.leftSideImageView removeGestureRecognizer:recognizer];
    }
    
    [activityCell.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    
    switch (activityType) {
        case FOLLOW_ACTIVITY: {
            
            EVNUser *userFollow = object[@"from"];
            
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
            [followActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
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
            
            EVNUser *userInvite = (EVNUser *) object[@"from"];
            
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
            activityCell.actionButton.eventToView = eventInvitedTo;
            [activityCell.actionButton setIsSelected:NO];
            
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            [activityCell.actionButton setIsSelected:NO];
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            
            break;
        }
        case REQUEST_ACCESS_ACTIVITY: {
            
            EVNUser *fromUser = object[@"from"];
            
            //Current User is On the Standby List
            if ([fromUser.objectId isEqualToString:[EVNUser currentUser].objectId]) {
                
                EventObject *eventToAccess = (EventObject *) object[@"activityContent"];
                
                //Left Image Configuration
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
                
                EVNUser *userRequestedAccess = (EVNUser *) object[@"from"];
                EventObject *eventToAccess = (EventObject *) object[@"activityContent"];
                
                //Left Image Configuration
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
                [grantedActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
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
                


            }
            
            break;
        }
        case ATTENDING_ACTIVITY: {
            
            EVNUser *userAttend = object[@"to"];
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
                    
                } else if (dateComparison == NSOrderedDescending) {
                    activityDescriptionString = [NSString stringWithFormat:@"You went to %@", eventToAttend.title];
                    
                } else {
                    activityDescriptionString = @"Failed comparison";
                }
                
            } else {
                
                if (dateComparison == NSOrderedAscending) {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ is going to %@", self.userForActivities[@"username"], eventToAttend.title];
                    
                } else if (dateComparison == NSOrderedDescending) {
                    activityDescriptionString = [NSString stringWithFormat:@"%@ went to %@", self.userForActivities[@"username"], eventToAttend.title];
                    
                } else {
                    activityDescriptionString = @"Failed comparison2";
                    
                }
            
            }
            
            activityCell.activityContentTextLabel.text = activityDescriptionString;
            
            
            //Right Action Button
            activityCell.actionButton.titleText = @"View";
            [activityCell.actionButton setIsSelected:NO];
            activityCell.actionButton.eventToView = eventToAttend;
            
            [activityCell.actionButton addTarget:self action:@selector(viewEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            break;
        }
        case ACCESS_GRANTED_ACTIVITY: {
            
            EVNUser *userGrantedAccess = (EVNUser *) object[@"from"];
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
            [activityCell.actionButton setIsSelected:NO];
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
#pragma mark - Filter Activity Table Type

- (void) filterActivityTable {
    
    NSLog(@"Filter Activity Table");
    
    UIAlertController *filterOptions = [UIAlertController alertControllerWithTitle:@"Notification Types" message:@"Select the notifications you want to see" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *eventsAttendedAction = [UIAlertAction actionWithTitle:@"Events Attended" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_ATTENDED;
        self.navigationBarTitleText = @"Attended";
        [self loadObjects];
    }];
    
    UIAlertAction *accessRequestsAction = [UIAlertAction actionWithTitle:@"Requests to Your Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_REQUESTS_TO_ME;
        self.navigationBarTitleText = @"Requests";
        [self loadObjects];
    }];
    
    UIAlertAction *accessResponsesAction = [UIAlertAction actionWithTitle:@"Your Requests to Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_MY_REQUESTS_STATUS;
        self.navigationBarTitleText = @"Responses";
        [self loadObjects];
    }];
    
    UIAlertAction *invitationsAction = [UIAlertAction actionWithTitle:@"Invitations to Events" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_INVITES;
        self.navigationBarTitleText = @"Invitations";
        [self loadObjects];
    }];
    
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"All Notifications" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.typeOfActivityView = ACTIVITIES_ALL;
        self.navigationBarTitleText = @"Notifications";
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


#pragma mark - 
#pragma mark - Target-Action Method Implementations

//View User Profile When Profile Image on Left Side is Selected
- (void)viewProfile:(UITapGestureRecognizer *)tapgr {
    
    ImageViewPFExtended *tappedImage = (ImageViewPFExtended *)tapgr.view;
    EVNUser *userProfle = (EVNUser *)tappedImage.objectForImageView;
    
    ProfileVC *followerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    followerProfileVC.userObjectID = userProfle.objectId;
    
    [self.navigationController pushViewController:followerProfileVC animated:YES];

}

- (void)viewEvent:(id)sender {
    
    
    UIButtonPFExtended *viewButton = (UIButtonPFExtended *)sender;
    EventObject *object = viewButton.eventToView;
    
    NSLog(@"View Event with - %@", object);

    EventDetailVC *eventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    
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
                    
                    EventObject *event = grantButton.eventToGrantAccess;
                    PFRelation *attendingRelation = [event relationForKey:@"attenders"];
                    [attendingRelation removeObject:grantButton.personToGrantAccess];
                    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            grantButton.titleText = kGrantAccess;
                        }
                        
                    }];
                    
                    
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
    EVNUser *userToChangeFollowState = followButton.personToFollow;
    
    followButton.enabled = NO;
    [followButton startedTask];

    //Follow User or Unfollow User Depending on Current Button State
    if ([followButton.titleText isEqualToString:@"Following"]) {

        UIAlertController *unfollowSheet = [UIAlertController alertControllerWithTitle:userToChangeFollowState.username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *unfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            //Find and Delete Old Follow Activity
            PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
            
            [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [findFollowActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
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
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            followButton.enabled = YES;
            [followButton endedTask];
            
        }];
        
        
        [unfollowSheet addAction:unfollow];
        [unfollowSheet addAction:cancelAction];
        
        [self presentViewController:unfollowSheet animated:YES completion:nil];
        
        
    } else if ([followButton.titleText isEqualToString:@"Follow"]) {
        
        
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        
        newFollowActivity[@"from"] = [EVNUser currentUser];
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

