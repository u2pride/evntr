//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "BBBadgeBarButtonItem.h"
#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EventDetailVC.h"
#import "EventObject.h"
#import "EventTableCell.h"
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
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@property (nonatomic, strong) PFGeoPoint *currentUserLocation;
@property (nonatomic) float searchRadius;

@property (nonatomic, strong) EVNNoResultsView *noResultsView;
@property (nonatomic, strong) BBBadgeBarButtonItem *filterBarButton;

@property (nonatomic, strong) NSIndexPath *indexPathOfEventInDetailView;

//Event for Invites
@property (nonatomic, strong) EventObject *eventForInvites;

@end

@implementation HomeScreenVC


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.title = @"Events";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        self.tabBarController.hidesBottomBarWhenPushed = YES;
        
        //Get isGuest Object
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        _isGuestUser = [standardDefaults boolForKey:kIsGuest];
        _searchRadius = 20.0;
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"VIEWDIDLOAD");
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
        
    //stop Movie Player on Initial Screen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopMoviePlayer" object:nil];

    
    //probably already wired up.    
    self.tableView.delegate = self;
    
    if (!self.isGuestUser) {
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchController)];
        self.navigationItem.rightBarButtonItem = searchButton;
    }
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.f", self.searchRadius] style:UIBarButtonItemStylePlain target:self action:@selector(displayFilterView)];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    //Subscribe to Location Updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedLocation:) name:@"newLocationNotif" object:nil];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    NSLog(@"type: %d", self.typeOfEventTableView);
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            [self.navigationItem setTitle:@"Public Events"];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            NSLog(@"EventsView - My Events");
            [self.navigationItem setTitle:@"My Events"];
            //remove search icon and filter
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItems = nil;

            break;
        }
        case OTHER_USER_EVENTS: {
            NSLog(@"EventsView - User Events");
            [self.navigationItem setTitle:@"User's Public Events"];
            //remove search icon and filter
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.leftBarButtonItems = nil;
            
            break;
        }
        default:
            break;
    }
    

}


#pragma mark - Search and Filtering

//TODO: Create New View Controller and Add TableView Programmatically - change here and in SeachVC
- (void)displaySearchController {
    
    [PFAnalytics trackEventInBackground:@"SearchAccessed" block:nil];
    
    SearchVC *searchController = (SearchVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchController animated:YES];
    
}

- (void) displayFilterView {
    
    [PFAnalytics trackEventInBackground:@"FilterAccessed" block:nil];
    
    FilterEventsVC *filterVC = (FilterEventsVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    filterVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    filterVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    filterVC.selectedFilterDistance = [self.navigationItem.leftBarButtonItem.title floatValue];
    filterVC.delegate = self;
    
    [self.tabBarController presentViewController:filterVC animated:YES completion:nil];
    
}

- (void) completedFiltering:(float)radius {

    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    
    self.searchRadius = radius;
    
    if (radius < 1) {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.01f", self.searchRadius];
    } else {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.f", self.searchRadius];
    }
    
    
    //Reload Table View with New Search Radius
    [self loadObjects];
    
}


#pragma mark - Location Notification

- (void) updatedLocation:(NSNotification *)notification {
    
    NSLog(@"NEW LOCATION");

    if (!self.currentUserLocation) {
        
        NSLog(@"NEW LOCATION - PART 1");
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
        
    } else {
        
        NSLog(@"NEW LOCATION - PART 2 - NO UPDATE");
        
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
    }
}


- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    NSLog(@"ObjectsWillLoad");
    

    
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.objects.count == 0) {
        [self showNoResultsView];
    } else if (self.noResultsView) {
        [self hideNoResultsView];
    }
}


#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    NSLog(@"QueryForTable");
    
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
        NSLog(@"Got Location from userdefaults - %@", self.currentUserLocation);
    }
    
    
    //Wait Until A Location Is Found
    if (!self.currentUserLocation) {
        NSLog(@"NO CURRENT LOCATION FOUND");
        [self performSelector:@selector(loadObjects) withObject:nil afterDelay:0.1];
        return nil;
    }
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    
    NSLog(@"self.typeOfEventTableView - %@", [NSNumber numberWithInt:self.typeOfEventTableView]);
    
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
            [eventsQuery orderByAscending:@"Title"];
            
            break;
        }
        case OTHER_USER_EVENTS: {

            [eventsQuery whereKey:@"parent" equalTo:self.userForEventsQuery];
            NSArray *eventTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE], [NSNumber numberWithInt:PUBLIC_APPROVED_EVENT_TYPE], nil];
            [eventsQuery whereKey:@"typeOfEvent" containedIn:eventTypes];
            [eventsQuery orderByAscending:@"Title"];
            
            break;
        }
            
        default:
            break;
    }
    
    eventsQuery.limit = 50;
    
    NSLog(@"Events Query: %@", eventsQuery);
    
    return eventsQuery;
}

//- (void)lookForLocationNow {
    
//    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//    currentLocation = [PFGeoPoint geoPointWithLocation:appDelegate.currentLocation];
//    [self loadObjects];
//}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    return self.allEvents.count;
    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 320;
}


- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"eventCell";
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    EventObject *event = (EventObject *)object;
    
    
    if (cell) {
        
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self refreshUIForCell:cell withEvent:event];
        
    }
    
    return cell;

}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Updating the Cell");
    
    static NSString *cellIdentifier = @"eventCell";
    
    NSLog(@"number of items in events %lu", (unsigned long)self.allEvents.count);
    NSLog(@"indexPath row %ld", (long)indexPath.row);
    NSLog(@"list of events - %@", self.allEvents);
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    EventObject *event = [self.allEvents objectAtIndex:indexPath.row];
    
    
    if (cell) {
        
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self refreshUIForCell:cell withEvent:event];
        
        //OLD start
        
 
        [eventForCell.eventCoverPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                UIImage *imageFromParse = [UIImage imageWithData:data];
                UIImage *imageWithEffect = [UIImageEffects imageByApplyingBlurToImage:imageFromParse withRadius:10.0 tintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] saturationDeltaFactor:1.0 maskImage:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    cell.eventCoverImage.image = imageWithEffect;
                });

            });
            
        }];
 
        
        //OLD end
        
        
        UIView *roundForEventTypeView = [[UIView alloc] initWithFrame:cell.eventTypeLabel.frame];
        roundForEventTypeView.frame = CGRectMake(0, 0, cell.eventTypeLabel.frame.size.width, cell.eventTypeLabel.frame.size.width);
        roundForEventTypeView.center = cell.eventTypeLabel.center;
        roundForEventTypeView.layer.cornerRadius = roundForEventTypeView.frame.size.width / 2.0f;
        roundForEventTypeView.backgroundColor = [UIColor orangeThemeColor];
        [cell.darkViewOverImage insertSubview:roundForEventTypeView atIndex:0];
        
    
        UIView *roundForAttendersView = [[UIView alloc] initWithFrame:cell.attendersCountLabel.frame];
        roundForAttendersView.frame = CGRectMake(0, 0, cell.attendersCountLabel.frame.size.width, cell.attendersCountLabel.frame.size.width);
        roundForAttendersView.center = cell.attendersCountLabel.center;
        roundForAttendersView.layer.cornerRadius = roundForAttendersView.frame.size.width / 2.0f;
        roundForAttendersView.backgroundColor = [UIColor orangeThemeColor];
        [cell.darkViewOverImage insertSubview:roundForAttendersView atIndex:0];
        
        
    }
    
    return cell;
    
}
*/

- (void) refreshUIForCell:(EventTableCell *)cell withEvent:(EventObject *)eventForCell {
    
    NSLog(@"Refreshing UI for cell with Event %@", eventForCell.title);
    
    cell.eventTitle.text = eventForCell.title;
    cell.eventTypeLabel.text = [eventForCell eventTypeForHomeView];
    cell.dateOfEventLabel.text = [eventForCell eventDateShortStyle];
    cell.timeOfEventLabel.text = [eventForCell eventTimeShortStye];
    
    cell.eventCoverImage.file = (PFFile *) eventForCell.coverPhoto;
    [cell.eventCoverImage loadInBackground];

    
    [eventForCell totalNumberOfAttendersInBackground:^(int count) {
        cell.attendersCountLabel.text = [NSString stringWithFormat:@"%d", count];
    }];
    
    
    //Getting Current Location and Comparing to Event Location
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //CLLocation *currentLocation = [[appDelegate locationManager] location];
    
    CLLocation *locationOfEvent = [[CLLocation alloc] initWithLatitude:eventForCell.locationOfEvent.latitude longitude:eventForCell.locationOfEvent.longitude];
    
    CLLocation *locationCurrent = [[CLLocation alloc] initWithLatitude:self.currentUserLocation.latitude longitude:self.currentUserLocation.longitude];
    
    CLLocationDirection distance = [locationOfEvent distanceFromLocation:locationCurrent];
    
    float distanceMiles = (float) distance * 0.000621371;
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.2f Mi", distanceMiles];
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"eventCell";
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        cell.eventCoverImage.file = (PFFile *)[object objectForKey:@"coverPhoto"];
        [cell.eventCoverImage loadInBackground:^(UIImage *image, NSError *error) {
            
            NSLog(@"BACK FROM NETWORK");
            cell.eventCoverImage.image = [UIImageEffects imageByApplyingBlurToImage:image withRadius:10.0 tintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] saturationDeltaFactor:1.0 maskImage:nil];
            
            
        }];
        
        cell.eventTitle.text = [object objectForKey:@"title"];
        NSDate *dateOfEvent = [object objectForKey:@"dateOfEvent"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        cell.dateOfEventLabel.text = [dateFormatter stringFromDate:dateOfEvent];
        
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        
        cell.timeOfEventLabel.text = [dateFormatter stringFromDate:dateOfEvent];
        
        PFRelation *relation = [object relationForKey:@"attenders"];
        PFQuery *query = [relation query];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
           
            cell.attendersCountLabel.text = [NSString stringWithFormat:@"%d", number];
            
        }];
        
        //TODO: set type property of cell and move this logic into the cell class.
        int typeOfEvent = [[object objectForKey:@"typeOfEvent"] intValue];
        switch (typeOfEvent) {
            case PUBLIC_EVENT_TYPE: {
                cell.eventTypeLabel.text = @"Pu";
                break;
            }
            case PRIVATE_EVENT_TYPE: {
                cell.eventTypeLabel.text = @"Pr";
                break;
            }
            case PUBLIC_APPROVED_EVENT_TYPE: {
                cell.eventTypeLabel.text = @"Pa";
                break;
            }
            default:
                break;
        }
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    
    return cell;
    
}
 
 */


