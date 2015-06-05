//
//  ActivityVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "EVNUser.h"

@interface ActivityVC : PFQueryTableViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) int typeOfActivityView;
@property (nonatomic, strong) EVNUser *userForActivities;
@property (nonatomic) BOOL backgroundUpdateOccurred;

- (void) updateRefreshTimestampWithDate:(NSDate *)updatedDate;


@end
