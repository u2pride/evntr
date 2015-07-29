//
//  EventObject.m
//  EVNTR
//
//  Created by Alex Ryan on 4/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EventObject.h"
#import "EVNConstants.h"
#import <Parse/PFObject+Subclass.h>

@implementation EventObject

@dynamic dateOfEvent, nameOfLocation, title, descriptionOfEvent, typeOfEvent, locationOfEvent, coverPhoto, parent, numAttenders, numComments, numPictures;

#pragma mark - Required For Subclassing PFUser

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Events";
}

#pragma mark - Helper Methods

- (NSString *) eventDateShortStyleAndVisible:(BOOL)visible {
    
    //if ([self.typeOfEvent intValue] == PUBLIC_APPROVED_EVENT_TYPE && !visible) {
        
        //return @"Unknown";
        
    //} else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        [dateFormatter setDoesRelativeDateFormatting:YES];
        
        return [dateFormatter stringFromDate:self.dateOfEvent];
    //}
}


- (NSString *) eventTimeShortStyeAndVisible:(BOOL)visible {
    
    //if ([self.typeOfEvent intValue] == PUBLIC_APPROVED_EVENT_TYPE && !visible) {
        
        //return @"Unknown";
        
    //} else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        
        return [dateFormatter stringFromDate:self.dateOfEvent];
    //}
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


- (void) queryForAttendersWithCompletion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *queryForAttenders = [PFQuery queryWithClassName:@"Activities"];
    [queryForAttenders whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [queryForAttenders whereKey:@"activityContent" equalTo:self];
    [queryForAttenders includeKey:@"userTo"];
    [queryForAttenders findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (error) {
            
            completionBlock(0);
        
        } else {
            
            NSMutableArray *eventAttenders = [[NSMutableArray alloc] init];
            [eventAttenders removeAllObjects];
            
            for (PFObject *attendingActivity in objects) {
                [eventAttenders addObject:attendingActivity[@"userTo"]];
            }
            
            completionBlock(eventAttenders);
        }
        
    }];
    
}


