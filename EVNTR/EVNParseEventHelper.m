//
//  EVNParseEventHelper.m
//  EVNTR
//
//  Created by Alex Ryan on 3/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNParseEventHelper.h"
#import "EVNConstants.h"

@implementation EVNParseEventHelper

+ (void) queryForActivitiesWithContent:(PFObject *)object ofType:(NSNumber *)type from:(PFUser *)fromUser to:(PFUser *)toUser withIncludeKey:(NSString *)key completion:(void (^)(NSError *, NSArray *))completionBlock {
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:object];
    [queryForStandbyUsers whereKey:@"type" equalTo:type];
    [queryForStandbyUsers includeKey:key];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        
        completionBlock(error, activities);
        
    }];

}


+ (void) queryForStandbyUsersWithContent:(EVNEvent *)event ofType:(NSNumber *)type withIncludeKey:(NSString *)key completion:(void (^)(NSError *, NSArray *))completionBlock {
    
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:event.backingObject];
    [queryForStandbyUsers whereKey:@"type" equalTo:type];
    [queryForStandbyUsers includeKey:key];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *standbyActivities, NSError *error) {
        
        NSMutableArray *usersOnStandby = [[NSMutableArray alloc] init];
        
        if (error) {
            usersOnStandby = nil;
            completionBlock(error, usersOnStandby);
            
        } else {
            for (PFObject *activity in standbyActivities) {
                
                PFUser *userOnStandby = activity[@"from"];
                [usersOnStandby addObject:userOnStandby];
                
            }
            
            completionBlock(error, usersOnStandby);
        }
        
    }];
    

}


+ (void) queryRSVPForUsername:(NSString *)username atEvent:(EVNEvent *)event completion:(void (^)(BOOL, NSString *))completionBlock {
    
    PFRelation *eventAttendersRelation = event.eventAttenders;
    PFQuery *attendingQuery = [eventAttendersRelation query];
    [attendingQuery whereKey:@"username" equalTo:username];
    [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object && !error) {
            completionBlock(YES, kAttendingEvent);
        } else {
            completionBlock(NO, kNotAttendingEvent);
        }
        
    }];
    
}

+ (void) queryApprovalStatusOfUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL, NSString *))completionBlock {
    
    PFQuery *requestedAccessQuery = [PFQuery queryWithClassName:@"Activities"];
    [requestedAccessQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    [requestedAccessQuery whereKey:@"from" equalTo:user];
    [requestedAccessQuery whereKey:@"activityContent" equalTo:event.backingObject];
    [requestedAccessQuery findObjectsInBackgroundWithBlock:^(NSArray *requestedActivityObjects, NSError *error) {
        
        __block NSString *status = kNotAttendingEvent;

        if (error) {
            completionBlock(NO, @"Error");
        
        } else {
            
            //User has requested Access to Event
            if (requestedActivityObjects.count > 0) {
                
                status = kRSVPedForEvent;
                
                //Now Query For Access Granted
                PFQuery *accessGrantedQuery = [PFQuery queryWithClassName:@"Activities"];
                [accessGrantedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
                [accessGrantedQuery whereKey:@"to" equalTo:user];
                [accessGrantedQuery whereKey:@"activityContent" equalTo:event.backingObject];
                [accessGrantedQuery findObjectsInBackgroundWithBlock:^(NSArray *accessActivityObjects, NSError *error) {
                    
                    if (error) {
                        completionBlock(NO, @"Error");
                        
                    } else {
                        //Access Granted to Event
                        if (accessActivityObjects.count > 0) {
                            
                            status = kGrantedAccessToEvent;
                            
                            completionBlock(YES, status);
                            
                        } else {
                            completionBlock(NO, status);
                        }
                        
                    }
                    
                }];
                
            } else {
                
                completionBlock(NO, status);
            }
            
        }
        
    }];
    
    
}


+ (void) requestAccessForUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL))completionBlock {
    
    //RSVP User for Event
    PFObject *rsvpActivity = [PFObject objectWithClassName:@"Activities"];
    rsvpActivity[@"from"] = user;
    rsvpActivity[@"to"] = event.eventCreator;
    rsvpActivity[@"type"] = [NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY];
    rsvpActivity[@"activityContent"] = event.backingObject;
    
    [rsvpActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
        
    }];
    
}




+ (void) rsvpUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL))completionBlock {
    
    PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
    newAttendingActivity[@"to"] = user;
    newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
    newAttendingActivity[@"activityContent"] = event.backingObject;
    [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
       
    }];
    
}


+ (void) unRSVPUser:(PFUser *)user forEvent:(EVNEvent *)event completion:(void (^)(BOOL))completionBlock {
    
    PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
    [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [queryForRSVP whereKey:@"to" equalTo:user];
    [queryForRSVP whereKey:@"activityContent" equalTo:event.backingObject];
    [queryForRSVP findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            completionBlock(NO);
        }
        
        PFObject *previousActivity = [objects firstObject];
        [previousActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            completionBlock(succeeded);
            
        }];
        
    }];
}


+ (void) inviteUsers:(NSArray *)users toEvent:(EVNEvent *)event completion:(void (^)(BOOL))completionBlock {
    
    __block BOOL success = YES;
    
    for (PFUser *user in users) {
        
        //If Private Event - Also Add Invited People to invitedUsers column as a PFRelation - actually maybe not
        
        PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
        
        newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
        newInvitationActivity[@"from"] = [PFUser currentUser];
        newInvitationActivity[@"to"] = user;
        newInvitationActivity[@"activityContent"] = event.backingObject;
        
        //save the invitation activities
        [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            success = (succeeded) ? YES : NO;
            
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    }
    
    completionBlock(success);
    
}



@end
