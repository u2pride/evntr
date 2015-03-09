//
//  LocationSearchVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "LocationSearchVC.h"
#import "GoogleResult.h"
#import "UserLocationTableCell.h"
#import <AddressBookUI/AddressBookUI.h>


@interface LocationSearchVC ()
{
    NSMutableArray *locationSearchResults;
    CLGeocoder *geoCoder;
    CLLocation *locationCurrent;
    
    NSNumber *latitude;
    NSNumber *longitude;
    
    BOOL isEnteringCustomLocation;
}

@property (nonatomic, strong) UserLocationTableCell *customUserLocationCell;

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;

- (IBAction)cancelLocationSearch:(id)sender;
- (IBAction)getCurrentLocation:(id)sender;

@end



@implementation LocationSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    isEnteringCustomLocation = NO;
    
    
    [self.searchResultsTable registerNib:[UINib nibWithNibName:@"UserLocationTableCell" bundle:nil]forCellReuseIdentifier:@"CustomLocationCell"];
    
    //Set up Search TableView and Controller
    locationSearchResults = [[NSMutableArray alloc] init];
    self.searchResultsTable.delegate = self;
    self.searchResultsTable.dataSource = self;
        
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;

    [self.searchController.searchBar sizeToFit];
    self.searchResultsTable.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    
    geoCoder = [[CLGeocoder alloc] init];
    
    
    //Grab current User Location Before Appearing - Right now just use what is stored in NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentLocation = [userDefaults objectForKey:@"userLocation"];

    latitude = [currentLocation objectForKey:@"latitude"];
    longitude = [currentLocation objectForKey:@"longitude"];
    
    CLLocationDegrees lat = [latitude doubleValue];
    CLLocationDegrees lng = [longitude doubleValue];
    
    locationCurrent = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    NSLog(@"CURRENT LOCATION : %@ - %@", latitude, longitude);
    
}

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //reset search results
    [locationSearchResults removeAllObjects];
    isEnteringCustomLocation = NO;
    
    //this is where we geocode and display search results in tableview.
    //[geoCoder geocodeAddressString:self.searchController.searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
       
        //NSLog(@"RESULTS: %@", placemarks);
        //[locationSearchResults addObjectsFromArray:placemarks];
        //[self.searchResultsTable reloadData];

    //}];
    
    NSString *keyword = self.searchController.searchBar.text;

    // Build the url string to send to Google - Searching for Places with Keyword rankedby distance to user's current location.
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%@,%@&rankby=distance&keyword=%@&sensor=true&key=%@", latitude, longitude, keyword, kGOOGLE_API_KEY];
    
    NSLog(@"STRING: %@", url);
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.EVNTR.bckqueue", 0);
    
    dispatch_async(backgroundQueue, ^{
    
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];

        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];

    });
    
    
    
}


