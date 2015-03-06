//
//  GoogleResult.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "GoogleResult.h"

@implementation GoogleResult

@synthesize title, location, address;

- (id)initWithTitle:(NSString*)name address:(NSString*)locationAddress location:(CLLocation*)locationCoordinates {
    if ((self = [super init])) {
        self.title = name;
        self.address = locationAddress;
        self.location = locationCoordinates;
        
    }
    return self;
}

@end
