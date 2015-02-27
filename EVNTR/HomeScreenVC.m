//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"
#import "EventTableCell.h"
#import "HomeScreenVC.h"
#import "ProfileVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "EVNConstants.h"
#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SearchVC.h"
#import "UIImageEffects.h"

@interface HomeScreenVC () {
    PFGeoPoint *currentLocation;
}

@property BOOL isGuestUser;

@end

@implementation HomeScreenVC

@synthesize userForEventsQuery, typeOfEventTableView, isGuestUser;

//Question:  What's best to do in initWithCoder v. ViewDidLoad?
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Events";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        self.userForEventsQuery = [PFUser currentUser];
        self.tabBarController.hidesBottomBarWhenPushed = YES;
        NSLog(@"INITWITHCODER OF HOMESCREEN: %@", [NSNumber numberWithBool:self.isGuestUser]);
        
        //Get isGuest Object
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        self.isGuestUser = [standardDefaults boolForKey:kIsGuest];

    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"VIEWDIDLOAD OF HOMESCREEN: %@", [NSNumber numberWithBool:self.isGuestUser]);

    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchController)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
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
            
            break;
        }
        case OTHER_USER_EVENTS: {
            NSLog(@"EventsView - User Events");
            [self.navigationItem setTitle:@"User Events"];
            
            break;
        }
        default:
            break;
    }
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
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


- (void) updatedLocation:(NSNotification *)notification {
    if (!currentLocation) {
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        currentLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
        [self loadObjects];
        
    } else {
        CLLocation *newUserLocation = (CLLocation *)[[notification userInfo] objectForKey:@"newLocationResult"];
        currentLocation = [PFGeoPoint geoPointWithLocation:newUserLocation];
    }
}


- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation *currentLocationFromAppDelegate=appDelegate.locationManager.location;

    NSLog(@"current location: %@", currentLocationFromAppDelegate);
    
}




- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"---------------------------------------------------------");
    NSLog(@"currentLocation lat and long %f and %f:", currentLocation.latitude, currentLocation.longitude);
    
    for (PFObject *newEvent in self.objects) {
        PFGeoPoint *location = [newEvent objectForKey:@"locationOfEvent"];
        NSLog(@"eventLocation lat and long %f and %f:", location.latitude, location.longitude);
    }

}




#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    
    //Return All Events for the Basic All Events View
    //Return a Specific Username's events when you are viewing someone's events.
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    
    switch (typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {

            NSLog(@"before everything");
            //One Way to Do It
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            currentLocation = [PFGeoPoint geoPointWithLocation:appDelegate.locationManager.location];
            
            NSLog(@"after app delegate method");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userLocationDictionary = [userDefaults objectForKey:@"userLocation"];
            
            NSNumber *latitude = [userLocationDictionary objectForKey:@"latitude"];
            NSNumber *longitude = [userLocationDictionary objectForKey:@"longitude"];
            NSLog(@"after userDefaults method");

            if (userLocationDictionary) {
                NSLog(@"Got the User Location from UserDefaults");
                currentLocation = [PFGeoPoint geoPointWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            }
            
            if (!currentLocation) {
                NSLog(@"Returning nil");
                return nil;
            }

            [eventsQuery whereKey:@"typeOfEvent" equalTo:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE]];
            [eventsQuery whereKey:@"locationOfEvent" nearGeoPoint:currentLocation];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            
            [eventsQuery whereKey:@"parent" equalTo:userForEventsQuery];
            [eventsQuery orderByAscending:@"Title"];
            
            break;
        }
        case OTHER_USER_EVENTS: {

            [eventsQuery whereKey:@"parent" equalTo:userForEventsQuery];
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
        //cell.numberOfAttenders.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"attenders"]];
        
        
        
        /*
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        [cell.eventCoverImage addSubview:effectView];
        */
    }
    
    return cell;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //open view with the event details
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        
        PFObject *event = [self.objects objectAtIndex:indexPathOfSelectedItem.row];
        eventDetailVC.eventObject = event;
        NSLog(@"PERFORMSEGUE OF HOMESCREEN: %@", [NSNumber numberWithBool:self.isGuestUser]);

        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        //nothing needed yet
        
    }
    
}


//- (void)returnToProfile {

//    [self dismissViewControllerAnimated:YES completion:nil];

//}

//using app delegate for location updates... need to pair with pfgeopointinbackground
/*
 NSLog(@"before the if then check");
 
 //Make sure location services are enabled before requesting the location
 if([CLLocationManager locationServicesEnabled]){
 
 NSLog(@"inside the if then check");
 
 
 AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
 CLLocation *currentLocationFromAppDelegate = appDelegate.currentLocation;
 
 currentLocation = [PFGeoPoint geoPointWithLocation:currentLocationFromAppDelegate];
 
 NSLog(@"Current Location: %@", currentLocation);
 
 if (currentLocation.latitude == 0 || currentLocation.longitude == 0) {
 UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Location From App Delegate - Maybe start a timer to ask for location in a couple of secs?" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
 
 [errorAlert show];
 }
 
 }
 
 UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(returnToProfile)];
 
 self.navigationItem.rightBarButtonItem = cancelButton;
 */

// TODO - THIS IS NOT GETTING CALLED WHEN USING THE NAVIGATION, but otherwise is getting called.
// Nevermind it is getting called, just after the queryForTable function... hmmm.  queryForTable is to determine the query. not where I should be checking locaiton.

//Fail safe for when we don't have a current location.
/*
 if (currentLocation.latitude == 0 || currentLocation.longitude == 0) {
 NSLog(@"QueryForTableView... no currentLocation");
 
 [NSTimer timerWithTimeInterval:5 target:self selector:@selector(lookForLocationNow) userInfo:nil repeats:NO];
 
 return;
 }
 
 //Add the location to the query.
 [self.queryForTable whereKey:@"locationOfEvent" nearGeoPoint:currentLocation];
 
 */


@end
