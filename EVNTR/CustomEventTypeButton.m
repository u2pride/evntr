//
//  CustomEventTypeButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CustomEventTypeButton.h"
#import "UIColor+EVNColors.h"

@implementation CustomEventTypeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected {
    
    if (selected) {
        self.titleLabel.textColor = [UIColor orangeThemeColor];
    } else {
        self.titleLabel.textColor = [UIColor darkTextColor];
    }
    
}

@end
