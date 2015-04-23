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
@property (nonatomic, strong) PFUser *parent;

+ (NSString *)parseClassName;


- (NSString *) eventTypeForHomeView;
- (NSString *) eventDateShortStyle;
- (NSString *) eventTimeShortStye;
- (void) coverImage:(void (^)(UIImage *image))completionBlock;

- (BOOL) allowUserToAddPhotosAtThisTime;

- (void) queryForStandbyUsersWithIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *users))completionBlock;

- (void) queryRSVPForUserId:(NSString *)userObjectId completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;
- (void) queryApprovalStatusOfUser:(PFUser *)user completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;

- (void) requestAccessForUser:(PFUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) rsvpUser:(PFUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) unRSVPUser:(PFUser *)user completion:(void (^)(BOOL success))completionBlock;
- (void) inviteUsers:(NSArray *)users completion:(void (^)(BOOL success))completionBlock;

- (void) estimateNumberOfPhotosWithCompletion:(void (^)(int count))completionBlock;
- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock;

- (void) queryForImagesWithCompletion:(void (^)(NSArray *images))completionBlock;
- (void) queryForCommentsWithCompletion:(void (^)(NSArray *comments))completionBlock;


/*

 Assuming you can now access all properties using EventObject.title 
 
 You should create new objects with the object class method. This constructs an autoreleased instance of your type and correctly handles further subclassing. To create a reference to an existing object, use objectWithoutDataWithObjectId:.
 
 + (void) queryForActivitiesWithContent:(PFObject *)object ofType:(NSNumber *)type from:(PFUser *)fromUser to:(PFUser *)toUser withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *activities))completionBlock;

*/

@end
