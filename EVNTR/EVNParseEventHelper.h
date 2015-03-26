//
//  EVNParseEventHelper.h
//  EVNTR
//
//  Created by Alex Ryan on 3/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVNEvent.h"
#import <Parse/Parse.h>

@interface EVNParseEventHelper : NSObject

//example - not used.
+ (void) queryForActivitiesWithContent:(PFObject *)object ofType:(NSNumber *)type from:(PFUser *)fromUser to:(PFUser *)toUser withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *activities))completionBlock;



//Query For Standby Users - Returns Error and Standby Users = nil if error.
+ (void) queryForStandbyUsersWithContent:(EVNEvent *)event ofType:(NSNumber *)type withIncludeKey:(NSString *)key completion:(void (^)(NSError *error, NSArray *users))completionBlock;


+ (void) queryRSVPForUsername:(NSString *)username atEvent:(EVNEvent *)event completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;

+ (void) queryApprovalStatusOfUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL isAttending, NSString *status))completionBlock;


+ (void) requestAccessForUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) rsvpUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) unRSVPUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL success))completionBlock;

+ (void) inviteUsers:(NSArray *)users toEvent:(EVNEvent *)event completion:(void (^)(BOOL success))completionBlock;

@end
