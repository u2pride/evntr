//
//  MapForEventView.h
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface MapForEventView : UIView

@property (nonatomic, strong) CLLocation *eventLocation;
@property (nonatomic, strong) NSString *address;

@property (nonatomic) float distanceAway;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, strong) NSTimer *timerForRandomize;

- (void) startedLoading;
- (void) finishedLoadingWithLocationAvailable:(BOOL)isLocationVisible;
- (void) randomizeLocation;

@end
