//
//  EventTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 1/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventTableCell.h"

@implementation EventTableCell


- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    
    self.eventTitle.textColor = [UIColor whiteColor];
    
    self.roundedContaingView.layer.cornerRadius = 10;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    //TODO: ANIMATION FOR WHEN A USER SELECTS AN EVENT.
    
    // Configure the view for the selected state
}

@end