- (void) queryForStandbyUsersWithIncludeKey:(NSString *)key completion:(void (^)(NSError *, NSArray *))completionBlock {
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:self];
    [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    [queryForStandbyUsers includeKey:@"userFrom"];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *standbyActivities, NSError *error) {
        
        __block NSMutableArray *usersOnStandby = [[NSMutableArray alloc] init];
        
        if (error) {
            usersOnStandby = nil;
            completionBlock(error, usersOnStandby);
            
        } else {
            for (PFObject *activity in standbyActivities) {
                
                EVNUser *userOnStandby = activity[@"userFrom"];
                
                if (userOnStandby) {
                    [usersOnStandby addObject:userOnStandby];
                }
                
            }
            
            PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
            [queryForStandbyUsers whereKey:@"activityContent" equalTo:self];
            [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
            [queryForStandbyUsers includeKey:@"userTo"];
            [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *accessActivities, NSError *error) {
                
                NSMutableArray *usersGrantedAccess = [[NSMutableArray alloc] init];
                
                if (error) {
                    usersOnStandby = nil;
                    completionBlock(error, usersOnStandby);
                } else {
                    
                    for (PFObject *activity2 in accessActivities) {
                        
                        EVNUser *userGrantedAcesss = activity2[@"userTo"];
                        
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


- (void) queryRSVPForUser:(EVNUser *)userObject completion:(void (^)(BOOL, NSString *, BOOL))completionBlock {
    
    PFQuery *eventAttendersQuery = [PFQuery queryWithClassName:@"Activities"];
    [eventAttendersQuery whereKey:@"userTo" equalTo:userObject];
    [eventAttendersQuery whereKey:@"activityContent" equalTo:self];
    [eventAttendersQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [eventAttendersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            completionBlock(NO, kNotAttendingEvent, YES);
            
        } else {
            
            if ([objects count] > 0) {
                completionBlock(YES, kAttendingEvent, NO);
            } else {
                completionBlock(NO, kNotAttendingEvent, NO);
            }
        }
        
        
    }];
    
}


- (void) queryApprovalStatusOfUser:(EVNUser *)user completion:(void (^)(BOOL, NSString *, BOOL))completionBlock {
    
    //activityTypes = [NSArray arrayWithObjects:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY], [NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY], nil];
    
    // 3 - {from} requested that {to} give access to {activityContent}
    // 5 - {from} let {to} in to {activityContent}
    
    PFQuery *requestActivity = [PFQuery queryWithClassName:@"Activities"];
    [requestActivity whereKey:@"activityContent" equalTo:self];
    [requestActivity whereKey:@"userFrom" equalTo:user];
    [requestActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    
    PFQuery *grantedActivty = [PFQuery queryWithClassName:@"Activities"];
    [grantedActivty whereKey:@"activityContent" equalTo:self];
    [grantedActivty whereKey:@"userTo" equalTo:user];
    [grantedActivty whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
    
    // 2 - {from} invited {to} to {activityContent}
    // 4 - {to} is attending {activityContent}
    
    PFQuery *invitedQuery = [PFQuery queryWithClassName:@"Activities"];
    [invitedQuery whereKey:@"activityContent" equalTo:self];
    [invitedQuery whereKey:@"userTo" equalTo:user];
    [invitedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
    
    PFQuery *attendingQuery = [PFQuery queryWithClassName:@"Activities"];
    [attendingQuery whereKey:@"activityContent" equalTo:self];
    [attendingQuery whereKey:@"userTo" equalTo:user];
    [attendingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    
    
    PFQuery *statusQuery = [PFQuery orQueryWithSubqueries:@[requestActivity, grantedActivty, invitedQuery, attendingQuery]];
    
    [statusQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
        if (error) {
            
            completionBlock(NO, @"", YES);
            
        } else {
            
            NSString *status = kNOTRSVPedForEvent;
            
            BOOL isInvited = NO;
            BOOL isGrantedAccess = NO;
            BOOL isAttending = NO;
            BOOL isRequestedAccess = NO;
            
            for (PFObject *activity in objects) {
                
                int activityType = (int) [[activity objectForKey:@"type"] integerValue];
                
                if (activityType == INVITE_ACTIVITY) {
                    isInvited = YES;
                } else if (activityType == ATTENDING_ACTIVITY) {
                    isAttending = YES;
                } else if (activityType == ACCESS_GRANTED_ACTIVITY) {
                    isGrantedAccess = YES;
                } else if (activityType == REQUEST_ACCESS_ACTIVITY) {
                    isRequestedAccess = YES;
                }
                
                
            }
            
        
            if (isInvited || isGrantedAccess) {
                
                if (isAttending) {
                    status = kAttendingEvent;
                } else {
                    status = kNotAttendingEvent;
                }
                
            } else {
                
                isAttending = NO;
                
                if (isRequestedAccess) {
                    status = kRSVPedForEvent;
                } else {
                    status = kNOTRSVPedForEvent;
                }
                
            }
            
            
            completionBlock(isAttending, status, NO);
        }
    }];
}


- (void) requestAccessForUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    PFObject *requestAccessActivity = [PFObject objectWithClassName:@"Activities"];
    requestAccessActivity[@"userFrom"] = user;
    requestAccessActivity[@"userTo"] = self.parent;
    requestAccessActivity[@"type"] = [NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY];
    requestAccessActivity[@"activityContent"] = self;
    
    [requestAccessActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!succeeded) {
            [PFAnalytics trackEventInBackground:@"RequestAccessIssue" block:nil];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance logEvent:@"RequestAccessIssue"];
        }
        
        completionBlock(succeeded);
        
    }];
    
}



- (void) rsvpUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
    newAttendingActivity[@"userTo"] = user;
    newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
    newAttendingActivity[@"activityContent"] = self;
    [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!succeeded) {
            [PFAnalytics trackEventInBackground:@"RSVPUserIssue" block:nil];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance logEvent:@"RSVPUserIssue"];
        }
        
        completionBlock(succeeded);
        
    }];
    
}


- (void) unRSVPUser:(EVNUser *)user completion:(void (^)(BOOL))completionBlock {
    
    PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
    [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
    [queryForRSVP whereKey:@"userTo" equalTo:user];
    [queryForRSVP whereKey:@"activityContent" equalTo:self];
    [queryForRSVP findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            completionBlock(NO);
        
        } else {
            
            PFObject *previousActivity = [objects firstObject];
            [previousActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                completionBlock(succeeded);
                
            }];
        }
        

        
    }];
}

- (void) inviteUsers:(NSArray *)users completion:(void (^)(BOOL))completionBlock {
    
    __block int totalSavesRequired = (int)[users count];
    __block int savesCompleted = 0;
    
    for (EVNUser *user in users) {
    
        PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
        
        newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
        newInvitationActivity[@"userFrom"] = [EVNUser currentUser];
        newInvitationActivity[@"userTo"] = user;
        newInvitationActivity[@"activityContent"] = self;
        
        [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                savesCompleted++;
            } else {
                [PFAnalytics trackEventInBackground:@"InviteUsersIssue" block:nil];
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.amplitudeInstance logEvent:@"InviteUsersIssue"];
                completionBlock(NO);
            }
            
            if (totalSavesRequired == savesCompleted) {
                completionBlock(YES);
            }
            
        }];
        
    }
    
}

