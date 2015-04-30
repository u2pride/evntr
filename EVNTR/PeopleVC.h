//
//  PeopleVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "EventObject.h"
#import "EVNUser.h"

@protocol PeopleVCDelegate;
@class EventAddVC;

@interface PeopleVC : UICollectionViewController

@property (nonatomic, weak) id<PeopleVCDelegate> delegate;
@property (nonatomic, assign) int typeOfUsers;
@property (nonatomic, strong) EVNUser *userProfile;
@property (nonatomic, strong) EventObject *eventToViewAttenders;

//Property for Invitation PeopleVC
@property (nonatomic, strong) PFRelation *usersAlreadyInvited;

@end


@protocol PeopleVCDelegate <NSObject>

//Invite Activites Only Created for New Invites - No Activity for Un-Invite
//Old Invite Activity Stays in Table TODO: Delete Old Activity on Un-Invite
- (void)finishedSelectingInvitations:(NSArray *)selectedPeople;

@end



