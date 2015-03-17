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

    if ((self = [super init])) {
        _eventTitle = title;
        _eventType = type;
        _eventCoverImage = image;
    }
    
    return self;
}

@end
