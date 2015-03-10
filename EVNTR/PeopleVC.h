//
//  PeopleVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@protocol PeopleVCDelegate;
@class EventAddVC;

@interface PeopleVC : UICollectionViewController

@property (nonatomic, weak) id<PeopleVCDelegate> delegate;
@property (nonatomic, assign) int typeOfUsers;
@property (nonatomic, strong) PFUser *profileUsername;
@property (nonatomic, strong) PFObject *eventToViewAttenders;

@end


@protocol PeopleVCDelegate <NSObject>

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople;

@end



