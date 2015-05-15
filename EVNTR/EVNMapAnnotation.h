//
//  EVNMapAnnotation.h
//  EVNTR
//
//  Created by Alex Ryan on 5/14/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface EVNMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

- (id) initWithTitle:(NSString *)newTitle location:(CLLocationCoordinate2D)location;

- (MKAnnotationView *) annotationView;

@end
