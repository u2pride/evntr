//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteContainerVC.h"

#import "AppDelegate.h"
#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EventDetailVC.h"
#import "EventObject.h"
#import "EventTableCell.h"
#import "EVNUtility.h"
#import "FilterEventsVC.h"
#import "HomeScreenVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "SearchVC.h"
#import "TabNavigationVC.h"
#import "UIImageEffects.h"
#import "UIColor+EVNColors.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>

@interface HomeScreenVC ()

@property BOOL isGuestUser;

@property (nonatomic, strong) PFGeoPoint *currentUserLocation;
@property (nonatomic) float searchRadius;
@property (nonatomic, strong) EVNNoResultsView *noResultsView;

@property (nonatomic, strong) NSIndexPath *indexPathOfEventInDetailView;
@property (nonatomic, strong) EventObject *eventForInvites;


@end

@implementation HomeScreenVC

#pragma mark - Initialization Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.title = @"Events";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        _typeOfEventTableView = ALL_PUBLIC_EVENTS;
        self.tabBarController.hidesBottomBarWhenPushed = YES;
        
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        _isGuestUser = [standardDefaults boolForKey:kIsGuest];
        _searchRadius = 20.0;
    }
    
    return self;
    
}


#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
    self.refreshControl.tintColor = [UIColor orangeThemeColor];
    
    //stop Movie Player on Initial Screen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopMoviePlayer" object:nil];
    
    //Setup Search and Filter Bar Button Items
    if (!self.isGuestUser) {
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchController)];
        self.navigationItem.rightBarButtonItem = searchButton;
    }
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.f", self.searchRadius] style:UIBarButtonItemStylePlain target:self action:@selector(displayFilterView)];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    //Subscribe to Location Updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedLocation:) name:@"newLocationNotif" object:nil];
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            [self.navigationItem setTitle:@"Public Events"];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            [self.navigationItem setTitle:@"My Events"];
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItems = nil;

            break;
        }
        case OTHER_USER_EVENTS: {
            [self.navigationItem setTitle:@"User's Public Events"];
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItems = nil;
            
            break;
        }
        default:
            break;
    }

}

#pragma mark - User Actions

- (void)displaySearchController {
    
    [PFAnalytics trackEventInBackground:@"SearchFeatureAccessed" block:nil];
    
    SearchVC *searchController = (SearchVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    [self.navigationController pushViewController:searchController animated:YES];
    
    
}

- (void) displayFilterView {
    
    [PFAnalytics trackEventInBackground:@"FilterFeatureAccessed" block:nil];
    
    FilterEventsVC *filterVC = (FilterEventsVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    filterVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    filterVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    filterVC.selectedFilterDistance = [self.navigationItem.leftBarButtonItem.title floatValue];
    filterVC.delegate = self;
    
    [self.tabBarController presentViewController:filterVC animated:YES completion:nil];
    
}

#pragma mark - Filtering Delegate 

- (void) completedFiltering:(float)radius {

    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    
    self.searchRadius = radius;
    
    if (radius < 1) {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.01f", self.searchRadius];
    } else {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.f", self.searchRadius];
    }
    
    //Reload Events Table
    [self loadObjects];
    
}


#pragma mark - Location Notification

- (void) updatedLocation:(NSNotification *)notification {
    
    if (!self.currentUserLocation || self.currentUserLocation.latitude == 0.0) {
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
        
    } else {
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        //[self loadObjects];
    }
}


#pragma mark - Building Query

- (PFQuery *)queryForTable {
    
    //One Way to Do It
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.currentUserLocation = [PFGeoPoint geoPointWithLocation:appDelegate.locationManagerGlobal.location];
    
    //Ends up Grabbing the Last Location Stored if No Location in Location Manager
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userLocationDictionary = [userDefaults objectForKey:kLocationCurrent];
    
    NSNumber *latitude = [userLocationDictionary objectForKey:@"latitude"];
    NSNumber *longitude = [userLocationDictionary objectForKey:@"longitude"];
    
    if (userLocationDictionary && !self.currentUserLocation) {
        self.currentUserLocation = [PFGeoPoint geoPointWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    }
    
    //Wait Until A Location Is Found
    if (!self.currentUserLocation || self.currentUserLocation.latitude == 0.0) {
        return nil;
    }
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {

            NSArray *eventTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE], [NSNumber numberWithInt:PUBLIC_APPROVED_EVENT_TYPE], nil];

            [eventsQuery whereKey:@"typeOfEvent" containedIn:eventTypes];
            [eventsQuery whereKey:@"locationOfEvent" nearGeoPoint:self.currentUserLocation withinMiles:self.searchRadius];
            
            NSDate *currentDateMinusOneDay = [NSDate dateWithTimeIntervalSinceNow:-86400];
            [eventsQuery whereKey:@"dateOfEvent" greaterThanOrEqualTo:currentDateMinusOneDay]; /* Grab Events in the Future and Ones Within 24 Hours in Past */
            [eventsQuery orderByDescending:@"createdAt"];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            
            [eventsQuery whereKey:@"parent" equalTo:self.userForEventsQuery];
            [eventsQuery orderByDescending:@"createdAt"];
            
            break;
        }
        case OTHER_USER_EVENTS: {

            [eventsQuery whereKey:@"parent" equalTo:self.userForEventsQuery];
            NSArray *eventTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE], [NSNumber numberWithInt:PUBLIC_APPROVED_EVENT_TYPE], nil];
            [eventsQuery whereKey:@"typeOfEvent" containedIn:eventTypes];
            [eventsQuery orderByDescending:@"createdAt"];
            
            break;
        }
            
        default:
            break;
    }
    
    eventsQuery.limit = 50;
    
    return eventsQuery;
}


