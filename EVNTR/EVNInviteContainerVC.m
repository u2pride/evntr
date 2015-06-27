//
//  EVNInviteContainerVC.m
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteContactsVC.h"
#import "EVNInviteContainerHeaderView.h"
#import "EVNInviteContainerVC.h"
#import "EVNInviteNewFriendsVC.h"
#import "EVNUtility.h"

@interface EVNInviteContainerVC ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) EVNInviteContainerHeaderView *controlView;

@property (nonatomic, strong) EVNInviteNewFriendsVC *facebookVC;
@property (nonatomic, strong) EVNInviteContactsVC *contactsVC;

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
    
    self.facebookVC = [[EVNInviteNewFriendsVC alloc] init];
    self.facebookVC.view.frame = self.contentView.bounds;
    [self addChildViewController:self.facebookVC];
    [self.contentView addSubview:self.facebookVC.view];
    [self.facebookVC didMoveToParentViewController:self];
    
    UITapGestureRecognizer *facebookGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapVCs2)];
    UITapGestureRecognizer *contactsGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapVCs)];
    
    [self.controlView.facebookButton addGestureRecognizer:facebookGR];
    [self.controlView.contactsButton addGestureRecognizer:contactsGR];
    
    self.contactsVC = [EVNInviteContactsVC new];
    
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
    
    [self moveFromVC:self.facebookVC toVC:self.contactsVC];
    
    [self.controlView lineUnderIndex:1];
    
}

- (void) swapVCs2 {
    
    [self moveFromVC:self.contactsVC toVC:self.facebookVC];

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
