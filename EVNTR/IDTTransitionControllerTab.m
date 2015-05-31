//
//  IDTransitionController.m
//  AnimationExperiments
//
//  Created by Ian Dundas on 24/09/2013.
//  Copyright (c) 2013 Ian Dundas. All rights reserved.
//

#import "IDTTransitionControllerTab.h"

@implementation IDTTransitionControllerTab

@synthesize isPresenting;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.2;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if (self.isPresenting) {
        [self executePresentationAnimation:transitionContext];
    } else {
        [self executeDismissalAnimation:transitionContext];
    }
    
}

- (void) executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *inView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    toView.transform = CGAffineTransformMakeTranslation(0, -700);
    
    [inView addSubview:toView];
    [inView bringSubviewToFront:toView];

    [UIView animateWithDuration:0.5 animations:^{
        
        fromView.alpha = 0;
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        //KEY - reset both views
        fromView.alpha = 1;
        fromView.transform = CGAffineTransformIdentity;
        toView.transform = CGAffineTransformIdentity;
        
    }];
}


- (void) executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIView *inView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [inView insertSubview:toView belowSubview:fromView];
    
    fromView.transform = CGAffineTransformIdentity;
    toView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.5 animations:^{
        
        toView.transform = CGAffineTransformIdentity;
        fromView.transform = CGAffineTransformMakeTranslation(0, -700);
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
        
        //KEY - reset both views
        fromView.transform = CGAffineTransformIdentity;
        toView.transform = CGAffineTransformIdentity;
        
    }];
}


@end
