//
//  EVNConstants.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"

#pragma mark - General Use

NSString *const kAppName = @"EVNTR";
NSString *const kLocationCurrent = @"CURRENT_LOCATION";
NSString *const kFirstLoginNewBuild = @"FIRST_LOGIN_NEW_BUILD";


#pragma mark - Notification

NSString *const kUserCreatedNewEvent = @"EventCreated";
NSString *const kNewFollow = @"UserFollowedNewProfile";
NSString *const kNewUnfollow = @"UserUnfollowedProfile";


#pragma mark - String Constants for Event Detail View

NSString *const kAttendingEvent = @"Attending";
NSString *const kNotAttendingEvent = @"Join";
NSString *const kRSVPedForEvent = @"Interested";
NSString *const kNOTRSVPedForEvent = @"Show Interest";
NSString *const kInviteUsers = @"Invite Users";

NSString *const kGrantAccess = @"Let In";
NSString *const kRevokeAccess = @"Revoke";
NSString *const kFollowingString = @"Following";
NSString *const kFollowString = @"Follow";


#pragma mark - Notification String Constants

NSString *const kNumberOfNotifications = @"NUM_NOTIFICATIONS";
NSString *const kLastBackgroundFetchTimeStamp = @"LAST_FETCH_TIME";

NSString *const kPrimaryUpdateTimestamp = @"PRIMARY_NOTIFICATIONS_UPDATE_TIMESTAMP";
NSString *const kSecondaryUpdateTimestamp = @"SECONDARY_NOTIFICATIONS_UPDATE_TIMESTAMP";


#pragma mark - User Management

NSString *const kIsGuest = @"isGuestKey";


#pragma mark - Custom Font

NSString *const kFontName = @"Lato-Regular";
NSString *const kFontColor = @"whiteColor";


NSString *const EVNFontBold = @"Lato-Bold";
NSString *const EVNFontRegular = @"Lato-Regular";
NSString *const EVNFontLight = @"Lato-Light";
NSString *const EVNFontThin = @"Lato-Thin";


#pragma mark - Keys for Accessing Objects from Dictionaries

NSString *const kFollowedUserObjectId = @"UserFollowedObjectId";
NSString *const kUnfollowedUserObjectId = @"UserUnfollowedObjectId";


