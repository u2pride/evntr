//
//  UIButtonPFExtended.h
//  EVNTR
//
//  Created by Alex Ryan on 2/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EVNButton.h"
#import "EVNUser.h"
#import "EventObject.h"

@interface EVNButtonExtended : EVNButton

@property (nonatomic, strong) NSString *fbIdToFollow;

@property (nonatomic, strong) EventObject *eventToView;
@property (nonatomic, strong) EVNUser *personToFollow;

@property (nonatomic, strong) EVNUser *personToGrantAccess;
@property (nonatomic, strong) EventObject *eventToGrantAccess;

@end
