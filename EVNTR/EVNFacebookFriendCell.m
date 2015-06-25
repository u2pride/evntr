//
//  EVNFacebookFriendCell.m
//  EVNTR
//
//  Created by Alex Ryan on 6/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNFacebookFriendCell.h"

@implementation EVNFacebookFriendCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _friendNameLabel = [[UILabel alloc] init];
        _friendNameLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
        _followButton = [[EVNButtonExtended alloc] init];
        _followButton.titleText = @" View ";
        _followButton.font = [UIFont fontWithName:@"Lato-Light" size:16.0];
        
        _friendNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _followButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_friendNameLabel];
        [self.contentView addSubview:_followButton];
        
    }
    
    return self;
    
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    
    //Follow Button
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.followButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.7
                                     constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.followButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                     constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.followButton
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeRight
                                     multiplier:1.0
                                     constant:-20.0]];
    
    CGRect followRect = [@" View " boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Light" size:16]} context:nil];
                                                                                                                                    
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.followButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:0.0
                                     constant:(followRect.size.width * 1.5)]];
    
    //Name Label
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.friendNameLabel
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:0.8
                                     constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.friendNameLabel
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                     constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.friendNameLabel
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeLeft
                                     multiplier:1.0
                                     constant:20.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.friendNameLabel
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.followButton
                                     attribute:NSLayoutAttributeLeft
                                     multiplier:1.0
                                     constant:-20.0]];
    
    
  
    
}



- (void)awakeFromNib {
    // Initialization code
}


@end
