//
//  EVNButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
#import "EVNConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+EVNColors.h"

@interface EVNButton ()

@property (nonatomic, strong) UILabel *titleTextLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation EVNButton

#pragma mark - Initialization Methods

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupButton];
    }
    
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setupButton];
    }
    
    return self;
}

- (void) setupButton {
    
    _buttonColorOpposing = [UIColor whiteColor];
    _isStateless = NO;
    _font = [UIFont fontWithName:EVNFontRegular size:14.0];
    _isRounded = YES;
    _buttonColor = [UIColor orangeThemeColor];
    _isSelected = NO;
    _hasBorder = YES;
    _titleText = @"";
    
    self.layer.cornerRadius = (_isRounded) ? 10 : 0;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _titleTextLabel = [[UILabel alloc] init];
    _titleTextLabel.frame = CGRectMake(0, 0, 100, 50);
    
    _titleTextLabel.text = self.titleText;
    _titleTextLabel.textAlignment = NSTextAlignmentCenter;
    _titleTextLabel.textColor = self.buttonColor;
    _titleTextLabel.backgroundColor = [UIColor clearColor];
    _titleTextLabel.font = self.font;
    
    _titleTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_titleTextLabel];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _activityIndicator.hidesWhenStopped = YES;
    
    [self addSubview:_activityIndicator];

    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = _buttonColor.CGColor;
}


- (void) layoutSubviews {
    
    //Center the Title Text Label and Activity Indicator
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.titleTextLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.activityIndicator
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.titleTextLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:self.activityIndicator
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];
    
    //Set the Width and Height of the Title Text Label to 0.8 of EVNButton frame
    [self addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleTextLabel
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.8
                              constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleTextLabel
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.8
                              constant:0.0]];
    
}



#pragma mark - Custom Setters

- (void) setTitleText:(NSString *)titleText {
    
    self.titleTextLabel.text = titleText;
    
    if ([titleText isEqualToString:@"Follow"]) {
        [self setIsSelected:NO];
    } else if ([titleText isEqualToString:@"Following"]) {
        [self setIsSelected:YES];
    } else if ([titleText isEqualToString:@"Let In"]) {
        [self setIsSelected:NO];
    } else if ([titleText isEqualToString:@"Revoke"]) {
        [self setIsSelected:YES];
    }
    
    _titleText = titleText;
    
}

- (void) setIsRounded:(BOOL)isRounded {
    
    self.layer.cornerRadius =  (isRounded) ? 10 : 0;
    
    _isRounded = isRounded;
    
}

- (void) setButtonColorOpposing:(UIColor *)buttonColorOpposing {
    
    if (!self.isSelected) {
        self.backgroundColor = buttonColorOpposing;
    }
    
    _buttonColorOpposing = buttonColorOpposing;
}

- (void) setIsSelected:(BOOL)isSelected {
    
    
    if (isSelected && !self.isStateless) {
        
        self.titleTextLabel.alpha = 1;
        self.backgroundColor = self.buttonColor;
        self.titleTextLabel.textColor = [UIColor whiteColor];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.titleTextLabel.alpha = 1;
            self.backgroundColor = self.buttonColor;
            self.titleTextLabel.textColor = [UIColor whiteColor];
            
        } completion:^(BOOL finished) {
            
        }];
        
        
    } else if (!isSelected && !self.isStateless) {
        
        self.titleTextLabel.alpha = 1;
        self.backgroundColor = self.buttonColorOpposing;
        self.titleTextLabel.textColor = self.buttonColor;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.titleTextLabel.alpha = 1;
            self.backgroundColor = self.buttonColorOpposing;
            self.titleTextLabel.textColor = self.buttonColor;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    _isSelected = isSelected;
    
}

- (void) setButtonColor:(UIColor *)buttonColor {
    
    self.layer.borderColor = buttonColor.CGColor;
    
    _buttonColor = buttonColor;
}


- (void) setFont:(UIFont *)font {
    
    self.titleTextLabel.font = font;
    
    _font = font;
    
}

- (void) setHasBorder:(BOOL)hasBorder {
    
    [self setNeedsDisplay];
    
    if (hasBorder) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = _buttonColor.CGColor;
    } else {
        self.layer.borderWidth = 0.0f;
        self.layer.borderColor = _buttonColor.CGColor;
    }
    
    _hasBorder = hasBorder;
    
    [self setNeedsDisplay];
    
}


#pragma mark - Long Running Tasks Methods

- (void) startedTask {
    
    self.enabled = NO;

    [UIView animateWithDuration:0.25 animations:^{
        
        self.titleTextLabel.alpha = 0;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.6];
        
        [self.activityIndicator startAnimating];

    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void) endedTask {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.titleTextLabel.alpha = 1;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1.0];
        
        [self.activityIndicator stopAnimating];
        

    } completion:^(BOOL finished) {
        
        self.enabled = YES;

    }];
    
}



#pragma mark - Button Feedback

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [super beginTrackingWithTouch:touch withEvent:event];
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];

    }];
    
    return YES;
    
}



@end
