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



- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    
    self.eventTitle.textColor = [UIColor whiteColor];
    
    
    self.roundForEventTypeView.layer.cornerRadius = self.roundForEventTypeView.frame.size.width / 2.0f;
    self.roundForEventTypeView.backgroundColor = [UIColor orangeThemeColor];
    
    self.roundForAttendersView.layer.cornerRadius = self.roundForAttendersView.frame.size.width / 2.0f;
    self.roundForAttendersView.backgroundColor = [UIColor orangeThemeColor];
    
    

}

- (void) layoutSubviews {
    
    /*
    if (!self.roundForEventTypeView) {
        
        NSLog(@"Inside");
        
        self.roundForEventTypeView = [[UIView alloc] initWithFrame:self.eventTypeLabel.frame];
        self.roundForEventTypeView.frame = CGRectMake(0, 0, self.eventTypeLabel.frame.size.width, self.eventTypeLabel.frame.size.width);
        self.roundForEventTypeView.center = self.eventTypeLabel.center;
        self.roundForEventTypeView.layer.cornerRadius = self.roundForEventTypeView.frame.size.width / 2.0f;
        self.roundForEventTypeView.backgroundColor = [UIColor orangeThemeColor];
        self.roundForAttendersView.translatesAutoresizingMaskIntoConstraints = NO;
        //[self.darkViewOverImage insertSubview:self.roundForEventTypeView atIndex:0];
        
    //}
    

    if (!self.roundForAttendersView) {
        
        self.roundForAttendersView = [[UIView alloc] initWithFrame:self.attendersCountLabel.frame];
        self.roundForAttendersView.frame = CGRectMake(0, 0, self.attendersCountLabel.frame.size.width, self.attendersCountLabel.frame.size.width);
        //self.roundForAttendersView.center = self.attendersCountLabel.center;
        self.roundForAttendersView.layer.cornerRadius = self.roundForAttendersView.frame.size.width / 2.0f;
        self.roundForAttendersView.backgroundColor = [UIColor orangeThemeColor];
        self.roundForAttendersView.translatesAutoresizingMaskIntoConstraints = NO;
        //[self.darkViewOverImage insertSubview:self.roundForAttendersView atIndex:0];
        
    }
    
    
    ////////////////////////////////////////////////////////////////////
    //backgroundView
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.roundForAttendersView
                         attribute:NSLayoutAttributeTrailingMargin
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:0.0
                         constant:-10.0]];
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.roundForAttendersView
                         attribute:NSLayoutAttributeBottomMargin
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:0.0
                         constant:20.0]];
    
    
    //Width
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.roundForAttendersView
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.0
                         constant:33]];
    
    //Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.roundForAttendersView
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.0
                         constant:20.0]];
    
    */

    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    //TODO: ANIMATION FOR WHEN A USER SELECTS AN EVENT.
    
    // Configure the view for the selected state
}



@end
