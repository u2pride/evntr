//
//  UIColor+EVNColors.m
//  EVNTR
//
//  Created by Alex Ryan on 2/19/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "UIColor+EVNColors.h"

@implementation UIColor (EVNColors)

+ (UIColor *) orangeThemeColor {
    
    return [UIColor colorWithRed:0.922 green:0.333 blue:0.141 alpha:1]; /*#eb5524*/}

+ (UIColor *) darkOrangeThemeColor {
    return [UIColor colorWithRed:0.651 green:0.322 blue:0 alpha:1]; /*#a65200*/
}


- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}


@end
