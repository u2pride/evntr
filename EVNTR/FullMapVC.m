//
//  FullMapVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "FullMapVC.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface FullMapVC ()

@end

@implementation FullMapVC

#pragma mark - Lifecyle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Event Location";
    self.edgesForExtendedLayout = UIRectEdgeNone;

    //Map Initialization
    MKMapView *map = [[MKMapView alloc] initWithFrame:self.view.frame];
    
    MKPointAnnotation *currentLocationAnnotation = [[MKPointAnnotation alloc] init];
    currentLocationAnnotation.coordinate = self.locationOfEvent.coordinate;
    currentLocationAnnotation.title = self.eventLocationName;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(self.locationOfEvent.coordinate, MKCoordinateSpanMake(0.05, 0.05));
    
    [map addAnnotation:currentLocationAnnotation];
    [map setRegion:region animated:YES];
    
    [self.view addSubview:map];
    
    //Directions Icon
    UIBarButtonItem *directions = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"DirectionsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(getDirectionsToEvent)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:directions];
    
}


#pragma mark - User Actions

- (void) getDirectionsToEvent {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.amplitudeInstance logEvent:@"Accessed Event Directions"];
    
    CLLocation *fromLocation = self.locationOfEvent;
    
    MKPlacemark *eventPlacemark = [[MKPlacemark alloc] initWithPlacemark:self.locationPlacemark];
    
    MKMapItem *mapItemEventLocation = [[MKMapItem alloc] initWithPlacemark:eventPlacemark];
    MKMapItem *mapItem = [MKMapItem mapItemForCurrentLocation];
    
    // Create a region centered on the starting point with a 10km span
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);
    
    NSArray *locationsForMap = [NSArray arrayWithObjects:mapItem, mapItemEventLocation, nil];
    
    // Open the item in Maps with the map region to display.
    [MKMapItem openMapsWithItems:locationsForMap
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                  [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey, [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsMapTypeKey, nil]];
    

}


@end