//Animate UITableViewCells Appearing
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.65 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        
        cell.alpha = 1;
        cell.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        
    }];
     
}

#pragma mark - No Results


- (void) showNoResultsView {
    
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
    
    [self.noResultsView removeFromSuperview];
    
}

- (void) switchToCreateTab {
    
    TabNavigationVC *tabController = (TabNavigationVC *) self.tabBarController;

    [tabController selectCreateTab];
    
    self.noResultsView.actionButton.isSelected = NO;
    
}

#pragma mark - Event Details Delegate Methods

- (void) userCompletedEventEditing {
    NSLog(@"userCompletedEventEditing");
    
    EventTableCell *cellToUpdate = (EventTableCell *) [self.tableView cellForRowAtIndexPath:self.indexPathOfEventInDetailView];
    //EventObject *event = [self.allEvents objectAtIndex:self.indexPathOfEventInDetailView.row];
    EventObject *event = (EventObject *)[self.objects objectAtIndex:self.indexPathOfEventInDetailView.row];
    
    [self refreshUIForCell:cellToUpdate withEvent:event];
    
    NSLog(@"CellToUpdates title: %@", cellToUpdate);
    
}

- (void) rsvpStatusUpdatedToGoing:(BOOL) rsvp {
    
    EventTableCell *cellToUpdate = (EventTableCell *) [self.tableView cellForRowAtIndexPath:self.indexPathOfEventInDetailView];

    if (rsvp) {
        //increment
        NSString *currentCount = cellToUpdate.attendersCountLabel.text;
        int newCount = [currentCount intValue] + 1;
        cellToUpdate.attendersCountLabel.text = [NSString stringWithFormat:@"%d", newCount];

    } else {
        //decrement
        NSString *currentCount = cellToUpdate.attendersCountLabel.text;
        int newCount = [currentCount intValue] - 1;
        cellToUpdate.attendersCountLabel.text = [NSString stringWithFormat:@"%d", newCount];
    }
    
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //open view with the event details
    //TODO: move this code to didSelectRowAtIndexPath - also make sure to call [super tableview didselectrowatindexpath?]
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        self.indexPathOfEventInDetailView = indexPathOfSelectedItem;
        
        //eventDetailVC.event = [self.allEvents objectAtIndex:indexPathOfSelectedItem.row];
        eventDetailVC.event = (EventObject *)[self.objects objectAtIndex:self.indexPathOfEventInDetailView.row];
        eventDetailVC.delegate = self;
        //PFObject *event = [self.objects objectAtIndex:indexPathOfSelectedItem.row];
        //TODO: Better way to select object and transition to new VC
        //PFObject *selectedObject = [self objectAtIndexPath:indexPath];

        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        //nothing needed yet
        
    }
    
}



#pragma mark - Invite Modal Delegate

- (void) finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.eventForInvites inviteUsers:selectedPeople completion:^(BOOL success) {
        NSLog(@"finished inviting users with : %@", [NSNumber numberWithBool:success]);
    }];
    
    [self.eventForInvites saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved invite pfrelations");
    }];

    
}


- (void) inviteUsersToEvent:(EventObject *)event {
    
    self.eventForInvites = event;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
        invitePeopleVC.userProfile = [EVNUser currentUser];
        invitePeopleVC.usersAlreadyInvited = nil;
        invitePeopleVC.delegate = self;
        
        UINavigationController *embedInThisVC = [[UINavigationController alloc] initWithRootViewController:invitePeopleVC];
        
        [self presentViewController:embedInThisVC animated:YES completion:nil];
        
    });
    

}


/*
 [cell.eventCoverImage loadInBackground:^(UIImage *image, NSError *error) {
 
 NSLog(@"Here 3");
 
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 
 NSLog(@"before imageeffect");
 
 UIImage *imageEffected = [UIImageEffects imageByApplyingBlurToImage:image withRadius:10.0 tintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] saturationDeltaFactor:1.0 maskImage:nil];
 
 dispatch_async(dispatch_get_main_queue(), ^(void) {
 
 cell.eventCoverImage.image = imageEffected;
 
 });
 
 NSLog(@"after imageeffect");
 
 });
 
 NSLog(@"Here 4");
 
 }];
 */






-(void)dealloc {
    NSLog(@"homescreen is being deallocated - deregister notifications");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
