//
//  EventObject.h
//  EVNTR
//
//  Created by Alex Ryan on 4/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface EventObject : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descriptionOfEvent;
@property (nonatomic, strong) NSDate *dateOfEvent;
@property (nonatomic, strong) PFGeoPoint *locationOfEvent;
@property (nonatomic, strong) NSNumber *typeOfEvent;
@property (nonatomic, strong, readonly) PFRelation *attenders;
@property (nonatomic, strong, readonly) PFRelation *invitedUsers;
@property (nonatomic, strong) NSArray *eventImages;
@property (nonatomic, strong) NSString *nameOfLocation;
@property (nonatomic, strong) PFFile *coverPhoto;
@property (nonatomic, strong) PFUser *parent; //TODO: Does this work?


+ (NSString *)parseClassName;

- (NSString *) eventTypeForHomeView;
- (NSString *) eventDateShortStyle;
- (NSString *) eventTimeShortStye;
- (void) coverImage:(void (^)(UIImage *image))completionBlock;

- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock;

- (BOOL) allowUserToAddPhotosAtThisTime;


/*

 Assuming you can now access all properties using EventObject.title 
 
 You should create new objects with the object class method. This constructs an autoreleased instance of your type and correctly handles further subclassing. To create a reference to an existing object, use objectWithoutDataWithObjectId:.
 
*/

@end
