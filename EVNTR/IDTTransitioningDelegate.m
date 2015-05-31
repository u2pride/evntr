//
//  IDTransitioningDelegate.m
//  AnimationExperiments
//
//  Created by Ian Dundas on 23/09/2013.
//  Copyright (c) 2013 Ian Dundas. All rights reserved.
//

#import "IDTTransitioningDelegate.h"
#import "IDTTransitionController.h"

@implementation IDTTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    IDTTransitionController *transitioning = [[IDTTransitionController alloc]init];
    
    transitioning.isPresenting = YES;
    
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    IDTTransitionController *transitioning = [[IDTTransitionController alloc]init];

    transitioning.isPresenting = NO;
    
    return transitioning;
}



@end
