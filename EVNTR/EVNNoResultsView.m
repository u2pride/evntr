//
//  EVNNoResultsView.m
//  EVNTR
//
//  Created by Alex Ryan on 3/19/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#define HEADER_FONT_SIZE 26
#define SUBHEADER_FONT_SIZE 16

#import "EVNNoResultsView.h"
#import "EVNConstants.h"

@interface EVNNoResultsView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *headerTextLabel;
@property (nonatomic, strong) UILabel *subHeaderTextLabel;

@end

@implementation EVNNoResultsView

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
    
    //self.backgroundColor = [UIColor orangeColor];
    
    
    _backgroundView = [[UIView alloc] init];
    _headerTextLabel = [[UILabel alloc] init];
    _subHeaderTextLabel = [[UILabel alloc] init];
    
    _backgroundView.backgroundColor = [UIColor whiteColor];
    //_headerTextLabel.backgroundColor = [UIColor blueColor];
    //_subHeaderTextLabel.backgroundColor = [UIColor purpleColor];
    
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
    
    
    /*
    _address = @"Location Address";
    _eventLocation = [[CLLocation alloc] init];
    _distanceAway = 2.0f;
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    _addressLabel = [[UILabel alloc] init];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    _addressLabel.font = [UIFont fontWithName:@"Lato-Light" size:16];
    _addressLabel.textColor = [UIColor blackColor];
    _addressLabel.numberOfLines = 2;
    _addressLabel.text = _address;
    
    _distanceAwayLabel = [[UILabel alloc] init];
    _distanceAwayLabel.textAlignment = NSTextAlignmentCenter;
    _distanceAwayLabel.font = [UIFont fontWithName:@"Lato-Light" size:78];
    _distanceAwayLabel.text = @"23.4";
    
    
    _circleView = [[UIView alloc] init];
    
    _milesAwayLabel = [[UILabel alloc] init];
    _milesAwayLabel.text = @"miles away";
    _milesAwayLabel.textAlignment = NSTextAlignmentCenter;
    _milesAwayLabel.font = [UIFont fontWithName:EVNFontRegular size:12];
    _milesAwayLabel.textColor = [UIColor darkGrayColor];
    
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _distanceAwayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _circleView.translatesAutoresizingMaskIntoConstraints = NO;
    _milesAwayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_mapView];
    [self addSubview:_circleView];
    [self addSubview:_addressLabel];
    
    [_circleView addSubview:_distanceAwayLabel];
    [_circleView addSubview:_milesAwayLabel];
    
    
    _mapView.backgroundColor = [UIColor orangeColor];
    _addressLabel.backgroundColor = [UIColor whiteColor];
    _circleView.backgroundColor = [UIColor whiteColor];
    _distanceAwayLabel.backgroundColor = [UIColor clearColor];
    _milesAwayLabel.backgroundColor = [UIColor clearColor];
    
    */
    
}



- (void) layoutSubviews {
    
    NSLog(@"LayoutSubviewsCalled");
    
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
    
    NSLog(@"size: %@", NSStringFromCGSize(adjustedSize));
    
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
                         constant:-constantToMoveCenterY]];
    
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
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.actionButton
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:20.0]];
    
    
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


- (void) setHeaderText:(NSString *)headerText {
    
    self.headerTextLabel.text = headerText;
    
    _headerText = headerText;
}


- (void) setSubHeaderText:(NSString *)subHeaderText {
    
    self.subHeaderTextLabel.text = subHeaderText;
    
    _subHeaderText = subHeaderText;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
