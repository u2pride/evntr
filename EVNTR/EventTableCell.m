//
//  EventTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 1/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventTableCell.h"
#import "UIColor+EVNColors.h"

@implementation EventTableCell

#pragma mark - Initialization Methods

- (void)awakeFromNib {
    
    self.backgroundColor = [UIColor clearColor];
    self.eventTitle.textColor = [UIColor whiteColor];
    
    self.roundForEventTypeView.layer.cornerRadius = self.roundForEventTypeView.frame.size.width / 2.0f;
    self.roundForEventTypeView.backgroundColor = [UIColor orangeThemeColor];
    
    self.roundForAttendersView.layer.cornerRadius = self.roundForAttendersView.frame.size.width / 2.0f;
    self.roundForAttendersView.backgroundColor = [UIColor orangeThemeColor];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
