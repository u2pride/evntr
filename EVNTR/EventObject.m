//
//  EventObject.m
//  EVNTR
//
//  Created by Alex Ryan on 4/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventObject.h"
#import "EVNConstants.h"
#import <Parse/PFObject+Subclass.h>

@implementation EventObject

@dynamic dateOfEvent, nameOfLocation, title, descriptionOfEvent, typeOfEvent, invitedUsers, attenders, locationOfEvent, coverPhoto, eventImages, parent;

#pragma mark - Required For Subclassing PFUser

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Events";
}

#pragma mark - Helper Methods

- (NSString *) eventDateShortStyle {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    return [dateFormatter stringFromDate:self.dateOfEvent];
    
}


- (NSString *) eventTimeShortStye {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    return [dateFormatter stringFromDate:self.dateOfEvent];
    
}

- (void) coverImage:(void (^)(UIImage *))completionBlock {
    
    [self.coverPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        
        UIImage *cover = [UIImage imageWithData:imageData];
        
        completionBlock(cover);
        
    }];
    
}

- (NSString *) eventTypeForHomeView {
    
    int eventType = [self.typeOfEvent intValue];
    
    switch (eventType) {
        case PUBLIC_EVENT_TYPE: {
            return @"Pu";
            break;
        }
        case PRIVATE_EVENT_TYPE: {
            return @"Pr";
            break;
        }
        case PUBLIC_APPROVED_EVENT_TYPE: {
            return @"Pa";
            break;
        }
        default:
            return @"Unknown";
            break;
    }
    
}

- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock {
    
    PFRelation *relation = self.attenders;
    PFQuery *query = [relation query];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        completionBlock(number);
        
    }];

}


//Users Can Only Post Photos To An Event Starting An Hour Before the Event.
//Creators of the Event Can Post Photos At All Times
- (BOOL) allowUserToAddPhotosAtThisTime {
    
    if ([self.objectId isEqual:[EVNUser currentUser].objectId]) {
                
        return YES;
        
    } else {
        
        NSDate *currentDate = [NSDate date];
        double numMinutesBefore = 60;
        double numSeconds = numMinutesBefore * 60;
        NSDate *hourBeforeDate = [currentDate dateByAddingTimeInterval:numSeconds];
        
        NSComparisonResult dateCompare = [hourBeforeDate compare:self.dateOfEvent];
        
        
        switch (dateCompare) {
            case NSOrderedSame: {
                
                return YES;
                break;
            }
            case NSOrderedAscending: {
                
                return NO;
                break;
            }
            case NSOrderedDescending: {
                
                return YES;
                break;
            }
            default: {
                
                return NO;
                break;
            }
        }
        
    }
    
}


- (void) queryForStandbyUsersWithIncludeKey:(NSString *)key completion:(void (^)(NSError *, NSArray *))completionBlock {
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:self];
    [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    [queryForStandbyUsers includeKey:@"from"];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *standbyActivities, NSError *error) {
        
        __block NSMutableArray *usersOnStandby = [[NSMutableArray alloc] init];
        
        if (error) {
            usersOnStandby = nil;
            completionBlock(error, usersOnStandby);
            
        } else {
            for (PFObject *activity in standbyActivities) {
                
                EVNUser *userOnStandby = activity[@"from"];
                
                if (userOnStandby) {
                    [usersOnStandby addObject:userOnStandby];
                }
                
            }
            
            PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
            [queryForStandbyUsers whereKey:@"activityContent" equalTo:self];
            [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForStandbyUsers includeKey:@"to"];
            [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *accessActivities, NSError *error) {
                
                NSMutableArray *usersGrantedAccess = [[NSMutableArray alloc] init];
                
                if (error) {
                    usersOnStandby = nil;
                    completionBlock(error, usersOnStandby);
                } else {
                    
                    for (PFObject *activity2 in accessActivities) {
                        
                        EVNUser *userGrantedAcesss = activity2[@"to"];
                        
                        [usersGrantedAccess addObject:userGrantedAcesss];
                    }
                    
                    
                    NSMutableArray *finalResults = [[NSMutableArray alloc] init];
                    
                    for (EVNUser *requestedAccessUser in usersOnStandby) {
                        
                        BOOL tempFlag = 0;
                        
                        for (EVNUser *grantedAccessUser in usersGrantedAccess) {
                            
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
                    
                    completionBlock(error, finalResults);
                    
                }
                
            }];
            
        }
        
    }];
    
}


- (void) queryRSVPForUserId:(NSString *)userObjectId completion:(void (^)(BOOL, NSString *))completionBlock {
    
    PFRelation *eventAttendersRelation = self.attenders;
    PFQuery *attendingQuery = [eventAttendersRelation query];
    [attendingQuery whereKey:@"objectId" equalTo:userObjectId];
    [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object && !error) {
            completionBlock(YES, kAttendingEvent);
        } else {
            completionBlock(NO, kNotAttendingEvent);
        }
        
    }];
    
}


