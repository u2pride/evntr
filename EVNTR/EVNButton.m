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

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _buttonColorOpposing = [UIColor whiteColor];
        _isStateless = NO;
        _font = [UIFont fontWithName:EVNFontRegular size:14.0];
        _isRounded = YES;
        _buttonColor = [UIColor orangeThemeColor];
        _isSelected = NO;
        _hasBorder = YES;
        _titleText = @"Button";
        [self setupButton];
    }
    
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _buttonColorOpposing = [UIColor whiteColor];
        _isStateless = NO;
        _font = [UIFont fontWithName:EVNFontRegular size:14.0];
        _isRounded = YES;
        _buttonColor = [UIColor orangeThemeColor];
        _isSelected = NO;
        _hasBorder = YES;
        _titleText = @"Button";
        [self setupButton];
    }
    
    return self;
}


- (void) setTitleText:(NSString *)titleText {
    
    self.titleTextLabel.text = titleText;
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
    
    NSLog(@"set isselected");

    if (isSelected && !self.isStateless) {
        
        [UIView animateWithDuration:0.8 animations:^{
            
            self.titleTextLabel.alpha = 1;
            self.backgroundColor = self.buttonColor;
            self.titleTextLabel.textColor = [UIColor whiteColor];
            
        } completion:^(BOOL finished) {
            
        }];
        
        
    } else if (!isSelected && !self.isStateless) {
        
        [UIView animateWithDuration:0.8 animations:^{
            
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
    NSLog(@"set has border.");

    if (hasBorder) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = _buttonColor.CGColor;
    } else {
        NSLog(@"updating layer borderwidth...");
        self.layer.borderWidth = 0.0f;
        self.layer.borderColor = _buttonColor.CGColor;
    }

    _hasBorder = hasBorder;

    [self setNeedsDisplay];
    
}

- (void) setupButton {
    
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


/*
- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //touch started in control
    
    
    //self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    
    CGPoint locationOfTouch = [touch locationInView:self];
    
    CAShapeLayer *circleShape = nil;
    CGFloat scale = 10.5f;
    CGFloat radius = 15.0f;
    
    circleShape = [self createCircleShapeWithPosition:CGPointMake(locationOfTouch.x - radius, locationOfTouch.y - radius)
                                             pathRect:CGRectMake(0, 0, radius * 2, radius * 2)
                                               radius:radius];
    
    [self.layer addSublayer:circleShape];
    [circleShape addAnimation:[self createFlashAnimationWithScale:scale duration:0.15f] forKey:nil];

    
    if (self.isSelected) {
        
        [self setIsSelected:NO];
    
    } else {
        
        [self setIsSelected:YES];

    }
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];

    
    return NO;
    
}


- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.75;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.delegate = self;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return animation;
}


- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius
{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    
    circleShape.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    
    UIColor *darkerColor = [self.buttonColor darkerColor];
    circleShape.fillColor = darkerColor.CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}


*/


- (void) startedTask {
    
    self.enabled = NO;

    NSLog(@"started task");
    
    [UIView animateWithDuration:0.35 animations:^{
        
        self.titleTextLabel.alpha = 0;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.6];
        
        //if (self.isRounded) {
        //    self.layer.cornerRadius = 0;
        //}
        
        [self.activityIndicator startAnimating];

        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            
        }
        
    }];
    
    
}

- (void) endedTask {
    
    [UIView animateWithDuration:0.35 animations:^{
        
        self.titleTextLabel.alpha = 1;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1.0];
        
        //if (self.isRounded) {
        //    self.layer.cornerRadius = 10;
        //}
        
        [self.activityIndicator stopAnimating];
        
        self.enabled = YES;

    } completion:^(BOOL finished) {
        
        if (finished) {
            
            
        }
        
    }];
    
}



@end
