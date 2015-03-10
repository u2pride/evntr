//
//  EventPictureCell.h
//  EVNTR
//
//  Created by Alex Ryan on 3/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface EventPictureCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PFImageView *eventPictureView;

@end
