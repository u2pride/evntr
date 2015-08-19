//
//  EVNFriendsEventsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 7/21/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNFriendsEventsVC.h"
#import "EVNInviteContainerVC.h"
#import "EVNHomeContainerVC.h"

#import "AppDelegate.h"
#import "Amplitude/Amplitude.h"
#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EventDetailVC.h"
#import "EventObject.h"
#import "EventTableCell.h"
#import "EVNUtility.h"
#import "EVNUser.h"
#import "FilterEventsVC.h"
#import "HomeScreenVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "TabNavigationVC.h"
#import "UIImageEffects.h"
#import "UIColor+EVNColors.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface EVNFriendsEventsVC ()

@property BOOL isGuestUser;

//Amplitude Analytics
@property (nonatomic, strong) NSDate *startStopwatchDate;
@property (nonatomic) NSNumber *numEventsScrolled;
@property (nonatomic) BOOL scrolledToBottom;

@property (nonatomic) float searchRadius;

@property (nonatomic, strong) PFGeoPoint *currentUserLocation;
@property (nonatomic, strong) EVNNoResultsView *noResultsView;

@property (nonatomic, strong) NSIndexPath *indexPathOfEventInDetailView;
@property (nonatomic, strong) EventObject *eventForInvites;


@end

@implementation EVNFriendsEventsVC

#pragma mark - Initialization Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initialSetup];
        
    }
    
    return self;
    
}

- (void) initialSetup {
    
    self.title = @"Friend's Events";
    self.parseClassName = @"Events";
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = NO;
    self.objectsPerPage = 50;
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    _isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl.tintColor = [UIColor orangeThemeColor];
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
    
    //Subscribe to Location & Radius Updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedLocation:) name:kUserLocationUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithNewRadius:) name:kFilterRadiusUpdate object:nil];
    
    [self loadObjects];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set the StartStopwatchDate to Current Date/Time - Used in ViewWillDisappear to Determine Time Spent Viewing Event
    self.startStopwatchDate = [NSDate date];
    self.numEventsScrolled = @0;
    self.scrolledToBottom = NO;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    //Amplitude Analytics
    int intTime = 0;
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startStopwatchDate];
    intTime = (int) round(time);

    NSMutableDictionary *eventProps = [NSMutableDictionary new];
    
        [eventProps setObject:[NSNumber numberWithInt:intTime] forKey:@"Total Time"];
        [eventProps setObject:self.numEventsScrolled forKey:@"Events Scrolled"];
        [eventProps setObject:[NSNumber numberWithBool:self.scrolledToBottom] forKey:@"Scrolled to Bottom"];

    [[Amplitude instance] logEvent:@"Viewed Following Events" withEventProperties:eventProps];
    
}


#pragma mark - EVNHomeContainerDelegate

- (void) updateWithNewRadius:(NSNotification *)notification {
    
    NSNumber *radius = (NSNumber *) [[notification userInfo] objectForKey:@"radius"];
    
    self.searchRadius = [radius floatValue];
    
    //Reload Table
    [self loadObjects];
    
}


#pragma mark - Location Notification

- (void) updatedLocation:(NSNotification *)notification {
    
    //Determine if this is Our First Real Location Update and If So, Reload Table
    if (!self.currentUserLocation || self.currentUserLocation.latitude == 0.0) {
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
        
    } else {
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];

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
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activities"];
    [followingQuery whereKey:@"userFrom" equalTo:[EVNUser currentUser]];
    [followingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    
    NSArray *eventTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE], [NSNumber numberWithInt:PUBLIC_APPROVED_EVENT_TYPE], nil];
    NSDate *currentDateMinusOneDay = [NSDate dateWithTimeIntervalSinceNow:TWELVE_HOURS];
    
    PFQuery *followingEventsQuery = [PFQuery queryWithClassName:@"Events"];
    [followingEventsQuery whereKey:@"parent" matchesKey:@"userTo" inQuery:followingQuery];
    [followingEventsQuery whereKey:@"typeOfEvent" containedIn:eventTypes];
    [followingEventsQuery whereKey:@"locationOfEvent" nearGeoPoint:self.currentUserLocation withinMiles:[self.delegate currentRadiusFilter]];
    [followingEventsQuery whereKey:@"dateOfEvent" greaterThanOrEqualTo:currentDateMinusOneDay];
    [followingEventsQuery orderByAscending:@"dateOfEvent"];
        
    
    return followingEventsQuery;
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
        
        //TODO - Move flagging to RefreshUI
        for (UIGestureRecognizer *recognizer in cell.flagButton.gestureRecognizers) {
            [cell.flagButton removeGestureRecognizer:recognizer];
        }
        
        cell.flagButton.tag = indexPath.row;
        
        UITapGestureRecognizer *flagGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagEvent:)];
        [cell.flagButton addGestureRecognizer:flagGR];
        
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self refreshUIForCell:cell withEvent:event];
        
        if ((indexPath.row + 1) > [self.numEventsScrolled intValue]) {
            
            NSInteger numberEvents = indexPath.row + 1;
            self.numEventsScrolled = [NSNumber numberWithInteger:numberEvents];
        }
        
        if ((indexPath.row + 1) == [self.objects count]) {
            self.scrolledToBottom = YES;
        }
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
    
    if (!self.noResultsView) {
        self.noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
    }
    
    self.noResultsView.backgroundColor = [UIColor whiteColor];
    self.noResultsView.headerText = @"No Events";
    self.noResultsView.subHeaderText = @"Looks like no one you're following has made any public events yet! Try finding more people to follow to personalize what events you see here.";
    self.noResultsView.actionButton.hidden = YES;
    
    [self.view addSubview:self.noResultsView];
    [self.view bringSubviewToFront:self.noResultsView];
    
}

- (void) hideNoResultsView {
    
    [self.noResultsView removeFromSuperview];
    self.noResultsView = nil;
    
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
