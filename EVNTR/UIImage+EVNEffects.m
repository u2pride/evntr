//
//  UIImage+EVNEffects.m
//  EVNTR
//
//  Created by Alex Ryan on 4/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "UIImage+EVNEffects.h"

@implementation UIImage (EVNEffects)


+ (UIImage *) imageWithView:(UIView *)view {

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;

}


@end
