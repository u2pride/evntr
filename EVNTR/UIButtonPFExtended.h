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

@interface UIButtonPFExtended : EVNButton

@property (nonatomic, strong) PFObject *eventToView;
@property (nonatomic, strong) PFUser *personToFollow;

@property (nonatomic, strong) PFUser *personToGrantAccess;
@property (nonatomic, strong) PFObject *eventToGrantAccess;

@end
