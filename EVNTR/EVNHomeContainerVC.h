//
//  EVNHomeContainerVC.h
//  EVNTR
//
//  Created by Alex Ryan on 7/21/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterEventsVC.h"
#import "HomeScreenVC.h"
#import "EVNFriendsEventsVC.h"

@interface EVNHomeContainerVC : UIViewController <EVNFilterProtocol, HomeScreenProtocol, EVNFriendsTabProtocol>

@property (nonatomic, strong) HomeScreenVC *allEventsViewController;
@property (nonatomic, strong) UIViewController *friendsViewController;


- (void) swapVCToIndex:(int)index;


@end