//
//  EVNInviteContainerVC.m
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteContainerHeaderView.h"
#import "EVNInviteContainerVC.h"
#import "EVNUtility.h"

@interface EVNInviteContainerVC ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) EVNInviteContainerHeaderView *controlView;

@end

@implementation EVNInviteContainerVC

#pragma mark - View Methods

- (void)loadView {
    
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    
    self.controlView = [EVNInviteContainerHeaderView new];
    self.controlView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:self.controlView];
    [view addSubview:self.contentView];
    
    
    
    self.view = view;
    
}


#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Find & Invite Friends";
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
    
    //self.viewControllerOne = [[EVNInviteNewFriendsVC alloc] init];
    self.viewControllerOne.view.frame = self.contentView.bounds;
    [self addChildViewController:self.viewControllerOne];
    [self.contentView addSubview:self.viewControllerOne.view];
    [self.viewControllerOne didMoveToParentViewController:self];
    
    UITapGestureRecognizer *facebookGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapVCs2)];
    UITapGestureRecognizer *contactsGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapVCs)];
    
    [self.controlView.facebookButton addGestureRecognizer:facebookGR];
    [self.controlView.contactsButton addGestureRecognizer:contactsGR];
    
    //self.viewControllerTwo = [EVNInviteContactsVC new];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.view setNeedsUpdateConstraints];
    
}


- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    
    //Control View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controlView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controlView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.2
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controlView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.controlView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
    //Content View

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.8
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
}



#pragma mark - Helper Methods

- (void) swapVCs {
    
    [self moveFromVC:self.viewControllerOne toVC:self.viewControllerTwo];
    
    [self.controlView lineUnderIndex:1];
    
}

- (void) swapVCs2 {
    
    [self moveFromVC:self.viewControllerTwo toVC:self.viewControllerOne];

    [self.controlView lineUnderIndex:0];

}


- (void) moveFromVC:(UIViewController*)fromVC toVC:(UIViewController*)toVC {
    
    [fromVC willMoveToParentViewController:nil];
    [self addChildViewController:toVC];
    
    toVC.view.frame = self.contentView.bounds;
    
    [self.contentView addSubview:toVC.view];
    
    [fromVC.view removeFromSuperview];
    [fromVC removeFromParentViewController];
    [toVC didMoveToParentViewController:self];
    
}


@end
