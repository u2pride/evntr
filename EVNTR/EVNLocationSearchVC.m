//
//  EVNLocationSearchVC.m
//  EVNTR
//
//  Created by Alex Ryan on 5/7/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNLocationSearchVC.h"
#import "EVNConstants.h"
#import "GoogleResult.h"
#import "UIColor+EVNColors.h"
#import "EVNMapAnnotation.h"

#define kGOOGLE_API_KEY @"AIzaSyDbbFOj98Z6G6lUskNuUlDr0uYPvrR-cZo"
const int NUMBER_OF_PLACES_RESULTS = 10;


@interface EVNLocationSearchVC ()

@property (strong, nonatomic) MKMapView *locationMapView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableView *locationSearchResultsTable;

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) UIButton *setLocationButton;

@property (nonatomic) BOOL isShowingMapView;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) EVNMapAnnotation *locationAnnotation;

- (IBAction)cancelLocation:(id)sender;

@end

@implementation EVNLocationSearchVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = NO;
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
    
    
    self.searchResults = [[NSMutableArray alloc] init];
    
    self.locationMapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.locationMapView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];

    
    self.setLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [self.setLocationButton setTitle:@"Set Location" forState:UIControlStateNormal];
    [self.setLocationButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [self.setLocationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setLocationButton addTarget:self action:@selector(chooseLocation) forControlEvents:UIControlEventTouchUpInside];
    self.setLocationButton.backgroundColor = [UIColor orangeThemeColor];
    self.setLocationButton.center = self.view.center;
    self.setLocationButton.frame = CGRectMake(self.setLocationButton.frame.origin.x, self.view.frame.size.height - 70, self.view.frame.size.width, 70);
    
    
    
    //self.locationSearchResultsTable.tableHeaderView = self.searchController.searchBar;

    self.locationMapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.setLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self.view addSubview:self.locationMapView];
    
    //CGRect resultsTableFrame = CGRectMake(0, self.searchController.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    self.locationSearchResultsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.locationSearchResultsTable.delegate = self;
    self.locationSearchResultsTable.dataSource = self;
    
    
    //self.locationSearchResultsTable.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.locationSearchResultsTable.translatesAutoresizingMaskIntoConstraints = NO;
    

    [self.view addSubview:self.locationSearchResultsTable];
    
    [self.view bringSubviewToFront:self.locationMapView];

    [self.view addSubview:self.searchController.searchBar];
    [self.view addSubview:self.setLocationButton];

    
    self.view.backgroundColor = [UIColor purpleColor];
    
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(movePinToCustomLocation:)];
    
    [self.locationMapView addGestureRecognizer:longPressGR];
    
}

- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.searchController.searchBar sizeToFit];
    
}

- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchController.searchBar
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchController.searchBar
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.self.searchController.searchBar
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.setLocationButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.setLocationButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.setLocationButton
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.setLocationButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.0
                                                           constant:70.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationSearchResultsTable
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationSearchResultsTable
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationSearchResultsTable
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationSearchResultsTable
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:self.searchController.searchBar.frame.size.height]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationMapView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationMapView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationMapView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.locationMapView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    
}

- (void) setIsShowingMapView:(BOOL)isShowingMapView {
    
    if (isShowingMapView) {
        NSLog(@"Show Map");
    
        [self.view bringSubviewToFront:self.locationMapView];
        [self.view bringSubviewToFront:self.searchController.searchBar];
        [self.view bringSubviewToFront:self.setLocationButton];
        [self.view bringSubviewToFront:self.navigationController.navigationBar];
        
    } else {
        NSLog(@"Show Results Table");
        [self.view bringSubviewToFront:self.locationSearchResultsTable];
        [self.view bringSubviewToFront:self.searchController.searchBar];
        [self.view bringSubviewToFront:self.navigationController.navigationBar];

        
    }
    
    
    _isShowingMapView = isShowingMapView;
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.currentLocation = appDelegate.locationManagerGlobal.location;
    
    [self.locationMapView setRegion:MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.02, 0.02)) animated:YES];
    
    self.locationAnnotation = [[EVNMapAnnotation alloc] initWithTitle:@"Current Location" location:self.currentLocation.coordinate];
    
    [self.locationMapView addAnnotation:self.locationAnnotation];
    [self.locationMapView selectAnnotation:self.locationAnnotation animated:YES];
    
    
    
}


