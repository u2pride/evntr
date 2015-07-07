//
//  EVNGradientView.m
//  EVNTR
//
//  Created by Alex Ryan on 7/6/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNGradientView.h"

@implementation EVNGradientView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
