//
//  EVNInviteContainerVC.h
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVNConnectFBFriendsVC.h"
#import "EVNInviteContactsVC.h"
#import "EVNNoResultsView.h"

@protocol EVNInviteProtocol;

@interface EVNInviteContainerVC : UIViewController <EVNContactInviteProtocol>

@property (nonatomic, strong) UIViewController *viewControllerOne;
@property (nonatomic, strong) EVNInviteContactsVC *viewControllerTwo;

@property (nonatomic, strong) id <EVNInviteProtocol> delegate;

@end

@protocol EVNInviteProtocol <NSObject>

- (EVNNoResultsView *) contactsInviteMessageWithSelector:(SEL) selector andSender:(id)sender;

@end