- (void) chooseLocation {
    
    NSLog(@"Choose location");
    
    if (self.presentedViewController) {
        
        [self dismissViewControllerAnimated:NO completion:^{
            [self formatChosenLocation];
        }];
    } else {
        [self formatChosenLocation];
    }
    
}


- (void) formatChosenLocation {
 
    if ([self.locationAnnotation.title isEqualToString:@"Custom Location"] || [self.locationAnnotation.title isEqualToString:@"Current Location"]) {
        
        UIAlertController *customLocationName = [UIAlertController alertControllerWithTitle:@"Name This Location" message:@"Pick a name for this location.  It'll appear on your event page, so make sure it's something others will understand" preferredStyle:UIAlertControllerStyleAlert];
        
        [customLocationName addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.delegate = self;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *nameTextField = (UITextField *) customLocationName.textFields.firstObject;
            
            if (nameTextField.text.length > 0 && nameTextField.text.length <= MAX_LOCATION_NAME_LENGTH) {
                
                id<EventLocationSearch> strongDelegate = self.delegate;
                
                CLLocation *locationChosen = [[CLLocation alloc] initWithLatitude:self.locationAnnotation.coordinate.latitude longitude:self.locationAnnotation.coordinate.longitude];
                
                [strongDelegate locationSelectedWithCoordinates:locationChosen andName:nameTextField.text];
                
            }
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        
        [customLocationName addAction:saveAction];
        [customLocationName addAction:cancelAction];
        
        [self presentViewController:customLocationName animated:YES completion:nil];
        
    } else {
        
        id<EventLocationSearch> strongDelegate = self.delegate;
        
        CLLocation *locationChosen = [[CLLocation alloc] initWithLatitude:self.locationAnnotation.coordinate.latitude longitude:self.locationAnnotation.coordinate.longitude];
        
        [strongDelegate locationSelectedWithCoordinates:locationChosen andName:self.locationAnnotation.title];
        
    }
}


- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= MAX_LOCATION_NAME_LENGTH || returnKey;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    EVNMapAnnotation *annotationCurrent = (EVNMapAnnotation *)annotation;
    
    return annotationCurrent.annotationView;
}


#pragma mark - UISearchController

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSLog(@"updateSearchResults with text:  %@", self.searchController.searchBar.text);
    
    if (self.searchController.searchBar.text.length > 0) {
        
        NSLog(@"Inside here");
        
        NSString *keyword = self.searchController.searchBar.text;
        
        //New Google Search String - Sorted by Prominence
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&rankby=prominence&keyword=%@&sensor=true&key=%@&radius=50000", [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude], [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude], keyword, kGOOGLE_API_KEY];
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *googleRequestURL=[NSURL URLWithString:url];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.EVNTR.bckqueue", 0);
        
        dispatch_async(backgroundQueue, ^{
            
            NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
            
            [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
            
        });
        
    }
    
}


- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"cancel button clicked");
    
    [self.searchController.searchBar setShowsCancelButton:NO animated:YES];

    self.isShowingMapView = YES;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    NSLog(@"Search Bar Begin Editing");
    
    [self.searchController.searchBar setShowsCancelButton:YES animated:YES];
    
    self.isShowingMapView = NO;
    
    
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Button Clicked");
    

}

- (void) movePinToCustomLocation:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint touchLocation = [gestureRecognizer locationInView:self.locationMapView];
    
    CLLocationCoordinate2D mapCoordinate = [self.locationMapView convertPoint:touchLocation toCoordinateFromView:self.locationMapView];
    
    self.locationAnnotation.title = @"Custom Location";
    self.locationAnnotation.coordinate = mapCoordinate;

    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateDragging) {
        
        EVNMapAnnotation *currentAnnotation = (EVNMapAnnotation *) view.annotation;
        currentAnnotation.title = @"Custom Location";
        
    }
    
}

