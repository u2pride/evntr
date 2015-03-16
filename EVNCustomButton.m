//
//  EVNCustomButton.m
//  EVNTR
//
//  Created by Alex Ryan on 3/2/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNCustomButton.h"
#import "UIColor+EVNColors.h"

@implementation EVNCustomButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self addTarget:self action:@selector(buttonTapped:withEvent:) forControlEvents:UIControlEventTouchDown];
        self.clipsToBounds = YES;
        
    }
    
    return self;
    
}


- (void)buttonTapped:(EVNCustomButton *)sender withEvent:(UIEvent *)event {
    
    NSLog(@"BUTTON TAPPED");
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint locationOfTouch = [touch locationInView:self];
    
    CAShapeLayer *circleShape = nil;
    CGFloat scale = 20.5f;
    CGFloat radius = 15.0f;
    
    circleShape = [self createCircleShapeWithPosition:CGPointMake(locationOfTouch.x - radius, locationOfTouch.y - radius)
                                             pathRect:CGRectMake(0, 0, radius * 2, radius * 2)
                                               radius:radius];

    [self.layer addSublayer:circleShape];
    [circleShape addAnimation:[self createFlashAnimationWithScale:scale duration:0.5f] forKey:nil];
    
    
}


- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @0.75;
    alphaAnimation.toValue = @1;
    
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
    circleShape.fillColor = [UIColor darkOrangeThemeColor].CGColor;
    
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //self.layer.backgroundColor = [UIColor purpleColor].CGColor;
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
