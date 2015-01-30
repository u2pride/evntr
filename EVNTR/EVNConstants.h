//
//  EVNConstants.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kAppName;


#pragma mark - Events

#define ALL_PUBLIC_EVENTS 1
#define CURRENT_USER_EVENTS 2
#define OTHER_USER_EVENTS 3

#pragma mark - People

#define VIEW_ALL_PEOPLE 1
#define VIEW_FOLLOWERS 2
#define VIEW_FOLLOWING 3

#pragma mark - Profiles

#define CURRENT_USER_PROFILE 1
#define OTHER_USER_PROFILE 2
#define SPONSORED_PROFILE 3

#pragma mark - Activity Types

#define FOLLOW_ACTIVITY 1
#define UNFOLLOW_ACTIVITY
#define INVITE_ACTIVITY
#define REQUEST_ACCESS_ACTIVITY 2
#define ATTENDING_ACTIVITY 3


// Time Type From To Content
// Alex followed Ben - 8 m ago
// Alex is attending Concert on Jan 30th
// Bobby invited Alex to Dinner on Feb 4th
// Alex approved {you} to Attend the Event on Dec 4th
//
//

