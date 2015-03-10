//
//  TabNavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNConstants.h"
#import "HomeScreenVC.h"
#import "IDTransitionControllerTab.h"
#import "IDTransitioningDelegate.h"
#import "ProfileVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface TabNavigationVC ()

@property BOOL isGuestUser;

@property (nonatomic, strong) UIVisualEffectView *darkBlur;
@property (nonatomic, strong) IDTransitionControllerTab *transitionController;
@property (strong, nonatomic) UITabBarItem *activityItem;

@end


@implementation TabNavigationVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transitionController = [[IDTransitionControllerTab alloc] init];
    self.delegate = self;
    

    //Determine If Guest User
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActivity:) name:@"newActivityNotifications" object:nil];
    //Should we register for the notification on the user returning to the app? maybe if we used userprefs to store new activity count. but not with other notificaiton.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name: UIApplicationWillEnterForegroundNotification object:nil];

    //Enable/Disable Tabs Based on isGuestUser
    if (self.isGuestUser) {
        
        //remember you have to initialize the nsmutablearay. ie viewControllersTab = self.tabBarController.viewControllers won't work.
        NSMutableArray *viewControllersTab = [NSMutableArray arrayWithArray:[self viewControllers]];
        [viewControllersTab removeObjectAtIndex:3];
        
        [self setViewControllers:viewControllersTab];
        
        [[self.tabBar.items objectAtIndex:1] setEnabled:NO];
        [[self.tabBar.items objectAtIndex:2] setEnabled:NO];
        
    } else {
        
        NSMutableArray *viewControllersTab = [NSMutableArray arrayWithArray:[self viewControllers]];
        [viewControllersTab removeObjectAtIndex:4];

        [self setViewControllers:viewControllersTab];
        
    }
    
    //UI Updates to Navigation and Tab Bars
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    for (UINavigationController *navController in self.viewControllers) {
        navController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        navController.navigationBar.translucent = YES;
        
        //Set Font Color to White
        [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
    }
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor orangeThemeColor];
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBar.translucent = YES;
    
}


#pragma mark - Notification Response - Update Badge of Activity Tab
- (void) newActivity:(NSNotification *)notification {
    
    NSDictionary *notificationDictionary = notification.userInfo;
    NSNumber *num = [notificationDictionary objectForKey:@"numberOfNotifications"];
    
    UINavigationController *navController = (UINavigationController *)[self.childViewControllers objectAtIndex:2];
    self.activityItem = navController.tabBarItem;
    
    self.activityItem.badgeValue = [NSString stringWithFormat:@"%@", num];
    
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
        eventsView.userForEventsQuery = [PFUser currentUser];
        
    //Profile VC
    } else if (viewController == [self.viewControllers objectAtIndex:3] && !self.isGuestUser) {
        
        UINavigationController *navVC = (UINavigationController *) self.viewControllers.lastObject;
        ProfileVC *profileView = navVC.childViewControllers.firstObject;
        
        profileView.userNameForProfileView = [[PFUser currentUser] objectForKey:@"username"];
    
    
    //Add Event VC
    } else if (viewController == [self.viewControllers objectAtIndex:1] && !self.isGuestUser) {
        
        UINavigationController *navController = (UINavigationController *)viewController;
        AddEventPrimaryVC *addEventModal = (AddEventPrimaryVC *)navController.childViewControllers.firstObject;
        addEventModal.delegate = self;
    }
    
}


#pragma mark - Custom Tab Switch Animation - Create Event

- (id<UIViewControllerAnimatedTransitioning>) tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    
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

- (void) completedEventCreation:(UIVisualEffectView *)darkBlur {
    
    self.darkBlur = darkBlur;
    [self.darkBlur removeFromSuperview];
    
    [self setSelectedIndex:0];
    
    
}

- (void) canceledEventCreation {
    
    [self setSelectedIndex:0];
    
}

 
@end
