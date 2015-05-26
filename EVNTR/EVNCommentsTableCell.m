//
//  EVNCommentsTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 4/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNCommentsTableCell.h"

@implementation EVNCommentsTableCell

- (void)awakeFromNib {
    // Initialization code

    self.commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.commentTextLabel.numberOfLines = 0;
}

//Neccessary for Dynamic Cell Heights
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.commentTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.commentTextLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
