//
//  LocationSearchVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNConstants.h"
#import "EVNLocationButton.h"
#import "GoogleResult.h"
#import "LocationSearchVC.h"
#import "UIColor+EVNColors.h"
#import "UserLocationTableCell.h"

#import <AddressBookUI/AddressBookUI.h>

#define kGOOGLE_API_KEY @"AIzaSyDbbFOj98Z6G6lUskNuUlDr0uYPvrR-cZo"

@interface LocationSearchVC ()

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;

@property (nonatomic, strong) UserLocationTableCell *customUserLocationCell;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *locationSearchResults;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) CLLocation *locationCurrent;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic) BOOL isEnteringCustomLocation;
@property (nonatomic, strong) UIView *tapToDismissView;


- (IBAction)cancelLocationSearch:(id)sender;
- (IBAction)getCurrentLocation:(id)sender;

@end



@implementation LocationSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
        
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
    //Bar Button Setup
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil]
                                                          forState:UIControlStateNormal];
    
    //Set up Search TableView and Controller
    self.locationSearchResults = [[NSMutableArray alloc] init];
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
    
    [self.searchResultsTable registerNib:[UINib nibWithNibName:@"UserLocationTableCell" bundle:nil]forCellReuseIdentifier:@"CustomLocationCell"];
    
    //Initialization
    self.definesPresentationContext = YES;
    self.isEnteringCustomLocation = NO;
    self.geoCoder = [[CLGeocoder alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.locationCurrent = appDelegate.locationManagerGlobal.location;
    
    self.latitude = [NSNumber numberWithDouble:self.locationCurrent.coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:self.locationCurrent.coordinate.longitude];
        
}


#pragma mark - Search Controller Perform Search on Google

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //reset search results
    [self.locationSearchResults removeAllObjects];
    self.isEnteringCustomLocation = NO;
    
    NSString *keyword = self.searchController.searchBar.text;

    // Build the url string to send to Google - Searching for Places with Keyword rankedby distance to user's current location.
    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%@,%@&rankby=prominence&keyword=%@&sensor=true&key=%@", self.latitude, self.longitude, keyword, kGOOGLE_API_KEY];
    
    //New Google Search String - Sorted by Prominence
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&rankby=prominence&keyword=%@&sensor=true&key=%@&radius=50000", self.latitude, self.longitude, keyword, kGOOGLE_API_KEY];
    
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    
    for (int i = 0; i < [places count]; i++) {
        
        NSDictionary *place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        
        CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[[location objectForKey:@"lat"] doubleValue] longitude:[[location objectForKey:@"lng"] doubleValue]];
        
        GoogleResult *newSearchResult = [[GoogleResult alloc] initWithTitle:name address:vicinity location:locationPoint];
        
        [self.locationSearchResults addObject:newSearchResult];
        
    }
    
    //Reload new search results data into table.
    [self.searchResultsTable reloadData];
    
}