- (void) fetchedData:(NSData *)responseData {
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *places = [json objectForKey:@"results"];
    
    NSLog(@"Data from GoogleError: %@  : %@", error, places);
    
    for (int i = 0; i < [places count]; i++) {
        
        NSDictionary *place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        
        CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[[location objectForKey:@"lat"] doubleValue] longitude:[[location objectForKey:@"lng"] doubleValue]];
        
        GoogleResult *newSearchResult = [[GoogleResult alloc] initWithTitle:name address:vicinity location:locationPoint];
        
        [locationSearchResults addObject:newSearchResult];
        
    }
    
    //Reload new search results data into table.
    [self.searchResultsTable reloadData];
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isEnteringCustomLocation) {
        return 3;
    } else {
        return locationSearchResults.count;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"HERE IN CELLFORROWATENDPATH");
    
    static NSString *reuseIdentifier = @"basicSearchResultsCell";
    static NSString *reuseIdentifierCustom = @"CustomSearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    if (isEnteringCustomLocation) {
        
        switch (indexPath.row) {
            case 0: {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierCustom];
                cell.textLabel.text = @"Custom User Location";
                //return self.customLocationHeaderCell;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                
                break;
            }
            case 1: {
                
                //UserLocationTableCell *cell = (UserLocationTableCell *) [tableView dequeueReusableCellWithIdentifier:@"CustomLocationCell"];
                
                self.customUserLocationCell = (UserLocationTableCell *) [tableView dequeueReusableCellWithIdentifier:@"CustomLocationCell"];
                
                self.customUserLocationCell.locationAddressTextView.text = @"";
                self.customUserLocationCell.locationNameTextField.text = @"Current Location";
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                return self.customUserLocationCell;
                //return self.customLocationUserInformationCell;
                
                break;
            }
            case 2: {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierCustom];
                cell.textLabel.text = @"Use This Location";
                //return self.customLocationSaveCell;
                
                break;
            }
            default:
                break;
        }
        
        
    } else {
        
        if (locationSearchResults.count > 0) {
            
            GoogleResult *resultOfSearch = [locationSearchResults objectAtIndex:indexPath.row];
            
            NSString *locationTitle = resultOfSearch.title;
            NSString *address = resultOfSearch.address;
            
            NSLog(@"PLacemark title: %@", resultOfSearch.title);
            
            cell.textLabel.text = locationTitle;
            cell.detailTextLabel.text = address;
            
        } else {
            
            cell.textLabel.text = @"No Results";
            
        }

        
        
    }
    
    
    
    return cell;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1 && isEnteringCustomLocation) {
        return 155.0f;
    } else {
        return 60.0f;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //grab the name of the location and the coordinates.  save the coordinates to parse and location name too.
    //call delegate that search has finished.
    
    if (isEnteringCustomLocation) {
        
        switch (indexPath.row) {
            case 0: {
                //do nothing
                break;
            }
            case 1: {
                //do nothing
                break;
            }
            case 2: {
                //save location and return to create event screen
                
                NSIndexPath *locationInfoIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                
                UserLocationTableCell *locationCell = (UserLocationTableCell *) [tableView cellForRowAtIndexPath:locationInfoIndexPath];
                
                [geoCoder geocodeAddressString:locationCell.locationAddressTextView.text completionHandler:^(NSArray *placemarks, NSError *error) {
                    
                    
                    if (!error && placemarks.count > 0) {
                        
                        CLPlacemark *placemark = [placemarks firstObject];
                        
                        GoogleResult *customLocation = [[GoogleResult alloc] initWithTitle:locationCell.locationNameTextField.text address:locationCell.locationAddressTextView.text location:placemark.location];
                        
                        NSLog(@"%@ - %@ ", locationCell.locationAddressTextView.text, locationCell.locationNameTextField.text);
                        
                        NSString *locationTitle = customLocation.title;
                        CLLocation *coordinates = customLocation.location;
                        
                        id<EventLocationSearch> strongDelegate = self.delegate;
                        
                        [strongDelegate locationSelectedWithCoordinates:coordinates andName:locationTitle];
                        
                    } else {
                        
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not a valid address." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                        
                        [errorAlert show];
                        
                        
                    }
                    
                    
                    
                }];
                
                

                break;
            }
            default:
                break;
        }
        
        
    } else {
        
        NSLog(@"SELECTED ROW");
        
        GoogleResult *selectedLocation = [locationSearchResults objectAtIndex:indexPath.row];
        
        NSString *locationTitle = selectedLocation.title;
        
        CLLocation *coordinates = selectedLocation.location;
        
        id<EventLocationSearch> strongDelegate = self.delegate;
        
        [strongDelegate locationSelectedWithCoordinates:coordinates andName:locationTitle];
        
        
        
    }
    
    
 
}


#pragma mark - TableView Delegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelLocationSearch:(id)sender {
    
    NSLog(@"CANCELING LOCATION SEARCH");
    
    id<EventLocationSearch> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(locationSearchDidCancel)]) {
        
        NSLog(@"CANCELING LOCATION SEARCH - INSIDE");

        [strongDelegate locationSearchDidCancel];
    }
}

- (IBAction)getCurrentLocation:(id)sender {
    
    isEnteringCustomLocation = YES;
    
    [geoCoder reverseGeocodeLocation:locationCurrent completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error with Location");
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.customUserLocationCell.locationAddressTextView.text = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
            
        }
        
    }];
    
    [self.searchResultsTable reloadData];
    
    
}
@end