//TODO: check to make sure completion block stops execution of method
- (void) queryApprovalStatusOfUser:(EVNUser *)user completion:(void (^)(BOOL, NSString *))completionBlock {
    
    //NSArray *activityTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY], [NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY], nil];
    
    // 3 - {from} requested that {to} give access to {activityContent}
    // 5 - {from} let {to} in to {activityContent}
    
    PFQuery *requestActivity = [PFQuery queryWithClassName:@"Activities"];
    [requestActivity whereKey:@"activityContent" equalTo:self];
    [requestActivity whereKey:@"from" equalTo:user];
    [requestActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    
    PFQuery *grantedActivty = [PFQuery queryWithClassName:@"Activities"];
    [grantedActivty whereKey:@"activityContent" equalTo:self];
    [grantedActivty whereKey:@"to" equalTo:user];
    [grantedActivty whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
    
    PFQuery *statusQuery = [PFQuery orQueryWithSubqueries:@[requestActivity, grantedActivty]];
    
    [statusQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
        if (error) {
            completionBlock(NO, @"Error");
        } else {
            
            NSString *status = kNOTRSVPedForEvent;
            BOOL isAttending = NO;
            
            for (PFObject *activity in objects) {
                
                int activityType = (int) [[activity objectForKey:@"type"] integerValue];
                
                if (activityType == ACCESS_GRANTED_ACTIVITY) {
                    NSLog(@"Granted Access - Now Return Before Next Checkpoint");
                    status = kGrantedAccessToEvent;
                    isAttending = YES;
                    break;
                }
                
                if (activityType == REQUEST_ACCESS_ACTIVITY) {
                    NSLog(@"On Standby for Event");
                    status = kRSVPedForEvent;
                }
                
            }
            
            completionBlock(isAttending, status);
            
        }
    
    }];
    
}


- (void) requestAccessForUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    //Request Access for User to Event
    PFObject *requestAccessActivity = [PFObject objectWithClassName:@"Activities"];
    requestAccessActivity[@"from"] = user;
    requestAccessActivity[@"to"] = self.parent;
    requestAccessActivity[@"type"] = [NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY];
    requestAccessActivity[@"activityContent"] = self;
    
    [requestAccessActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
        
    }];
    
}



- (void) rsvpUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
    newAttendingActivity[@"to"] = user;
    newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
    newAttendingActivity[@"activityContent"] = self;
    [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        completionBlock(succeeded);
        
    }];
    
}


- (void) unRSVPUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
    [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [queryForRSVP whereKey:@"to" equalTo:user];
    [queryForRSVP whereKey:@"activityContent" equalTo:self];
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

//TODO: Is this how I want to go about inviting users for the backend design?
- (void) inviteUsers:(NSArray *)users completion:(void (^)(BOOL))completionBlock {
    
    __block BOOL success = YES;
    
    for (EVNUser *user in users) {
        
        //If the user is invited to a public approved event, they are automatically granted access. This will be changed.
        if (self.typeOfEvent.intValue == PUBLIC_APPROVED_EVENT_TYPE) {
            PFObject *newActivity = [PFObject objectWithClassName:@"Activities"];
            newActivity[@"from"] = [EVNUser currentUser];
            newActivity[@"to"] = user;
            newActivity[@"type"] = [NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY];
            newActivity[@"activityContent"] = self;
            [newActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    PFRelation *attendingRelation = [self relationForKey:@"attenders"];
                    [attendingRelation addObject:user];
                    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        
                    }];
                }
                
            }];
            
        }
        
        
        //If Private Event - Also Add Invited People to invitedUsers column as a PFRelation - actually maybe not
        
        PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
        
        newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
        newInvitationActivity[@"from"] = [EVNUser currentUser];
        newInvitationActivity[@"to"] = user;
        newInvitationActivity[@"activityContent"] = self;
        
        //save the invitation activities
        [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            success = (succeeded) ? YES : NO;
            
            if (error) {
                NSLog(@"Developer Note:  Error saving invitations: %@", error);
            }
        }];
        
        PFRelation *invitedUsersRelation = [self relationForKey:@"invitedUsers"];
        [invitedUsersRelation addObject:user];
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            success = (succeeded) ? YES : NO;
            
            if (succeeded) {
                //empty
            }
            
        }];
    }
    
    //TODO - this is not right... success variable gets re-written after each save - this will only reflect the last save result
    completionBlock(success);
    
}

- (void) queryForImagesWithCompletion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *imagesQuery = [PFQuery queryWithClassName:@"Pictures"];
    [imagesQuery includeKey:@"takenBy"]; /* Include the EVNUser who took the photo */
    [imagesQuery whereKey:@"eventParent" equalTo:self];
    [imagesQuery orderByDescending:@"createdAt"];
    
    [imagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        completionBlock(objects);
        
    }];
    
}


- (void) estimateNumberOfPhotosWithCompletion:(void (^)(int))completionBlock {
    
    PFQuery *imagesQuery = [PFQuery queryWithClassName:@"Pictures"];
    [imagesQuery includeKey:@"takenBy"]; /* Include the EVNUser who took the photo */
    [imagesQuery whereKey:@"eventParent" equalTo:self];
    [imagesQuery orderByAscending:@"createdAt"];
    
    [imagesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        completionBlock(number);
        
    }];
    
}


- (void) queryForCommentsWithCompletion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentsQuery whereKey:@"commentEvent" equalTo:self];
    [commentsQuery includeKey:@"commentParent"];
    [commentsQuery orderByDescending:@"updatedAt"];
    [commentsQuery setLimit:50];
    
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        completionBlock(objects);
        
    }];
    
}



@end
