//
//  EVNFriendsEventsVC.h
//  EVNTR
//
//  Created by Alex Ryan on 7/21/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@protocol EVNFriendsTabProtocol;

@interface EVNFriendsEventsVC : PFQueryTableViewController <EventDetailProtocol, PeopleVCDelegate>

@property (nonatomic, weak) id <EVNFriendsTabProtocol> delegate;

@end

@protocol EVNFriendsTabProtocol <NSObject>

- (float) currentRadiusFilter;
- (void) presentFilterView;

@end