#pragma mark - PFQueryTableView DataSource and Delegate Methods

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0) {
        [self showNoResultsView];
    } else if (self.noResultsView) {
        [self hideNoResultsView];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 320;
}


- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"eventCell";
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    EventObject *event = (EventObject *)object;
    
    if (cell) {
        
        //Flagging
        for (UIGestureRecognizer *recognizer in cell.flagButton.gestureRecognizers) {
            [cell.flagButton removeGestureRecognizer:recognizer];
        }
        
        cell.flagButton.tag = indexPath.row;

        UITapGestureRecognizer *flagGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagEvent:)];
        [cell.flagButton addGestureRecognizer:flagGR];
        
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self refreshUIForCell:cell withEvent:event];
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.65 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        
        cell.alpha = 1;
        cell.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        
    }];
     
}

#pragma mark - No Results View and Helper Methods

- (void) refreshUIForCell:(EventTableCell *)cell withEvent:(EventObject *)eventForCell {
    
    cell.eventTitle.text = eventForCell.title;
    
    cell.eventTypeLabel.text = [eventForCell eventTypeForHomeView];
    cell.dateOfEventLabel.text = [eventForCell eventDateShortStyleAndVisible:NO];
    cell.timeOfEventLabel.text = [eventForCell eventTimeShortStyeAndVisible:NO];
    
    cell.eventCoverImage.file = (PFFile *) eventForCell.coverPhoto;
    [cell.eventCoverImage loadInBackground];
    
    if (eventForCell.numAttenders) {
        cell.attendersCountLabel.text = [eventForCell.numAttenders stringValue];
    } else {
        cell.attendersCountLabel.text = @"0";
    }
    
    CLLocation *locationOfEvent = [[CLLocation alloc] initWithLatitude:eventForCell.locationOfEvent.latitude longitude:eventForCell.locationOfEvent.longitude];
    CLLocation *locationCurrent = [[CLLocation alloc] initWithLatitude:self.currentUserLocation.latitude longitude:self.currentUserLocation.longitude];
    
    CLLocationDirection distance = [locationOfEvent distanceFromLocation:locationCurrent];
    
    float distanceMiles = (float) distance * 0.000621371;
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f Mi", distanceMiles];
    
}

