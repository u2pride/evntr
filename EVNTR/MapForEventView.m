//
//  MapForEventView.m
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "MapForEventView.h"
#import <QuartzCore/QuartzCore.h>

@interface MapForEventView ()

@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *distanceAwayLabel;
@property (nonatomic, strong) UILabel *milesAwayLabel;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation MapForEventView

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
    
    _address = @"";
    _eventLocation = [[CLLocation alloc] init];
    _distanceAway = 2.0f;
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    _addressLabel = [[UILabel alloc] init];
    _addressLabel.textAlignment = NSTextAlignmentCenter;
    _addressLabel.font = [UIFont fontWithName:@"Lato-Light" size:16];
    _addressLabel.textColor = [UIColor blackColor];
    _addressLabel.numberOfLines = 2;
    _addressLabel.text = _address;
    _addressLabel.alpha = 0.0;

    _distanceAwayLabel = [[UILabel alloc] init];
    _distanceAwayLabel.textAlignment = NSTextAlignmentCenter;
    _distanceAwayLabel.font = [UIFont fontWithName:@"Lato-Light" size:78];
    _distanceAwayLabel.text = @"";
    _distanceAwayLabel.alpha = 0.0;

    
    _circleView = [[UIView alloc] init];
    
    _milesAwayLabel = [[UILabel alloc] init];
    _milesAwayLabel.text = @"miles away";
    _milesAwayLabel.textAlignment = NSTextAlignmentCenter;
    _milesAwayLabel.font = [UIFont fontWithName:EVNFontRegular size:12];
    _milesAwayLabel.textColor = [UIColor darkGrayColor];
    _milesAwayLabel.alpha = 0.0;
    
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.hidesWhenStopped = YES;
    
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
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
    [_circleView addSubview:_activityIndicator];
    
    _mapView.backgroundColor = [UIColor orangeColor];
    _addressLabel.backgroundColor = [UIColor whiteColor];
    _circleView.backgroundColor = [UIColor whiteColor];
    _distanceAwayLabel.backgroundColor = [UIColor clearColor];
    _milesAwayLabel.backgroundColor = [UIColor clearColor];
    
    
    [_activityIndicator startAnimating];

    
}



- (void) layoutSubviews {
    
    ////////////////////////////////////////////////////////////////////
    //Map View
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.mapView
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.mapView
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];
    
    
    //Width
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.mapView
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:1.0
                         constant:0.0]];
    
    //Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.mapView
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:1.0
                         constant:0.0]];
    
    
    ////////////////////////////////////////////////////////////////////
    //Distance Away Circle View

    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.circleView
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y Plus Offset
    int constantToMoveCenterY = self.frame.size.height / 4.0;
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.circleView
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:-constantToMoveCenterY]];
    
    //Width Equal to Height
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.circleView
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeHeight
                         multiplier:1.0
                         constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.circleView
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.4
                         constant:0.0]];
    
    
    
    //Now set the CornerRadius to Make a Circle
    self.circleView.layer.cornerRadius = self.frame.size.height * 0.4 / 2;
    
    self.circleView.clipsToBounds = YES;
    
    
    
    ////////////////////////////////////////////////////////////////////
    //Distance Away Label
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.distanceAwayLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.distanceAwayLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:-20.0]];
    
    //Width is 0.8 of Superview
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.distanceAwayLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.7
                         constant:0.0]];
    
    self.distanceAwayLabel.adjustsFontSizeToFitWidth = YES;
    
    ////////////////////////////////////////////////////////////////////
    //Activity Indicator
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.activityIndicator
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.activityIndicator
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];
    
    //Width is 0.8 of Superview
    /*
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.activityIndicator
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.7
                         constant:0.0]];
    */

    ////////////////////////////////////////////////////////////////////
    //Miles Away Label
    
    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.milesAwayLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Place Directly Below Distance Label
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.milesAwayLabel
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.distanceAwayLabel
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.0
                         constant:-5.0]];
    
    //Width is 0.8 of Superview
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.milesAwayLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.circleView
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.8
                         constant:0.0]];
    
    self.milesAwayLabel.adjustsFontSizeToFitWidth = YES;
    self.milesAwayLabel.textColor = [UIColor darkGrayColor];

    
    ////////////////////////////////////////////////////////////////////
    //Address Label

    //Center X
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.addressLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    //Center Y Plus Offset
    
    int constantToMoveCenterY2 = self.frame.size.height / 4.0;

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.addressLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:constantToMoveCenterY2]];
    
    
    //Width is 0.85 of Superview
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.addressLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:0.85
                         constant:0.0]];
    
    //Height is 0.25 of Superview
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.addressLabel
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeHeight
                         multiplier:0.25
                         constant:0.0]];
    
    self.addressLabel.adjustsFontSizeToFitWidth = YES;
    
}



- (void) setEventLocation:(CLLocation *)eventLocation {
    
    
    _eventLocation = eventLocation;
    
}

- (void) setDistanceAway:(float)distanceAway {
    
    if (distanceAway >= 100.0) {
        self.distanceAwayLabel.text = [NSString stringWithFormat:@"%.f", distanceAway];
    } else {
        self.distanceAwayLabel.text = [NSString stringWithFormat:@"%.01lf", distanceAway];
    }
    
    _distanceAway = distanceAway;
}


- (void) setAddress:(NSString *)address {
    
    self.addressLabel.text = address;
    
    _address = address;
    
}


- (void) startedLoading {
    
    self.distanceAwayLabel.alpha = 0.0;
    self.addressLabel.alpha = 0.0;
    self.milesAwayLabel.alpha = 0.0;
    
    
}

- (void) finishedLoadingWithLocationAvailable:(BOOL)isLocationVisible {
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.distanceAwayLabel.alpha = 1.0;
        self.addressLabel.alpha = 1.0;
        self.milesAwayLabel.alpha = 1.0;

        
    }];
    
    if (isLocationVisible) {
        MKCoordinateRegion region = MKCoordinateRegionMake(self.eventLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05));
        [self.mapView setRegion:region animated:YES];
    }
    
    
    [self.activityIndicator stopAnimating];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
