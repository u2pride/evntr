//
//  ActivityTableCell.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface ActivityTableCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftSideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightSideImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityContentTextLabel;

@end
