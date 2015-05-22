//
//  TabNavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "ActivityVC.h"
#import "AppDelegate.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "HomeScreenVC.h"
#import "IDTransitionControllerTab.h"
#import "ProfileVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface TabNavigationVC ()

@property (nonatomic) BOOL isGuestUser;

@property (nonatomic, strong) UIVisualEffectView *darkBlur;
@property (nonatomic, strong) IDTransitionControllerTab *transitionController;
@property (strong, nonatomic) UITabBarItem *activityItem;

@end


@implementation TabNavigationVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.transitionController = [[IDTransitionControllerTab alloc] init];
    
    //UI Updates to Tab & Navigation Bar
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor orangeThemeColor];
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBar.translucent = NO;
    
    //UI Updates to Nav Bars
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    for (UINavigationController *navController in self.viewControllers) {
        navController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        navController.navigationBar.translucent = NO;
        
        //Set Font Color to White
        [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }


    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    if (self.isGuestUser) {
        
        NSMutableArray *viewControllersTab = [NSMutableArray arrayWithArray:[self viewControllers]];
        [viewControllersTab removeObjectAtIndex:3];
        
        [self setViewControllers:viewControllersTab];
        
        [[self.tabBar.items objectAtIndex:1] setEnabled:NO];
        [[self.tabBar.items objectAtIndex:2] setEnabled:NO];
        
    } else {
        
        //Enable Background Fetching - User Is Logged In
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
        
        NSMutableArray *viewControllersTab = [NSMutableArray arrayWithArray:[self viewControllers]];
        [viewControllersTab removeObjectAtIndex:4];

        [self setViewControllers:viewControllersTab];
        
    }
    
}



#pragma mark - Delegate Methods for Tab Bar Controller

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    //Events View Controller
    if (viewController == [self.viewControllers objectAtIndex:0]) {
        
        UINavigationController *navVC = (UINavigationController *) self.viewControllers.firstObject;
        HomeScreenVC *eventsView = navVC.childViewControllers.firstObject;
        
        eventsView.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        eventsView.userForEventsQuery = [EVNUser currentUser];
        

    //Add Event VC
    } else if (viewController == [self.viewControllers objectAtIndex:1] && !self.isGuestUser) {
        
        UINavigationController *navController = (UINavigationController *)viewController;
        
        AddEventPrimaryVC *addEventModal = (AddEventPrimaryVC *)navController.childViewControllers.firstObject;
        addEventModal.delegate = self;
    
    //Activity VC
    } else if (viewController == [self.viewControllers objectAtIndex:2] && !self.isGuestUser) {
        
        UINavigationController *navVC = (UINavigationController *) viewController;
        [navVC popToRootViewControllerAnimated:NO];
        
        ActivityVC *activityVC = (ActivityVC *)navVC.childViewControllers.firstObject;
        activityVC.userForActivities = [EVNUser currentUser];
        activityVC.typeOfActivityView = ACTIVITIES_ALL;
        
    //Profile VC
    } else if (viewController == [self.viewControllers objectAtIndex:3] && !self.isGuestUser) {
    
        UINavigationController *navVC = (UINavigationController *) viewController;
        [navVC popToRootViewControllerAnimated:NO];
        
        ProfileVC *profileView = navVC.childViewControllers.firstObject;
        profileView.userObjectID = [EVNUser currentUser].objectId;
        profileView.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    }
    
    
}


#pragma mark - Programmatically Selecting Add New Event
- (void) selectCreateTab {
    
    [self setSelectedIndex:1];
    
    UINavigationController *navController = (UINavigationController *)self.selectedViewController;
    AddEventPrimaryVC *addEventModal = (AddEventPrimaryVC *)navController.childViewControllers.firstObject;
    addEventModal.delegate = self;
    
}

- (NSString *)viewControllerNameForIndex:(int)indexValue {
    
    switch (indexValue) {
        case TAB_HOME: {
            return @"Home";
            break;
        }
        case TAB_CREATE: {
            return @"Create";
            break;
        }
        case TAB_ACTIVITY: {
            return @"Notifcations";
            break;
        }
        case TAB_PROFILE: {
            return @"Profile";
            break;
        }
        default:
            return @"Unknown";
            break;
    }
    
}


#pragma mark - Custom Tab Switch Animation - Create Event

- (id<UIViewControllerAnimatedTransitioning>) tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
    NSString *fromVCName = [self viewControllerNameForIndex:(int)fromVCIndex];
    NSString *toVCName = [self viewControllerNameForIndex:(int)toVCIndex];
    
    NSDictionary *dimensions = @{
                                 @"InitialTab": fromVCName,
                                 @"FinalTab": toVCName,
                                 };
    
    [PFAnalytics trackEventInBackground:@"NavigationPatterns" dimensions:dimensions block:nil];
    
    
    if (toVCIndex == TAB_CREATE) {
        self.transitionController.isPresenting = YES;
        return self.transitionController;
    } else if (fromVCIndex == TAB_CREATE) {
        self.transitionController.isPresenting = NO;
        return self.transitionController;
    }
    
    return nil;
    
}



#pragma mark - AddEventModal Delegate Methods

- (void) completedEventCreation:(UIVisualEffectView *)darkBlur withEvent:(EventObject *)event {
    
    self.darkBlur = darkBlur;
    [self.darkBlur removeFromSuperview];
    
    //Scroll TableView to Top and Refresh Results to Show Most Recently Created Event
    UINavigationController *navController = (UINavigationController *) [self.viewControllers objectAtIndex:TAB_HOME];
    HomeScreenVC *allEventsVC = (HomeScreenVC *) navController.childViewControllers.firstObject;
    
    [navController popToRootViewControllerAnimated:YES];
    
    allEventsVC.tableView.contentOffset = CGPointMake(0, 0 - allEventsVC.tableView.contentInset.top);
    
    [allEventsVC loadObjects];
    
    [self setSelectedIndex:0];
    
    [allEventsVC inviteUsersToEvent:event];
    
    
}

- (void) canceledEventCreation {
    
    UINavigationController *navController = (UINavigationController *) [self.viewControllers objectAtIndex:TAB_HOME];

    [navController popToRootViewControllerAnimated:YES];
    
    [self setSelectedIndex:0];
    
}

 
@end
