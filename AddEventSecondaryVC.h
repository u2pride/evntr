//
//  AddEventSecondaryVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EVNConstants.h"


@interface AddEventSecondaryVC : UIViewController

@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, assign) int eventType;
@property (nonatomic, strong) PFFile *eventCoverImage;

@end
