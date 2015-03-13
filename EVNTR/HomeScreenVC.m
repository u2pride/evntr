//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNConstants.h"
#import "EventDetailVC.h"
#import "EventTableCell.h"
#import "FilterEventsVC.h"
#import "HomeScreenVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ProfileVC.h"
#import "SearchVC.h"
#import "UIImageEffects.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>

@interface HomeScreenVC ()

@property BOOL isGuestUser;
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;

@property (nonatomic, strong) PFGeoPoint *currentUserLocation;
@property (nonatomic) int searchRadius;

@end

@implementation HomeScreenVC

//Question:  What's best to do in initWithCoder v. ViewDidLoad?
// anything related to view goes into viewdidload.
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        //TODO - SHOULD NOT BE DOING THIS self.____ is not for init.
        self.title = @"Events";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        self.userForEventsQuery = [PFUser currentUser];
        self.tabBarController.hidesBottomBarWhenPushed = YES;
        //self.navigationController.hidesBarsOnSwipe = YES;
        NSLog(@"INITWITHCODER OF HOMESCREEN: %@", [NSNumber numberWithBool:self.isGuestUser]);
        
        //Get isGuest Object
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        self.isGuestUser = [standardDefaults boolForKey:kIsGuest];

    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //probably already wired up.    
    self.tableView.delegate = self;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchController)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FilterIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displayFilterView)];
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
    
    
    //Observe Changes in the Filter Radius Distance
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(newFilterApplied:) name:@"FilterApplied" object:nil];
    
    //Default Search Radius
    self.searchRadius = 10;
    
    
}



- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSLog(@"HOME FRAME: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"HOME BOUNDS: %@", NSStringFromCGRect(self.view.bounds));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO: Create New View Controller and Add TableView Programmatically - change here and in SeachVC
- (void)displaySearchController {
    NSLog(@"Display Search Controller");
    
    SearchVC *searchController = (SearchVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchController animated:YES];
    
}

- (void) displayFilterView {
        
    FilterEventsVC *filterVC = (FilterEventsVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    filterVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    filterVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.tabBarController presentViewController:filterVC animated:YES completion:nil];
    
    
}

- (void) newFilterApplied:(NSNotification *)notification {
    
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    
    UIButton *buttonPressedToFilter = (UIButton *)notification.object;
    self.searchRadius = [buttonPressedToFilter.titleLabel.text intValue];
    
    //Reload Table View with New Search Radius
    [self loadObjects];
    
}


- (void) updatedLocation:(NSNotification *)notification {
    if (!self.currentUserLocation) {
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
        
    } else {
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        self.currentUserLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
    }
}


- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocationFromAppDelegate=appDelegate.locationManager.location;

    NSLog(@"Current Location From AppDelegate: %@", currentLocationFromAppDelegate);
    
}


- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"Location Used for Search: %f and %f:", self.currentUserLocation.latitude, self.currentUserLocation.longitude);
    
    /*
    for (PFObject *newEvent in self.objects) {
        PFGeoPoint *location = [newEvent objectForKey:@"locationOfEvent"];
        NSLog(@"eventLocation lat and long %f and %f:", location.latitude, location.longitude);
    }
     */

}




#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    //Return All Events for the Basic All Events View
    //Return a Specific Username's events when you are viewing someone's events.
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            
            //One Way to Do It
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            self.currentUserLocation = [PFGeoPoint geoPointWithLocation:appDelegate.locationManager.location];
            
            //Ends up Grabbing the Last Location Stored if No Location in Location Manager
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userLocationDictionary = [userDefaults objectForKey:@"userLocation"];
            
            NSNumber *latitude = [userLocationDictionary objectForKey:@"latitude"];
            NSNumber *longitude = [userLocationDictionary objectForKey:@"longitude"];

            if (userLocationDictionary) {
                NSLog(@"Got the User Location from UserDefaults");
                self.currentUserLocation = [PFGeoPoint geoPointWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            }
            
            if (!self.currentUserLocation) {
                NSLog(@"Returning nil");
                return nil;
            }

            NSArray *eventTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE], [NSNumber numberWithInt:PUBLIC_APPROVED_EVENT_TYPE], nil];

            [eventsQuery whereKey:@"typeOfEvent" containedIn:eventTypes];
            [eventsQuery whereKey:@"locationOfEvent" nearGeoPoint:self.currentUserLocation withinMiles:self.searchRadius];
            
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
    
    return eventsQuery;
}

//- (void)lookForLocationNow {
    
//    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//    currentLocation = [PFGeoPoint geoPointWithLocation:appDelegate.currentLocation];
//    [self loadObjects];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"eventCell";
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        cell.eventCoverImage.file = (PFFile *)[object objectForKey:@"coverPhoto"];
        [cell.eventCoverImage loadInBackground:^(UIImage *image, NSError *error) {
            
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
        
    }
    
    return cell;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //open view with the event details
    //TODO: move this code to didSelectRowAtIndexPath - also make sure to call [super tableview didselectrowatindexpath?]
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        
        PFObject *event = [self.objects objectAtIndex:indexPathOfSelectedItem.row];
        
        //TODO: Better way to select object and transition to new VC
        //PFObject *selectedObject = [self objectAtIndexPath:indexPath];

        eventDetailVC.eventObject = event;

        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        //nothing needed yet
        
    }
    
}





@end
