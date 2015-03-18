//
//  EVNDefaultButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNDefaultButton.h"
#import "UIColor+EVNColors.h"
#import <QuartzCore/QuartzCore.h>

@implementation EVNDefaultButton

//CALLED WHEN INITIALIZED FROM STORYBOARD
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor orangeThemeColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        
    }
    
    return self;
    
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.layer setShadowOffset:CGSizeZero];
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowRadius:10.0];
    [self.layer setShadowOpacity:0.3];
    [self.layer setCornerRadius:10.0f];
    
    
}





/*
- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        NSLog(@"HI");
        self.backgroundColor = [UIColor orangeThemeColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
