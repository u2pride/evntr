//
//  MapForEventView.h
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapForEventView : UIView

@property (nonatomic, strong) CLLocation *eventLocation;
@property (nonatomic, strong) NSString *address;

@property (nonatomic) float distanceAway;
@property (nonatomic, strong) MKMapView *mapView;


@end