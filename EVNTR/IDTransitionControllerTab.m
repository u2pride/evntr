//
//  IDTransitionController.m
//  AnimationExperiments
//
//  Created by Ian Dundas on 24/09/2013.
//  Copyright (c) 2013 Ian Dundas. All rights reserved.
//

#import "IDTransitionControllerTab.h"

@implementation IDTransitionControllerTab

@synthesize isPresenting;

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.2;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if (self.isPresenting) {
        NSLog(@"HERE");
        [self executePresentationAnimation:transitionContext];
    } else {
        NSLog(@"THERE");
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
        
        //KEY
        fromView.transform = CGAffineTransformIdentity;
        toView.transform = CGAffineTransformIdentity;
        
    }];
    
}

/*
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [containerView addSubview:presentingView];
    [containerView bringSubviewToFront:presentingView];
    
    
    if(isPresenting)
    {
        // Set up the initial position of the presented settings controller. Scale it down so it seems in the distance. Alpha it down so it is dark and shadowed.
        //presentedController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        //presentedController.view.alpha = 0.7;
        
        presentedView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        presentedView.alpha = 0.7;
        
        
        [UIView animateWithDuration: [self transitionDuration: transitionContext] animations:^{
            // Lift up the presented controller.
            //presentedController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
            presentedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
            // Brighten the presented controller (out of shadow).
            //presentedController.view.alpha = 1;
            
            presentedView.alpha = 1;
            
            // Push the presenting controller down the screen – 3d effect to be added later.
            //presentingController.view.layer.transform = CATransform3DMakeTranslation(0,400,0);
            
            presentingView.layer.transform = CATransform3DMakeTranslation(0, 400, 0);
            
            
        } completion: ^(BOOL finished){
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
    }
    else
    {
        //presentedController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        //presentedController.view.alpha = 0.7;
        
        presentedView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        presentedView.alpha = 0.7;
        
        [presentingView addSubview:presentedView];

        
        [UIView animateWithDuration: [self transitionDuration: transitionContext] animations:^{
            // Bring the presenting controller back to its original position.
            //presentingController.view.layer.transform = CATransform3DIdentity;
            
            presentingView.layer.transform = CATransform3DIdentity;
            
            // Lower the presented controller again and put it back in to shade.
            //presentedController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
            //presentedController.view.alpha = 0.4;
            
            presentedView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            presentedView.alpha = 0.4;
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
    }
    
}
*/

@end
