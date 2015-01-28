//
//  EventTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 1/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventTableCell.h"

@implementation EventTableCell

@synthesize eventCoverImage, eventTitle, numberOfAttenders;

- (void)awakeFromNib {
    // Initialization code
    //eventCoverImage.image = [UIImage imageNamed:@"EventLoading"];
    eventTitle.textColor = [UIColor whiteColor];
    numberOfAttenders.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
