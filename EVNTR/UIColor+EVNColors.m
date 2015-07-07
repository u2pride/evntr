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
    
    return [UIColor colorWithRed:0.929 green:0.373 blue:0.165 alpha:1]; /*#ed5f2a*/
    //return [UIColor colorWithRed:0.918 green:0.325 blue:0.141 alpha:1]; #ea5324
    //return [UIColor colorWithRed:0.949 green:0.439 blue:0.188 alpha:1]; /*#f27030*/
}

+ (UIColor *) lightOrangeThemeColor {
    return [UIColor colorWithRed:0.863 green:0.259 blue:0.149 alpha:1]; /*#dc4226*/
    //return [UIColor colorWithRed:0.949 green:0.439 blue:0.188 alpha:1]; /*#f27030*/
}

+ (UIColor *) darkOrangeThemeColor {
    return [UIColor colorWithRed:0.855 green:0.259 blue:0.09 alpha:1]; /*#da4217*/
    //return [UIColor colorWithRed:0.918 green:0.325 blue:0.141 alpha:1]; #ea5324
}

+ (UIColor *) redOrangeColor {
    return [UIColor colorWithRed:0.812 green:0.188 blue:0.149 alpha:1]; /*#cf3026*/
}

/*
 
 Light Orange
 
 [UIColor colorWithRed:0.949 green:0.439 blue:0.188 alpha:1] #f27030

 Dark Orange

 [UIColor colorWithRed:0.918 green:0.325 blue:0.141 alpha:1] #ea5324

 Red Orange

 [UIColor colorWithRed:0.812 green:0.188 blue:0.149 alpha:1] #cf3026

*/




//+ (UIColor *) orangeThemeColor {
//    return [UIColor colorWithRed:0.922 green:0.333 blue:0.141 alpha:1]; /*#eb5524*/
//}

//+ (UIColor *) darkOrangeThemeColor {
//    return [UIColor colorWithRed:0.808 green:0.192 blue:0.153 alpha:1]; /*#ce3127*/
//}

//+ (UIColor *) lightOrangeThemeColor {
//    return [UIColor colorWithRed:0.953 green:0.443 blue:0.192 alpha:1]; /*#f37131*/
//}

- (UIColor *)lighterColor {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor {
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}


@end
