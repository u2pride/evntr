//
//  EVNConstants.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kAppName;


#pragma mark - Events Pull and Details

#define ALL_PUBLIC_EVENTS 1
#define CURRENT_USER_EVENTS 2
#define OTHER_USER_EVENTS 3
extern NSString *const kAttendingEvent;
extern NSString *const kNotAttendingEvent;

#pragma mark - People

#define VIEW_ALL_PEOPLE 1
#define VIEW_FOLLOWERS 2
#define VIEW_FOLLOWING 3
#define VIEW_FOLLOWING_TO_INVITE 4
#define VIEW_EVENT_ATTENDERS 5

#pragma mark - Profiles

#define CURRENT_USER_PROFILE 1
#define OTHER_USER_PROFILE 2
#define SPONSORED_PROFILE 3

#pragma mark - Activity Types

#define FOLLOW_ACTIVITY 1
#define INVITE_ACTIVITY 2
#define REQUEST_ACCESS_ACTIVITY 3
#define ATTENDING_ACTIVITY 4

// 1 - {from} followed {to}
// 2 - {from} invited {to} to {activityContent}
// 3 -
// 4 - {to} is attending {activityContent}
// Notifications Query - for all Activities in which {to} matches [PFUser CurrentUser]

#pragma mark - Event Types

#define PUBLIC_EVENT_TYPE 1
#define PRIVATE_EVENT_TYPE 2

#pragma mark - Notifications
extern NSString *const kNumberOfNotifications;
extern NSString *const kLastBackgroundFetchTimeStamp;


#pragma mark - Default Button Attributes
#define BUTTON_BORDER_WIDTH 1.5f
#define BUTTON_CORNER_RADIUS 8

#pragma mark - Notification Names
extern NSString *const kNotificationNewFollow;
extern NSString *const kNotificationRemovedFollow;
extern NSString *const kFollowActivity;
extern NSString *const kEventCreated;


#pragma mark - User Management 
extern NSString *const kIsGuest;

// Time Type From To Content
// Alex followed Ben - 8 m ago
// Alex is attending Concert on Jan 30th
// Bobby invited Alex to Dinner on Feb 4th
// Alex approved {you} to Attend the Event on Dec 4th
//
//

