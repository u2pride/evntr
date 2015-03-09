//
//  ImageViewPFExtended.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ImageViewPFExtended.h"
#import "EVNUtility.h"

@implementation ImageViewPFExtended

@synthesize objectForImageView;

- (void)setImage:(UIImage *)image {
    
    UIImage *newImage = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
    
    [super setImage:newImage];
        
}

@end
