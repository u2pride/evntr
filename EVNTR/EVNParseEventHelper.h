//
//  EVNParseEventHelper.h
//  EVNTR
//
//  Created by Alex Ryan on 3/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventObject.h"
#import <Parse/Parse.h>

@interface EVNParseEventHelper : NSObject

//example - not used.
+ (void) queryForActivitiesWithContent:(PFObject *)object ofType:(NSNumber *)type from:(PFUser *)fromUser to:(PFUser *)toUser withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *activities))completionBlock;



//Consider using NSSet:  http://stackoverflow.com/questions/2288266/symmetric-difference-of-two-arrays

//Query For Standby Users - Returns Error and Standby Users = nil if error.
+ (void) queryForStandbyUsersWithContent:(EventObject *)event ofType:(NSNumber *)type withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *users))completionBlock;


+ (void) queryRSVPForUsername:(NSString *)username atEvent:(EventObject *)event completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;

+ (void) queryApprovalStatusOfUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;


+ (void) requestAccessForUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) rsvpUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) unRSVPUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) inviteUsers:(NSArray *)users toEvent:(EventObject *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) queryForUsersFollowing:(PFUser *)user completion:(void (^)(NSArray *following))completionBlock;


@end
