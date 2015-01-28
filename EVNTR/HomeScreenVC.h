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

@interface HomeScreenVC : PFQueryTableViewController

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;

// 1 - for public  2 - for current user 3 - for different username
@property (nonatomic, assign) int typeOfEventTableView;
@property (nonatomic, strong) PFUser *userForEventsQuery;

@end