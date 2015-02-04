//
//  ImageViewPFExtended.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewPFExtended : UIImageView

@property (nonatomic, strong) PFUser *userForImageView;

@end
