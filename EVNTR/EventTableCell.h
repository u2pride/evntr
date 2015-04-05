//
//  EventTableCell.h
//  EVNTR
//
//  Created by Alex Ryan on 1/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface EventTableCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UIView *roundedContaingView;
@property (nonatomic, strong) IBOutlet PFImageView *eventCoverImage;
@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateOfEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeOfEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (strong, nonatomic) IBOutlet UIView *darkViewOverImage;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end
