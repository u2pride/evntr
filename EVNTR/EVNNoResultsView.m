//
//  EVNNoResultsView.m
//  EVNTR
//
//  Created by Alex Ryan on 3/19/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNNoResultsView.h"

#define HEADER_FONT_SIZE 26
#define SUBHEADER_FONT_SIZE 16

@interface EVNNoResultsView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *headerTextLabel;
@property (nonatomic, strong) UILabel *subHeaderTextLabel;

@end

@implementation EVNNoResultsView

#pragma mark - Initialization Methods

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}


- (void) setup {
    
    _offsetY = 0;
    
    _backgroundView = [[UIView alloc] init];
    _headerTextLabel = [[UILabel alloc] init];
    _subHeaderTextLabel = [[UILabel alloc] init];
    
    _backgroundView.backgroundColor = [UIColor whiteColor];
    
    _actionButton = [[EVNButton alloc] init];
    _actionButton.titleText = @"";
    _actionButton.font = [UIFont fontWithName:EVNFontRegular size:15.0];
    
    _headerTextLabel.textColor = [UIColor blackColor];
    _subHeaderTextLabel.textColor = [UIColor blackColor];
    _headerTextLabel.textAlignment = NSTextAlignmentCenter;
    _subHeaderTextLabel.textAlignment = NSTextAlignmentCenter;
    
    _subHeaderTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _subHeaderTextLabel.numberOfLines = 0;
    
    _headerTextLabel.text = @"";
    _subHeaderTextLabel.text = @"";
    _headerTextLabel.font = [UIFont fontWithName:EVNFontRegular size:HEADER_FONT_SIZE];
    _subHeaderTextLabel.font = [UIFont fontWithName:EVNFontLight size:SUBHEADER_FONT_SIZE];
    
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _headerTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _subHeaderTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_backgroundView];
    [self addSubview:_headerTextLabel];
    [self addSubview:_subHeaderTextLabel];
    [self addSubview:_actionButton];
    
}


- (void) setOffsetY:(int)offsetY {
    
    [self setNeedsDisplay];
    
    _offsetY = offsetY;
}


- (void) layoutSubviews {
    
    ////////////////////////////////////////////////////////////////////
    //backgroundView
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.backgroundView
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.backgroundView
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];
    
    
    //Width
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.backgroundView
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:1.0
                         constant:0.0]];
    
    //Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.backgroundView
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:1.0
                         constant:0.0]];
    
    
    ////////////////////////////////////////////////////////////////////
    //header text label
    
    NSString *sampleString = @"Header";

    CGSize size = [sampleString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:EVNFontRegular size:HEADER_FONT_SIZE]}];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.headerTextLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y Plus Offset
    int constantToMoveCenterY = self.frame.size.height / 4.0;
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.headerTextLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:(-constantToMoveCenterY - self.offsetY)]];
    
    //80% Width
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.headerTextLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.8
                         constant:0.0]];
    
    //Height Related to Text String
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.headerTextLabel
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.0
                         constant:adjustedSize.height]];
    
    
    
    ////////////////////////////////////////////////////////////////////
    //SubHeader Label
    
    CGSize size2 = [sampleString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:SUBHEADER_FONT_SIZE]}];
    CGSize adjustedSize2 = CGSizeMake(ceilf(size2.width), ceilf(size2.height));
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.subHeaderTextLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Top is Equal to Header Bottom
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.subHeaderTextLabel
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.headerTextLabel
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.0
                         constant:0]];
    
    
    //Width is 0.85 of Superview
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.subHeaderTextLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.85
                         constant:0.0]];
    
    //Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.subHeaderTextLabel
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.0
                         constant:4*adjustedSize2.height]];
    
    
    ////////////////////////////////////////////////////////////////////
    //Action Button
    
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.actionButton
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    
    //Top is Equal to Header Bottom
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.actionButton
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.subHeaderTextLabel
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.0
                         constant:20]];
    
    
    //Width
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.actionButton
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.8
                         constant:0.0]];
    
    //Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.actionButton
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.08
                         constant:0.0]];
    
    
}

#pragma mark - Setter Methods

- (void) setHeaderText:(NSString *)headerText {
    
    self.headerTextLabel.text = headerText;
    
    _headerText = headerText;
}


- (void) setSubHeaderText:(NSString *)subHeaderText {
    
    self.subHeaderTextLabel.text = subHeaderText;
    
    _subHeaderText = subHeaderText;
}



@end
