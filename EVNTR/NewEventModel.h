//
//  NewEventModel.h
//  EVNTR
//
//  Created by Alex Ryan on 3/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NewEventModel : NSObject

@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, assign) int eventType;
@property (nonatomic, strong) PFFile *eventCoverImage;

@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) PFGeoPoint *eventCoordinates;
@property (nonatomic, strong) NSString *eventLocationName;
@property (nonatomic, strong) NSDate *eventDate;

- (id)initWithTitle:(NSString*)title eventType:(int)type coverImage:(PFFile *)image;


@end
