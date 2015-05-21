//
//  EVNMapAnnotation.m
//  EVNTR
//
//  Created by Alex Ryan on 5/14/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNMapAnnotation.h"

@implementation EVNMapAnnotation

- (id) initWithTitle:(NSString *)newTitle location:(CLLocationCoordinate2D)location {
    
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    
    return self;
}



- (MKAnnotationView *)annotationView {
    
    //MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"customAnnotation"];
    
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"customAnnotation"];
    
    annotationView.pinColor = MKPinAnnotationColorPurple;
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];

    
    return annotationView;

}

@end
