//
//  EVNLocationButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNLocationButton.h"
#import "UIColor+EVNColors.h"

@implementation EVNLocationButton


- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
 
    if (highlighted) {
        NSLog(@"HI");
        self.backgroundColor = [UIColor orangeThemeColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor orangeThemeColor];
    }
 
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
