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

    
    
    
    
    
    
    
    
    
    /*
    UIView* inView = [transitionContext containerView];
        
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [transitionContext.containerView addSubview:toView];

    [inView addSubview:toView];

    CGPoint centerOffScreen = inView.center;
    
    centerOffScreen.y = (-1)*inView.frame.size.height;
    toView.center = centerOffScreen;

    
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.95f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        toView.center = inView.center;
        fromView.alpha = 0.6;
        
    } completion:^(BOOL finished) {
        
        [[UIApplication sharedApplication].keyWindow addSubview: toView];

        [transitionContext completeTransition:YES];
        
        toView.userInteractionEnabled = YES; //delete
        
    }];
    */
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    UIView* inView = [transitionContext containerView];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    
    
    [inView insertSubview:toView belowSubview:fromView];

    
    CGPoint centerOffScreen = inView.center;
    centerOffScreen.y = (-1)*inView.frame.size.height;
    
    [UIView animateKeyframesWithDuration:1.2f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            
            CGPoint center = fromView.center;

            center.y += 50;
            fromView.center = center;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            
            
            fromView.center = centerOffScreen;
            toView.alpha = 1.0;
            
        }];
        
        
    } completion:^(BOOL finished) {
       
        //[[UIApplication sharedApplication].keyWindow addSubview: toView];

        [transitionContext completeTransition:YES];
        

    }];
     
     */
}







/* Archive
 
 -(void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
 
 
 UIView* inView = [transitionContext containerView];
 
 //UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
 //UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
 
 UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
 UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
 
 [transitionContext.containerView addSubview:toView];
 
 //[inView addSubview:toViewController.view];
 [inView addSubview:toView];
 
 CGPoint centerOffScreen = inView.center;
 
 centerOffScreen.y = (-1)*inView.frame.size.height;
 //toViewController.view.center = centerOffScreen;
 toView.center = centerOffScreen;
 
 
 [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.95f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
 
 //toViewController.view.center = inView.center;
 //fromViewController.view.alpha = 0.6;
 toView.center = inView.center;
 fromView.alpha = 0.6;
 
 } completion:^(BOOL finished) {
 
 [[UIApplication sharedApplication].keyWindow addSubview: toView];
 
 [transitionContext completeTransition:YES];
 
 toView.userInteractionEnabled = YES;
 
 //[transitionContext completeTransition:YES];
 //if(![[UIApplication sharedApplication].keyWindow.subviews containsObject:toViewController.view]) {
 //    [[UIApplication sharedApplication].keyWindow addSubview:toViewController.view];
 //}
 
 }];
 }
 
 -(void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
 
 UIView* inView = [transitionContext containerView];
 
 //UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
 //UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
 
 
 UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
 UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
 
 
 //[inView insertSubview:toViewController.view belowSubview:fromViewController.view];
 
 [inView insertSubview:toView belowSubview:fromView];
 
 
 CGPoint centerOffScreen = inView.center;
 centerOffScreen.y = (-1)*inView.frame.size.height;
 
 [UIView animateKeyframesWithDuration:1.2f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
 
 [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
 
 //CGPoint center = fromViewController.view.center;
 CGPoint center = fromView.center;
 
 center.y += 50;
 //fromViewController.view.center = center;
 fromView.center = center;
 }];
 
 [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
 
 //fromViewController.view.center = centerOffScreen;
 //toViewController.view.alpha = 1.0;
 
 fromView.center = centerOffScreen;
 toView.alpha = 1.0;
 
 }];
 
 
 } completion:^(BOOL finished) {
 
 [[UIApplication sharedApplication].keyWindow addSubview: toView];
 
 [transitionContext completeTransition:YES];
 
 
 toView.userInteractionEnabled = YES;
 
 //[transitionContext completeTransition:YES];
 //if(![[UIApplication sharedApplication].keyWindow.subviews containsObject:toViewController.view]) {
 //    [[UIApplication sharedApplication].keyWindow addSubview:toViewController.view];
 //}
 
 }];
 }

*/









//-------------------------------OLDER----------------------------------------------------
/*

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
 
    if(self.isPresenting){
        [self executePresentationAnimation:transitionContext];
    }
    else{
        [self executeDismissalAnimation:transitionContext];
    }
 
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
 
    UIView *containerView = [context containerView];
    UIViewController *fromViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Boolean value to determine presentation or dismissal animation
    if (self.reverse){
        [transitionContext.containerView addSubview:toViewController.view];
        // Your presenting animation code
        
        
        
    } else {
        // Your dismissal animation code
    }
    
    
    UIView *inView = [context containerView];
    UIView *toView = [[context viewControllerForKey:UITransitionContextToViewControllerKey]view];
    UIView *fromView = [[context viewControllerForKey:UITransitionContextFromViewControllerKey]view];

    if (self.reverse) {
        [inView insertSubview:toView belowSubview:fromView];
    }
    else {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        toView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        toView.transform = CGAffineTransformMakeScale(0, 0);
        [inView addSubview:toView];
    }
    
    CGFloat damping = self.reverse ? 1.0 : 0.8;
    NSTimeInterval duration = [self transitionDuration:context];

    [toView setUserInteractionEnabled: true];
    [fromView setUserInteractionEnabled: false];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:6.0 options:0 animations:^{
        if (self.reverse) {
            fromView.transform = CGAffineTransformMakeScale(0, 0);
        }
        else {
            toView.transform = CGAffineTransformIdentity; // i.e. CGAffineTransformMakeScale(1, 1);
        }

    } completion:^(BOOL finished) {
        
        [[[UIApplication sharedApplication] keyWindow] sendSubviewToBack:toView];

        [context completeTransition:finished]; // vital

        
        UIViewController *toViewController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
        
        BOOL canceled = [context transitionWasCancelled];
        [context completeTransition:!canceled];
        if (!canceled)
        {
            [[UIApplication sharedApplication].keyWindow addSubview: toViewController.view];
            toViewController.view.userInteractionEnabled = YES;
        }
        
 

        
    }];
    
    
    
}
*/


@end
