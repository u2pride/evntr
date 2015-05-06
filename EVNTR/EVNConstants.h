//
//  EVNConstants.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import <Foundation/Foundation.h>

#pragma mark - General Use
extern NSString *const kFirstLoginNewBuild;
extern NSString *const kAppName;
extern NSString *const kLocationCurrent;


#pragma mark - View Controllers on Tab 
#define TAB_HOME 0
#define TAB_CREATE 1
#define TAB_ACTIVITY 2
#define TAB_PROFILE 3

#pragma mark - Notification Names
extern NSString *const kNotificationNewFollow;
extern NSString *const kNotificationRemovedFollow;
extern NSString *const kFollowActivity;
extern NSString *const kEventCreated;


#pragma mark - User Management
extern NSString *const kIsGuest;

#pragma mark - Default Button Attributes
#define BUTTON_BORDER_WIDTH 1.5f
#define BUTTON_CORNER_RADIUS 8




#pragma mark - Type of Event TableView

#define ALL_PUBLIC_EVENTS 1
#define CURRENT_USER_EVENTS 2
#define OTHER_USER_EVENTS 3
extern NSString *const kAttendingEvent;
extern NSString *const kNotAttendingEvent;
extern NSString *const kRSVPedForEvent;
extern NSString *const kNOTRSVPedForEvent;
extern NSString *const kGrantedAccessToEvent;
extern NSString *const kInviteUsers;
#define SEARCH_RADIUS_DEFAULT 10


#pragma mark - Type of Activites TableView

#define ACTIVITIES_ALL 1
#define ACTIVITIES_INVITES 2
//TODO:  requests
#define ACTIVITIES_REQUESTS_TO_ME 3
#define ACTIVITIES_ATTENDED 4
#define ACTIVITIES_MY_REQUESTS_STATUS 5

extern NSString *const kGrantAccess;
extern NSString *const kRevokeAccess;




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
#define ACCESS_GRANTED_ACTIVITY 5

//Requests to My Events - {from}
//My Requests to Events -

// 1 - {from} followed {to}
// 2 - {from} invited {to} to {activityContent}
// 3 - {from} requested that {to} give access to {activityContent}
// 4 - {to} is attending {activityContent}
// 5 - {from} let {to} in to {activityContent}

// 3 - {from} has been asked by {to} for access to {activityContent} - SWITCHED TO THIS BUT THEN SWITCHED BACK TO ORIGINAL
// {to} requested access from {from} to {activityContent} - Never Implemented

// Notifications Query - for all Activities in which {to} matches [EVNUser CurrentUser]


#pragma mark - Event Types

#define PUBLIC_EVENT_TYPE 1
#define PRIVATE_EVENT_TYPE 2
#define PUBLIC_APPROVED_EVENT_TYPE 3

#pragma mark - Notifications
extern NSString *const kNumberOfNotifications;
extern NSString *const kLastBackgroundFetchTimeStamp;




#pragma mark - NavBar Appearance
#define kFontSize 18

#pragma mark - Max Lengths
#define MIN_USERNAME_LENGTH 2
#define MAX_USERNAME_LENGTH 20
#define MIN_REALNAME_LENGTH 0
#define MAX_REALNAME_LENGTH 20
#define MAX_BIO_LENGTH 120
#define MIN_PASSWORD_LENGTH 2



#pragma mark - Custom Font
extern NSString *const EVNFontBold;
extern NSString *const EVNFontRegular;
extern NSString *const EVNFontLight;
extern NSString *const EVNFontThin;




// Time Type From To Content
// Alex followed Ben - 8 m ago
// Alex is attending Concert on Jan 30th
// Bobby invited Alex to Dinner on Feb 4th
// Alex approved {you} to Attend the Event on Dec 4th
//
//








