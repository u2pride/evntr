//
//  FullMapVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "FullMapVC.h"
#import <MapKit/MapKit.h>

@interface FullMapVC ()

@end

@implementation FullMapVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MKMapView *map = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];

    self.title = @"Event Location";
    
    MKPointAnnotation *currentLocationAnnotation = [[MKPointAnnotation alloc] init];
    currentLocationAnnotation.coordinate = self.locationOfEvent.coordinate;
    
    //Setting up Map to Current Location
    MKCoordinateRegion region = MKCoordinateRegionMake(self.locationOfEvent.coordinate, MKCoordinateSpanMake(0.05, 0.05));
    
    [map addAnnotation:currentLocationAnnotation];
    [map setRegion:region animated:YES];
    
    [self.view addSubview:map];
    
    
    UIBarButtonItem *directions = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(getDirectionsToEvent)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:directions];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
}

- (void) getDirectionsToEvent {
    
    CLLocation *fromLocation = self.locationOfEvent;
    
    MKPlacemark *eventPlacemark = [[MKPlacemark alloc] initWithPlacemark:self.locationPlacemark];
    
    MKMapItem *mapItemEventLocation = [[MKMapItem alloc] initWithPlacemark:eventPlacemark];
    MKMapItem *mapItem = [MKMapItem mapItemForCurrentLocation];
    
    // Create a region centered on the starting point with a 10km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);
    
    
    NSArray *locationsForMap = [NSArray arrayWithObjects:mapItem, mapItemEventLocation, nil];
    
    
    // Open the item in Maps, specifying the map region to display.
    [MKMapItem openMapsWithItems:locationsForMap
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsMapTypeKey, nil]];
    
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)dealloc
{
    NSLog(@"fullmapvc is being deallocated");
}

@end