- (void) showNoResultsView {
    
    NSLog(@"Show No Results View");
    
    if (!self.noResultsView) {
        self.noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
    }
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            self.noResultsView.headerText = @"This Is Awkward...";
            self.noResultsView.subHeaderText = @"Looks like there aren't any public events near you. Maybe increase your search radius.";
            self.noResultsView.actionButton.titleText = @"Increase Your Search Radius";
            
            UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayFilterView)];
            [self.noResultsView.actionButton addGestureRecognizer:tapgr];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            self.noResultsView.headerText = @"No Events";
            self.noResultsView.subHeaderText = @"Looks like you haven't created any events yet.  Want to create your first?";
            self.noResultsView.actionButton.titleText = @"Create An Event";
            
            [self.noResultsView.actionButton addTarget:self action:@selector(switchToCreateTab) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        }
        case OTHER_USER_EVENTS: {
            self.noResultsView.headerText = @"No Events";
            self.noResultsView.subHeaderText = @"Looks like they haven't created any events yet.";
            self.noResultsView.actionButton.hidden = YES;
            
            break;
        }
        default:
            break;
    }
    
    
    [self.view addSubview:self.noResultsView];
    
}

- (void) hideNoResultsView {
    
    NSLog(@"Hide No Results View");
    
    [self.noResultsView removeFromSuperview];
    
}

- (void) switchToCreateTab {
    
    TabNavigationVC *tabController = (TabNavigationVC *) self.tabBarController;

    [tabController selectCreateTab];
    
    self.noResultsView.actionButton.isSelected = NO;
    
}


- (void) flagEvent:(UIGestureRecognizer *)sender {
    
    UIImageView *flagButton = (UIImageView *)sender.view;
    
    EventObject *eventToFlag = (EventObject *) [self.objects objectAtIndex:flagButton.tag];
    
    [eventToFlag flagEventFromVC:self];

}

#pragma mark - Event Details Delegate Methods

- (void) updateEventCellAfterEdit {
    
    EventTableCell *cellToUpdate = (EventTableCell *) [self.tableView cellForRowAtIndexPath:self.indexPathOfEventInDetailView];
    EventObject *event = (EventObject *)[self.objects objectAtIndex:self.indexPathOfEventInDetailView.row];
    
    [self refreshUIForCell:cellToUpdate withEvent:event];
    
}

- (void) rsvpStatusUpdatedToGoing:(BOOL) rsvp {
    
    EventTableCell *cellToUpdate = (EventTableCell *) [self.tableView cellForRowAtIndexPath:self.indexPathOfEventInDetailView];

    if (rsvp) {
        NSString *currentCount = cellToUpdate.attendersCountLabel.text;
        int newCount = [currentCount intValue] + 1;
        cellToUpdate.attendersCountLabel.text = [NSString stringWithFormat:@"%d", newCount];

    } else {
        NSString *currentCount = cellToUpdate.attendersCountLabel.text;
        int newCount = [currentCount intValue] - 1;
        cellToUpdate.attendersCountLabel.text = [NSString stringWithFormat:@"%d", newCount];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //TODO: move this code to didSelectRowAtIndexPath - also make sure to call [super tableview didselectrowatindexpath?]
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        self.indexPathOfEventInDetailView = indexPathOfSelectedItem;
        
        eventDetailVC.event = (EventObject *)[self.objects objectAtIndex:self.indexPathOfEventInDetailView.row];
        eventDetailVC.delegate = self;
        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        
    }
    
}


#pragma mark - Invite Modal Delegate

- (void) finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.eventForInvites inviteUsers:selectedPeople completion:^(BOOL success) {
        
    }];
    
}


- (void) inviteUsersToEvent:(EventObject *)event {
    
    self.eventForInvites = event;
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
        invitePeopleVC.userProfile = [EVNUser currentUser];
        invitePeopleVC.eventForInvites = event;
        invitePeopleVC.delegate = self;
        
        UINavigationController *embedInThisVC = [[UINavigationController alloc] initWithRootViewController:invitePeopleVC];
        
        [self presentViewController:embedInThisVC animated:YES completion:nil];
        
    });
}


#pragma mark - Clean Up

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
