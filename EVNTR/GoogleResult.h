//
//  GoogleResult.h
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GoogleResult : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) CLLocation *location;

- (id)initWithTitle:(NSString*)name address:(NSString*)locationAddress location:(CLLocation*)locationCoordinates;

@end
