//
//  StandbyCollectionViewCell.h
//  EVNTR
//
//  Created by Alex Ryan on 3/9/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ImageViewPFExtended.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@interface StandbyCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet ImageViewPFExtended *profilePictureOfStandbyUser;

@end