- (void) fetchedData: (NSData *)responseData {
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *places = [json objectForKey:@"results"];
    
    int numberOfResults = (int) MIN([places count], NUMBER_OF_PLACES_RESULTS - 1);
    
    NSMutableArray *fetchedCleanResults = [[NSMutableArray alloc] init];
    [fetchedCleanResults removeAllObjects];
    
    for (int i = 0; i < numberOfResults; i++) {
        
        
        NSDictionary *place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        
        CLLocation *locationPoint = [[CLLocation alloc] initWithLatitude:[[location objectForKey:@"lat"] doubleValue] longitude:[[location objectForKey:@"lng"] doubleValue]];
        
        GoogleResult *locationFromGoogle = [[GoogleResult alloc] initWithTitle:name address:vicinity location:locationPoint];
        
        [fetchedCleanResults addObject:locationFromGoogle];
        
    }
    
    [self.searchResults removeAllObjects];
    [self.searchResults addObjectsFromArray:fetchedCleanResults];
    
    [self.locationSearchResultsTable reloadData];
    
}


#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"basicSearchResultsCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Light" size:13];

    if (indexPath.row == 0) {
        
        UIFont *boldFont = [UIFont fontWithName:@"Lato-Bold" size:15];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName, nil];
        //const NSRange range = NSMakeRange(8,12); // range of " 2012/10/14 ". Ideally this should not be hardcoded
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:@"Current Location"
                                               attributes:attrs];
        
        
        cell.textLabel.attributedText = attributedText;
        cell.detailTextLabel.text = @"";
    
    } else {
        
        GoogleResult *resultOfSearch = [self.searchResults objectAtIndex:indexPath.row - 1];
        
        NSString *locationTitle = resultOfSearch.title;
        NSString *address = resultOfSearch.address;
        
        cell.textLabel.text = locationTitle;
        cell.detailTextLabel.text = address;
    
    }
    
    
    /*
    if (self.searchResults.count > 0) {
        
        GoogleResult *resultOfSearch = [self.searchResults objectAtIndex:indexPath.row];
        
        NSString *locationTitle = resultOfSearch.title;
        NSString *address = resultOfSearch.address;
        
        NSLog(@"cellForRowAtIndexPath with title: %@", resultOfSearch.title);

        
        cell.textLabel.text = locationTitle;
        cell.detailTextLabel.text = address;
        
    } else {
        cell.textLabel.text = @"No Results";
        cell.detailTextLabel.text = @"try another search";
    }
    */
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"self.searchResults.count - %lu", (unsigned long)self.searchResults.count);
    
    int numRows = (int) MIN(self.searchResults.count + 1, 10);
    
    return numRows;
    
    /*
    if (self.searchResults.count > 0) {
        NSLog(@"self.searchResults.count");
        return self.searchResults.count;
    } else {
        NSLog(@"returning 1");
        return 1;
    }
    */
    
}



#pragma mark - UITableView Delegate Methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchController.searchBar setShowsCancelButton:NO animated:YES];
    self.searchController.searchBar.text = @"";
    [self.searchController.searchBar resignFirstResponder];
    
    [self.locationMapView removeAnnotation:self.locationAnnotation];
    
    if (indexPath.row == 0) {
        //current location
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
        CLLocationCoordinate2D location;
        location.latitude = self.currentLocation.coordinate.latitude;
        location.longitude = self.currentLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [self.locationMapView setRegion:region animated:YES];
        
        self.isShowingMapView = YES;
        
        self.locationAnnotation = [[EVNMapAnnotation alloc] initWithTitle:@"Current Location" location:self.currentLocation.coordinate];
        
        [self.locationMapView addAnnotation:self.locationAnnotation];
        [self.locationMapView selectAnnotation:self.locationAnnotation animated:YES];
        
    } else {
        
        GoogleResult *selectedResult = [self.searchResults objectAtIndex:indexPath.row - 1];
        
        NSLog(@"selected: %@", selectedResult.title);
        
        CLLocation *coordinates = selectedResult.location;
            
        self.isShowingMapView = YES;
        
        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinates.coordinate, span);
        
        [self.locationMapView setRegion:region animated:YES];
        
        
        self.locationAnnotation = [[EVNMapAnnotation alloc] initWithTitle:selectedResult.title location:coordinates.coordinate];
        //self.locationAnnotation.title = selectedResult.title;
        //self.locationAnnotation.coordinate = coordinates.coordinate;
        
        [self.locationMapView addAnnotation:self.locationAnnotation];
        [self.locationMapView selectAnnotation:self.locationAnnotation animated:YES];

        
        
        
    }
    

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelLocation:(id)sender {
    
    id<EventLocationSearch> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(locationSearchDidCancel)]) {
        
        [strongDelegate locationSearchDidCancel];
    }
    
}


@end
