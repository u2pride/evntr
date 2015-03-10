//
//  ImageViewPFExtended.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ImageViewPFExtended : PFImageView

@property (nonatomic, strong) PFObject *objectForImageView;
@property (nonatomic, strong, setter= setImage:) UIImage *image;

@end
