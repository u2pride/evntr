//
//  ActivityTableCell.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "ImageViewPFExtended.h"
#import "EVNButtonExtended.h"

@interface ActivityTableCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet ImageViewPFExtended *leftSideImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityContentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampActivity;
@property (weak, nonatomic) IBOutlet EVNButtonExtended *actionButton;

- (void) highlightCellForNewNotification;
- (void) resetHighlighting;


@end