#pragma mark - TableView Data Source and Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isEnteringCustomLocation) {
        return 3;
    } else {
        return self.locationSearchResults.count;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"basicSearchResultsCell";
    static NSString *reuseIdentifierCustom = @"CustomSearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    if (self.isEnteringCustomLocation) {
        
        switch (indexPath.row) {
            case 0: {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierCustom];
                cell.textLabel.text = @"Custom User Location";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont fontWithName:EVNFontRegular size:19];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                break;
            }
            case 1: {
                
                //UserLocationTableCell *cell = (UserLocationTableCell *) [tableView dequeueReusableCellWithIdentifier:@"CustomLocationCell"];
                
                self.customUserLocationCell = (UserLocationTableCell *) [tableView dequeueReusableCellWithIdentifier:@"CustomLocationCell"];
                
                self.customUserLocationCell.locationAddressTextView.delegate = self;
                self.customUserLocationCell.locationNameTextField.delegate = self;
                self.customUserLocationCell.locationAddressTextView.text = @"";
                self.customUserLocationCell.locationNameTextField.text = @"Current Location";
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                return self.customUserLocationCell;
                //return self.customLocationUserInformationCell;
                
                break;
            }
            case 2: {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierCustom];
 
                cell.textLabel.text = @"";
                //return self.customLocationSaveCell;
                
                
                EVNLocationButton *useLocation = [[EVNLocationButton alloc] init];
                [useLocation setTitle:@"Use Location" forState:UIControlStateNormal];
                [useLocation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [useLocation.titleLabel setFont:[UIFont fontWithName:@"Lato-Light" size:18]];
                [useLocation.titleLabel setTextAlignment:NSTextAlignmentCenter];
                
                useLocation.clipsToBounds = NO;
                
                useLocation.backgroundColor = [UIColor orangeThemeColor];
                
                [cell addSubview:useLocation];
                useLocation.translatesAutoresizingMaskIntoConstraints = NO;
                
                NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:useLocation attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
                
                [cell addConstraint:constraintCenterX];
                
                NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:useLocation attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
                
                [cell addConstraint:constraintCenterY];
                
                NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:useLocation attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
                
                [cell addConstraint:constraintHeight];
                
                NSLayoutConstraint *constraintWidth = [NSLayoutConstraint constraintWithItem:useLocation attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
                
                [cell addConstraint:constraintWidth];
                
                [useLocation addTarget:self action:@selector(tappedUseLocation) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            default:
                break;
        }
        
        
    } else {
        
        if (self.locationSearchResults.count > 0) {
            
            GoogleResult *resultOfSearch = [self.locationSearchResults objectAtIndex:indexPath.row];
            
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


- (void) tappedUseLocation {
        
    NSIndexPath *locationInfoIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    UserLocationTableCell *locationCell = (UserLocationTableCell *) [self.searchResultsTable cellForRowAtIndexPath:locationInfoIndexPath];
    
    [self.geoCoder geocodeAddressString:locationCell.locationAddressTextView.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        
        if (!error && placemarks.count > 0) {
            
            CLPlacemark *placemark = [placemarks firstObject];
            
            GoogleResult *customLocation = [[GoogleResult alloc] initWithTitle:locationCell.locationNameTextField.text address:locationCell.locationAddressTextView.text location:placemark.location];
            
            NSString *locationTitle = customLocation.title;
            CLLocation *coordinates = customLocation.location;
            
            id<EventLocationSearch> strongDelegate = self.delegate;
            
            [strongDelegate locationSelectedWithCoordinates:coordinates andName:locationTitle];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Not a valid address." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            [errorAlert show];
            
        }
        
    }];

    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1 && self.isEnteringCustomLocation) {
        return 155.0f;
    } else {
        return 60.0f;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //grab the name of the location and the coordinates.  save the coordinates to parse and location name too.
    //call delegate that search has finished.
    
    if (self.isEnteringCustomLocation) {
        
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
                
                [self.geoCoder geocodeAddressString:locationCell.locationAddressTextView.text completionHandler:^(NSArray *placemarks, NSError *error) {
                    
                    
                    if (!error && placemarks.count > 0) {
                        
                        CLPlacemark *placemark = [placemarks firstObject];
                        
                        GoogleResult *customLocation = [[GoogleResult alloc] initWithTitle:locationCell.locationNameTextField.text address:locationCell.locationAddressTextView.text location:placemark.location];
                        
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
        
        GoogleResult *selectedLocation = [self.locationSearchResults objectAtIndex:indexPath.row];
        
        NSString *locationTitle = selectedLocation.title;
        CLLocation *coordinates = selectedLocation.location;
        
        id<EventLocationSearch> strongDelegate = self.delegate;
        
        [strongDelegate locationSelectedWithCoordinates:coordinates andName:locationTitle];
        
    }
    
}


#pragma mark - UITextField and View Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

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


- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.tapToDismissView = [[UIView alloc] initWithFrame:self.view.frame];
    self.tapToDismissView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tapToDismissView];
    
    //Gesture Recognizer to Dismiss Keyboard on Tap in View
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    tapToDismiss.cancelsTouchesInView = YES;
    [self.tapToDismissView addGestureRecognizer:tapToDismiss];
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.tapToDismissView removeFromSuperview];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add details about your event...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        NSLog(@"WE HERE");
    }
    
    [textView resignFirstResponder];
}


- (void)tapToDismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Button Actions

- (IBAction)cancelLocationSearch:(id)sender {
    
    id<EventLocationSearch> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(locationSearchDidCancel)]) {
        
        [strongDelegate locationSearchDidCancel];
    }
}

- (IBAction)getCurrentLocation:(id)sender {
    
    self.isEnteringCustomLocation = YES;
    [self.searchController.searchBar resignFirstResponder];
    
    [self.geoCoder reverseGeocodeLocation:self.locationCurrent completionHandler:^(NSArray *placemarks, NSError *error) {
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
