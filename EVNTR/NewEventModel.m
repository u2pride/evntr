//
//  NewEventModel.m
//  EVNTR
//
//  Created by Alex Ryan on 3/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "NewEventModel.h"

@implementation NewEventModel

- (id)initWithTitle:(NSString*)title eventType:(int)type coverImage:(PFFile *)image {

    if (self = [super init]) {
        _eventTitle = title;
        _eventType = type;
        _eventCoverImage = image;
    }
    
    return self;
}


- (id)initWithTitle:(NSString *)title eventType:(int)type coverImage:(PFFile *)image eventDescription:(NSString *)description location:(PFGeoPoint *)coordinates locationName:(NSString *)name eventDate:(NSDate *)eventDate backingObject:(PFObject *)object {
 
    if (self = [super init]) {
        _eventTitle = title;
        _eventType = type;
        _eventCoverImage = image;
        _eventDescription = description;
        _eventCoordinates = coordinates;
        _eventLocationName = name;
        _eventDate = eventDate;
        _object = object;
    }
    
    return self;
    
}

@end
