//
//  EVNHomeContainerVC.m
//  EVNTR
//
//  Created by Alex Ryan on 7/21/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNHomeContainerVC.h"
#import "EVNUtility.h"
#import "SearchVC.h"
#import "HomeScreenVC.h"

#import "EVNInviteContainerHeaderView.h"

@interface EVNHomeContainerVC ()

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) float searchRadius;
@property BOOL isGuestUser;

@end

@implementation EVNHomeContainerVC

#pragma mark - View Methods

- (void)loadView {
    
    UIView *view = [[UIView alloc] init];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor redColor];
    
    self.contentView = view;
    
    
    self.view = view;
    
}


#pragma mark - Lifecycle Methods

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        _isGuestUser = [standardDefaults boolForKey:kIsGuest];
        _searchRadius = 20.0;
        
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Home";
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
    
    //stop Movie Player on Initial Screen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopMoviePlayer" object:nil];
    
    //Add Segmented Control to Navigation Bar
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"New", @"Following"]];
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(switchHomeTabs) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:self.segmentControl];
    
    //Initialize Child View Controls
    if (self.isGuestUser) {
        self.friendsViewController = [[UIViewController alloc] init];
        
        EVNNoResultsView *guestMessage = [[EVNNoResultsView alloc] initWithFrame:self.friendsViewController.view.frame];
        guestMessage.headerText = @"#membersonly";
        guestMessage.subHeaderText = @"Once you sign up, here is where you will see all of the events that are created by who you follow.";
        guestMessage.actionButton.hidden = YES;
        
        [self.friendsViewController.view addSubview:guestMessage];
        
    } else {
        self.friendsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsEvenstViewController"];
        EVNFriendsEventsVC *friendsVC = (EVNFriendsEventsVC *) self.friendsViewController;
        friendsVC.delegate = self;
    }
    
    self.allEventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    self.allEventsViewController.view.backgroundColor = [UIColor whiteColor];
    self.friendsViewController.view.backgroundColor = [UIColor whiteColor];
    
    self.allEventsViewController.delegate = self;
    
    self.allEventsViewController.view.frame = self.contentView.bounds;
    [self addChildViewController:self.allEventsViewController];
    [self.contentView addSubview:self.allEventsViewController.view];
    [self.allEventsViewController didMoveToParentViewController:self];
    
    //Setup Search and Filter Bar Button Items
    if (!self.isGuestUser) {
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySearchController)];
        self.navigationItem.rightBarButtonItem = searchButton;
    }
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.f", self.searchRadius] style:UIBarButtonItemStylePlain target:self action:@selector(displayFilterView)];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //See what happens without this line below ..
    [self.view setNeedsUpdateConstraints];
    
}


#pragma mark - User Actions

- (void) switchHomeTabs {
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self swapVCToIndex:0];
    } else {
        [self swapVCToIndex:1];
    }
    
}

- (void) displaySearchController {
    
    [PFAnalytics trackEventInBackground:@"SearchFeatureAccessed" block:nil];
    
    SearchVC *searchController = (SearchVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    [self.navigationController pushViewController:searchController animated:YES];
    
}

- (void) displayFilterView {
    
    [PFAnalytics trackEventInBackground:@"FilterFeatureAccessed" block:nil];
    
    FilterEventsVC *filterVC = (FilterEventsVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    filterVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    filterVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    filterVC.selectedFilterDistance = [self.navigationItem.leftBarButtonItem.title floatValue];
    filterVC.delegate = self;
    
    [self.tabBarController presentViewController:filterVC animated:YES completion:nil];
    
}

#pragma mark - Filter Delegate Methods

- (void) completedFiltering:(float)radius {
    
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    
    self.searchRadius = radius;
    
    if (radius < 1) {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.01f", self.searchRadius];
    } else {
        self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%.f", self.searchRadius];
    }
    
    //Send Out Notification that Radius Is Updated
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilterRadiusUpdate object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:radius] forKey:@"radius"]];
    
}

#pragma mark - Home Screen Delegate Methods

- (float) currentRadiusFilter {
    
    return self.searchRadius;
    
}

- (void) presentFilterView {
    
    [self displayFilterView];
    
}


#pragma mark - Helper Methods

- (void) swapVCToIndex:(int)index {
    
    self.segmentControl.selectedSegmentIndex = index;
    
    if (index == 0) {
        
        [self moveFromVC:self.friendsViewController toVC:self.allEventsViewController];

    } else if (index == 1) {
        
        [self moveFromVC:self.allEventsViewController toVC:self.friendsViewController];

    }
    
}


- (void) moveFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC {
    
    [fromVC willMoveToParentViewController:nil];
    [self addChildViewController:toVC];
    
    toVC.view.frame = self.contentView.bounds;
    
    [self.contentView addSubview:toVC.view];
    
    [fromVC.view removeFromSuperview];
    [fromVC removeFromParentViewController];
    [toVC didMoveToParentViewController:self];
    
}





@end
