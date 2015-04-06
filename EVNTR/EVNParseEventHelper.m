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
    [queryForStandbyUsers includeKey:@"from"];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        
        completionBlock(error, activities);
        
    }];

}


+ (void) queryForStandbyUsersWithContent:(EventObject *)event ofType:(NSNumber *)type withIncludeKey:(NSString *)key completion:(void (^)(NSError *, NSArray *))completionBlock {
    
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:event];
    [queryForStandbyUsers whereKey:@"type" equalTo:type];
    [queryForStandbyUsers includeKey:@"from"];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *standbyActivities, NSError *error) {
        
        NSLog(@"FIRST QUERY RESULTS:  %@", standbyActivities);
        
        __block NSMutableArray *usersOnStandby = [[NSMutableArray alloc] init];
        
        if (error) {
            usersOnStandby = nil;
            completionBlock(error, usersOnStandby);
            
        } else {
            for (PFObject *activity in standbyActivities) {
                
                
                PFUser *userOnStandby = activity[@"from"];
                NSLog(@"User Found in Query One: %@", userOnStandby);

                [usersOnStandby addObject:userOnStandby];
                
            }
            
            PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
            [queryForStandbyUsers whereKey:@"activityContent" equalTo:event];
            [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForStandbyUsers includeKey:@"to"];
            [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *accessActivities, NSError *error) {
               
                NSLog(@"SECOND QUERY RESULTS:  %@", accessActivities);
                
                NSMutableArray *usersGrantedAccess = [[NSMutableArray alloc] init];
                
                if (error) {
                    usersOnStandby = nil;
                    completionBlock(error, usersOnStandby);
                } else {
                    
                    for (PFObject *activity2 in accessActivities) {
                        
                        PFUser *userGrantedAcesss = activity2[@"to"];
                        
                        NSLog(@"User Found in Query Two: %@", userGrantedAcesss);
                        
                        [usersGrantedAccess addObject:userGrantedAcesss];
                    }
                    
                    
                    NSMutableArray *finalResults = [[NSMutableArray alloc] init];
                    
                    for (PFUser *requestedAccessUser in usersOnStandby) {
                        
                        BOOL tempFlag = 0;
                        
                        for (PFUser *grantedAccessUser in usersGrantedAccess) {
                            
                            if ([requestedAccessUser.objectId isEqualToString:grantedAccessUser.objectId]) {
                                tempFlag = 1;
                            }
                            
                        }
                        
                        if (tempFlag) {
                            tempFlag = 0;
                        } else {
                            [finalResults addObject:requestedAccessUser];
                        }
                        
                        
                    }
                    
                    
                    NSLog(@"FINAL USERS LIST:  %@", finalResults);
                    

                    completionBlock(error, finalResults);
                    
                }
                
            }];
            
        }
        
    }];
    

}


+ (void) queryRSVPForUsername:(NSString *)username atEvent:(EventObject *)event completion:(void (^)(BOOL, NSString *))completionBlock {
    
    PFRelation *eventAttendersRelation = event.attenders;
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

+ (void) queryApprovalStatusOfUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL, NSString *))completionBlock {
    
    PFQuery *requestedAccessQuery = [PFQuery queryWithClassName:@"Activities"];
    [requestedAccessQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    [requestedAccessQuery whereKey:@"from" equalTo:user];
    [requestedAccessQuery whereKey:@"activityContent" equalTo:event];
    [requestedAccessQuery findObjectsInBackgroundWithBlock:^(NSArray *requestedActivityObjects, NSError *error) {
        
        __block NSString *status = kNOTRSVPedForEvent;

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
                [accessGrantedQuery whereKey:@"activityContent" equalTo:event];
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


+ (void) requestAccessForUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL))completionBlock {
    
    //RSVP User for Event
    PFObject *rsvpActivity = [PFObject objectWithClassName:@"Activities"];
    rsvpActivity[@"from"] = user;
    rsvpActivity[@"to"] = event.parent;
    rsvpActivity[@"type"] = [NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY];
    rsvpActivity[@"activityContent"] = event;
    
    [rsvpActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
        
    }];
    
}




+ (void) rsvpUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL))completionBlock {
    
    PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
    newAttendingActivity[@"to"] = user;
    newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
    newAttendingActivity[@"activityContent"] = event;
    [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
       
    }];
    
}


+ (void) unRSVPUser:(PFUser *)user forEvent:(EventObject *)event completion:(void (^)(BOOL))completionBlock {
    
    PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
    [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [queryForRSVP whereKey:@"to" equalTo:user];
    [queryForRSVP whereKey:@"activityContent" equalTo:event];
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


+ (void) inviteUsers:(NSArray *)users toEvent:(EventObject *)event completion:(void (^)(BOOL))completionBlock {
    
    __block BOOL success = YES;
    
    for (PFUser *user in users) {
        
        //If Private Event - Also Add Invited People to invitedUsers column as a PFRelation - actually maybe not
        
        PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
        
        newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
        newInvitationActivity[@"from"] = [PFUser currentUser];
        newInvitationActivity[@"to"] = user;
        newInvitationActivity[@"activityContent"] = event;
        
        //save the invitation activities
        [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            success = (succeeded) ? YES : NO;
            
            if (error) {
                NSLog(@"Developer Note:  Error saving invitations: %@", error);
            }
        }];
        
        PFRelation *invitedUsersRelation = [event relationForKey:@"invitedUsers"];
        [invitedUsersRelation addObject:user];
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            success = (succeeded) ? YES : NO;

            if (succeeded) {
                //empty
            }
            
        }];
    }
    
    completionBlock(success);
    
}

+ (void) queryForUsersFollowing:(PFUser *)user completion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
    [query whereKey:@"from" equalTo:user];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [query includeKey:@"to"];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
        
        NSMutableArray *finalResults = [[NSMutableArray alloc] init];
        
        if (!error) {
            for (PFObject *object in usersFound) {
                
                PFUser *userFollowing = object[@"to"];
                
                if (![finalResults containsObject:userFollowing]) {
                    [finalResults addObject:userFollowing];
                } else {
                    NSLog(@"Developer Note:  Duplicate attendee found.");
                }
            }
        }

        completionBlock(finalResults);
        
    }];

    
}



@end
