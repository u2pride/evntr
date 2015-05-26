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


@interface HomeScreenVC : PFQueryTableViewController <UIScrollViewDelegate, EVNFilterProtocol, EventDetailProtocol, PeopleVCDelegate>

@property (nonatomic, assign) int typeOfEventTableView;
@property (nonatomic, strong) EVNUser *userForEventsQuery;

- (void) inviteUsersToEvent:(EventObject *)event;

@end