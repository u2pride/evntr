//
//  EVNInviteContainerHeaderView.h
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVNInviteContainerHeaderView : UIView

@property (nonatomic, strong) UIImageView *facebookButton;
@property (nonatomic, strong) UIImageView *contactsButton;

@property (nonatomic, strong) CAShapeLayer *lineUnderFacebook;
@property (nonatomic, strong) CAShapeLayer *lineUnderContacts;


- (void) lineUnderIndex:(int)index;

@end
