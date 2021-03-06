//
//  UIColor+EVNColors.h
//  EVNTR
//
//  Created by Alex Ryan on 2/19/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (EVNColors)

+ (UIColor *) orangeThemeColor;
+ (UIColor *) darkOrangeThemeColor;
+ (UIColor *) lightOrangeThemeColor;

+ (UIColor *)redOrangeColor;

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end
