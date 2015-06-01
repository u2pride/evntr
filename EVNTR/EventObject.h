//
//  EventObject.h
//  EVNTR
//
//  Created by Alex Ryan on 4/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface EventObject : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descriptionOfEvent;
@property (nonatomic, strong) NSDate *dateOfEvent;
@property (nonatomic, strong) PFGeoPoint *locationOfEvent;
@property (nonatomic, strong) NSNumber *typeOfEvent;
@property (nonatomic, strong) NSNumber *numPictures;
@property (nonatomic, strong) NSNumber *numAttenders;
@property (nonatomic, strong) NSNumber *numComments;

@property (nonatomic, strong) NSArray *eventImages;
@property (nonatomic, strong) NSString *nameOfLocation;
@property (nonatomic, strong) PFFile *coverPhoto;
@property (nonatomic, strong) EVNUser *parent;

+ (NSString *)parseClassName;

- (NSString *) eventTypeForHomeView;
- (NSString *) eventDateShortStyleAndVisible:(BOOL)visible;
- (NSString *) eventTimeShortStyeAndVisible:(BOOL)visible;

- (void) coverImage:(void (^)(UIImage *image))completionBlock;
- (BOOL) allowUserToAddPhotosAtThisTime;

- (void) queryRSVPForUser:(EVNUser *)userObject completion:(void (^)(BOOL isAttending, NSString *status, BOOL error))completionBlock;
- (void) queryApprovalStatusOfUser:(EVNUser *)user completion:(void (^)(BOOL isAttending, NSString *status, BOOL error))completionBlock;

- (void) rsvpUser:(EVNUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) unRSVPUser:(EVNUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) requestAccessForUser:(EVNUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) inviteUsers:(NSArray *)users completion:(void (^)(BOOL success))completionBlock;

- (void) queryForAttendersWithCompletion:(void (^)(NSArray *attenders))completionBlock;
- (void) queryForStandbyUsersWithIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *users))completionBlock;
- (void) queryForImagesWithCompletion:(void (^)(NSArray *images))completionBlock;
- (void) queryForCommentsWithCompletion:(void (^)(NSArray *comments))completionBlock;


/*

 Assuming you can now access all properties using EventObject.title 
 
 You should create new objects with the object class method. This constructs an autoreleased instance of your type and correctly handles further subclassing. To create a reference to an existing object, use objectWithoutDataWithObjectId:.
 
 + (void) queryForActivitiesWithContent:(PFObject *)object ofType:(NSNumber *)type from:(EVNUser *)fromUser to:(EVNUser *)toUser withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *activities))completionBlock;

*/

@end
