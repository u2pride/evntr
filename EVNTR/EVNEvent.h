//
//  EVNEvent.h
//  EVNTR
//
//  Created by Alex Ryan on 3/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface EVNEvent : NSObject

//Corresponds to Parse Object ID
@property (nonatomic, readonly, strong) NSString *eventID;
@property (nonatomic, readonly, strong) NSString *eventTitle;
@property (nonatomic, readonly, strong) NSNumber *eventType;
@property (nonatomic, readonly, strong) PFUser *eventCreator;
@property (nonatomic, readonly, strong) NSString *eventDescription;
@property (nonatomic, readonly, strong) NSDate *eventDate;

@property (nonatomic, readonly, strong) PFFile *eventCoverPhoto;
@property (nonatomic, readonly, strong) NSArray *eventPhotos;
@property (nonatomic, readonly, strong) PFGeoPoint *eventLocationGeoPoint;
@property (nonatomic, readonly, strong) NSString *eventLocationName;

@property (nonatomic, readonly, strong) PFRelation *eventInvitedUsers;
@property (nonatomic, readonly, strong) PFRelation *eventAttenders;

@property (nonatomic, readonly, strong) PFObject *backingObject;


- (id)initWithID:(NSString *)ID
            name:(NSString *)title
            type:(NSNumber *)type
         creator:(PFUser *)creator
      coverImage:(PFFile *)image
     description:(NSString *)description
            date:(NSDate *)date
locationGeoPoint:(PFGeoPoint *)locationGeoPoint
    locationName:(NSString *)locationName
          photos:(NSArray *)photos
    invitedUsers:(PFRelation *)invitedUsers
       attendees:(PFRelation *)attendees
   backingObject:(PFObject *)object;


- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock;

- (BOOL) allowUserToAddPhotosAtThisTime;
- (NSString *) numberOfPhotos;

- (NSString *) eventDateShortStyle;
- (NSString *) eventTimeShortStye;

- (NSString *) dateForEventDetails;


- (NSString *) eventTypeForHomeView;

//Example Methods
//- (NSArray *) attendees;


@end
