//
//  EVNInviteContactsVC.h
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVNNoResultsView.h"

@import MessageUI;

@protocol EVNContactInviteProtocol;

@interface EVNInviteContactsVC : UIViewController <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) id <EVNContactInviteProtocol> delegate;

@end

@protocol EVNContactInviteProtocol <NSObject>

- (EVNNoResultsView *) messageViewWithSelector:(SEL) selector andSender:(id)sender;

@end
