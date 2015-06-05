//
//  ActivityTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "ActivityTableCell.h"

@implementation ActivityTableCell

//Necessary for Dynamic Cell Heights
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    
    self.activityContentTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.activityContentTextLabel.frame);
}

- (void)setActivityContentTextLabel:(UILabel *)activityContentTextLabel {
    
    _activityContentTextLabel = activityContentTextLabel;
}

- (void)setTimestampActivity:(UILabel *)timestampActivity {
    
    _timestampActivity = timestampActivity;
}

- (void) highlightCellForNewNotification {
        
    self.backgroundColor = [UIColor colorWithRed:0.922 green:0.333 blue:0.141 alpha:0.15];
    
    //[UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
    //    self.backgroundColor = [UIColor whiteColor];
        
    //} completion:^(BOOL finished) {
        
    //}];
    
    
}

- (void) resetHighlighting {
    
    self.backgroundColor = [UIColor whiteColor];

}

@end