- (void) queryForImagesWithCompletion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *imagesQuery = [PFQuery queryWithClassName:@"Pictures"];
    [imagesQuery includeKey:@"takenBy"]; /* Include the EVNUser who took the photo */
    [imagesQuery whereKey:@"eventParent" equalTo:self];
    [imagesQuery orderByDescending:@"createdAt"];
    
    [imagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            completionBlock(0);
        } else {
            completionBlock(objects);
        }
        
    }];
    
}


- (void) queryForCommentsWithCompletion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentsQuery whereKey:@"commentEvent" equalTo:self];
    [commentsQuery includeKey:@"commentParent"];
    [commentsQuery orderByDescending:@"updatedAt"];
    [commentsQuery setLimit:50];
    
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            completionBlock(nil);
        } else {
            completionBlock(objects);
        }
        
    }];
    
}


- (void) flagEventFromVC:(UIViewController *)currentVC {
    
    UIAlertController *flagSelection = [UIAlertController alertControllerWithTitle:@"Flag Content" message:@"Please select why you are flagging this content.  What content is inappropriate?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *eventName = [UIAlertAction actionWithTitle:@"Event Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self createFlaggingAlertViewWithType:@"EventName" andMessage:@"Please add a description to explain why the event name is inappropriate." onVC:currentVC];
        
    }];
    
    UIAlertAction *eventDescription = [UIAlertAction actionWithTitle:@"Event Description" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self createFlaggingAlertViewWithType:@"EventDescription" andMessage:@"Please add a description to explain why the event description is inappropriate." onVC:currentVC];
        
    }];
    
    UIAlertAction *eventContent = [UIAlertAction actionWithTitle:@"Event Content" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self createFlaggingAlertViewWithType:@"EventContent" andMessage:@"Please identify which event comment or picture is innapropriate." onVC:currentVC];
        
    }];
    
    UIAlertAction *otherContent = [UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self createFlaggingAlertViewWithType:@"Other" andMessage:@"Please describe the content you are reporting and why it is inappropriate." onVC:currentVC];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        
    }];
    
    
    [flagSelection addAction:eventName];
    [flagSelection addAction:eventDescription];
    [flagSelection addAction:eventContent];
    [flagSelection addAction:otherContent];
    [flagSelection addAction:cancelAction];
    
    [currentVC presentViewController:flagSelection animated:YES completion:nil];
    
}


- (void) createFlaggingAlertViewWithType:(NSString *)type andMessage:(NSString *)message onVC:(UIViewController *)vc {
    
    __block UITextField *descriptionText;
    
    UIAlertController *submitReport = [UIAlertController alertControllerWithTitle:@"Report Content" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [submitReport addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        descriptionText = textField;
        
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        PFObject *reportObject = [PFObject objectWithClassName:@"Reports"];
        [reportObject setObject:[EVNUser currentUser] forKey:@"userFrom"];
        [reportObject setObject:self forKey:@"flaggedEvent"];
        [reportObject setObject:descriptionText.text forKey:@"flagDescription"];
        [reportObject setObject:type forKey:@"flagType"];
        
        [reportObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                UIAlertController *submitVerification = [UIAlertController alertControllerWithTitle:@"Submitted" message:@"Thanks for submitting a report.  We'll review this content within 24 hours and remove if it violates our policy." preferredStyle:UIAlertControllerStyleAlert];
                
                [vc presentViewController:submitVerification animated:YES completion:^{
                    
                    double delayInSeconds = 2;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [vc dismissViewControllerAnimated:YES completion:nil];
                        
                    });
                    
                }];
                
            } else {
                
                UIAlertController *submitVerification = [UIAlertController alertControllerWithTitle:@"Failed" message:@"Please try to submit again." preferredStyle:UIAlertControllerStyleAlert];
                
                [vc presentViewController:submitVerification animated:YES completion:^{
                    
                    double delayInSeconds = 2;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        [vc dismissViewControllerAnimated:YES completion:nil];
                        
                    });
                    
                }];
                
            }
            
        }];
        
    }];
    
    UIAlertAction *cancelReport = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
    }];
    
    [submitReport addAction:submit];
    [submitReport addAction:cancelReport];
    
    [vc presentViewController:submitReport animated:YES completion:nil];
    
}


@end
