//
//  EVNButton.h
//  EVNTR
//
//  Created by Alex Ryan on 3/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVNButton : UIControl

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, strong) UIFont *font;

@property (nonatomic) BOOL isRounded;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isStateless;

- (void) startedTask;
- (void) endedTask;

@end
