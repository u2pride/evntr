//
//  HomeScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import "EventDetailVC.h"
#import "FilterEventsVC.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@protocol HomeScreenProtocol;

@interface HomeScreenVC : PFQueryTableViewController <UIScrollViewDelegate, EventDetailProtocol, PeopleVCDelegate>

@property (nonatomic, assign) int typeOfEventTableView;
@property (nonatomic, strong) EVNUser *userForEventsQuery;
@property (nonatomic, weak) id <HomeScreenProtocol> delegate;

- (void) inviteUsersToEvent:(EventObject *)event;

@end


@protocol HomeScreenProtocol <NSObject>

- (float) currentRadiusFilter;
- (void) presentFilterView;

@end