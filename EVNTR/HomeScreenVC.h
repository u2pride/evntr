//
//  HomeScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "FilterEventsVC.h"
#import "EventDetailVC.h"

@interface HomeScreenVC : PFQueryTableViewController <UIScrollViewDelegate, EVNFilterProtocol, EventDetailProtocol>

//Customize an Event Table - All Events, Curent User Events, Other User Events (specified in userForEventsQuery)
@property (nonatomic, assign) int typeOfEventTableView;
@property (nonatomic, strong) PFUser *userForEventsQuery;

@end