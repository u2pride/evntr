//
//  EVNButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNButton.h"
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
        
        _isStateless = NO;
        _font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
        _isRounded = YES;
        _buttonColor = [UIColor orangeThemeColor];
        _isSelected = NO;
        _titleText = @"Button";
        [self setupButton];
    }
    
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _isStateless = NO;
        _font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
        _isRounded = YES;
        _buttonColor = [UIColor orangeThemeColor];
        _isSelected = NO;
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

- (void) setIsSelected:(BOOL)isSelected {
    
    NSLog(@"set isselected");

    if (isSelected && !self.isStateless) {
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.titleTextLabel.alpha = 1;
            self.backgroundColor = self.buttonColor;
            self.titleTextLabel.textColor = [UIColor whiteColor];
            
        } completion:^(BOOL finished) {
            
        }];
        
        
    } else if (!isSelected && !self.isStateless) {
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.titleTextLabel.alpha = 1;
            self.backgroundColor = [UIColor whiteColor];
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

- (void) setupButton {
    
    self.layer.cornerRadius = (self.isRounded) ? 10 : 0;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleTextLabel = [[UILabel alloc] init];
    self.titleTextLabel.frame = CGRectMake(0, 0, 100, 50);
    
    self.titleTextLabel.text = self.titleText;
    self.titleTextLabel.textAlignment = NSTextAlignmentCenter;
    self.titleTextLabel.textColor = self.buttonColor;
    self.titleTextLabel.backgroundColor = [UIColor clearColor];
    self.titleTextLabel.font = self.font;
    
    self.titleTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.titleTextLabel];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self addSubview:self.activityIndicator];
    
    
    
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = self.buttonColor.CGColor;
    
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
    [circleShape addAnimation:[self createFlashAnimationWithScale:scale duration:0.5f] forKey:nil];

    
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





- (void) startedTask {
    

    NSLog(@"started task");
    
    [UIView animateWithDuration:1.0 animations:^{
        
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
    
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.titleTextLabel.alpha = 1;
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1.0];
        
        //if (self.isRounded) {
        //    self.layer.cornerRadius = 10;
        //}
        
        [self.activityIndicator stopAnimating];

        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            
        }
        
    }];
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
