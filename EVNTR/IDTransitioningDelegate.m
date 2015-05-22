//
//  IDTransitioningDelegate.m
//  AnimationExperiments
//
//  Created by Ian Dundas on 23/09/2013.
//  Copyright (c) 2013 Ian Dundas. All rights reserved.
//

#import "IDTransitioningDelegate.h"
#import "IDTransitionController.h"

@implementation IDTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    IDTransitionController *transitioning = [[IDTransitionController alloc]init];
    
    transitioning.isPresenting = YES;
    
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    IDTransitionController *transitioning = [[IDTransitionController alloc]init];

    transitioning.isPresenting = NO;
    
    return transitioning;
}


@end
