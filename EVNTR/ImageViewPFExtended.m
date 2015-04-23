//
//  ImageViewPFExtended.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "ImageViewPFExtended.h"

@implementation ImageViewPFExtended

- (void)setImageToUse:(UIImage *)imageToUse {
    
    //UIImage *newImage = [EVNUtility maskImage:imageToUse withMask:[UIImage imageNamed:@"MaskImage"]];
    
    [super setImage:imageToUse];
    
    _imageToUse = imageToUse;
    
}

@end
