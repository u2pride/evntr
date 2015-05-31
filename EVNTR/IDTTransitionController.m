//
//  IDTransitionController.m
//  AnimationExperiments
//
//  Created by Ian Dundas on 24/09/2013.
//  Copyright (c) 2013 Ian Dundas. All rights reserved.
//

#import "IDTTransitionController.h"

@implementation IDTTransitionController

@synthesize isPresenting;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.2;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if(self.isPresenting){
        [self executePresentationAnimation:transitionContext];
    }
    else{
        [self executeDismissalAnimation:transitionContext];
    }
    

}

-(void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* inView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [transitionContext.containerView addSubview:toView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    toView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    //fromView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    //fromView.transform = CGAffineTransformIdentity;
    
    toView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    toView.alpha = 0;
    [inView addSubview:toView];
    
    CGFloat damping =  1.0;
    NSTimeInterval duration = 0.75;
    
    [toView setUserInteractionEnabled: true];
    [fromView setUserInteractionEnabled: false];
    
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1.0 options:0 animations:^{

        toView.alpha = 1;
        toView.transform = CGAffineTransformIdentity; // i.e. CGAffineTransformMakeScale(1, 1);
        //fromView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
    } completion:^(BOOL finished) {
        
        //[[UIApplication sharedApplication].keyWindow addSubview: toView]; //add if not working.

        [transitionContext completeTransition:YES];
    }];

}



-(void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    
    UIView* inView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [inView insertSubview:toView belowSubview:fromView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    toView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    //fromView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    //fromView.transform = CGAffineTransformIdentity;
    
    toView.transform = CGAffineTransformMakeScale(1, 1);
    //toView.alpha = 0;
    fromView.alpha = 1;
    [inView addSubview:toView];
    
    CGFloat damping =  1.0;
    NSTimeInterval duration = 0.75;
    
    [toView setUserInteractionEnabled: true];
    [fromView setUserInteractionEnabled: false];
    
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1.0 options:0 animations:^{

        //toView.alpha = 1.0;
        fromView.alpha = 0;
        fromView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        toView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished]; // vital
    }];
    
}



@end
