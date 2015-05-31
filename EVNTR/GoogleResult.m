//
//  GoogleResult.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "GoogleResult.h"

@implementation GoogleResult

- (id)initWithTitle:(NSString*)name address:(NSString*)locationAddress location:(CLLocation*)locationCoordinates {
    
    if ((self = [super init])) {
        _title = name;
        _address = locationAddress;
        _location = locationCoordinates;
    }
    
    return self;
}



@end
