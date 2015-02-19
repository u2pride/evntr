//
//  TabNavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "TabNavigationVC.h"
#import "HomeScreenVC.h"
#import "ProfileVC.h"
#import "EVNConstants.h"
#import "AppDelegate.h"

@interface TabNavigationVC ()

@property (strong, nonatomic) UITabBarItem *activityItem;

@end

@implementation TabNavigationVC

@synthesize activityItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActivity:) name:@"newActivityNotifications" object:nil];
    
    //Should we register for the notification on the user returning to the app? maybe if we used userprefs to store new activity count. but not with other notificaiton.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name: UIApplicationWillEnterForegroundNotification object:nil];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Update Activity Badge - From Background Fetch
- (void) newActivity:(NSNotification *)notification {
    
    NSDictionary *notificationDictionary = notification.userInfo;
    NSNumber *num = [notificationDictionary objectForKey:@"numberOfNotifications"];
    
    UINavigationController *navController = (UINavigationController *)[self.childViewControllers objectAtIndex:3];
    self.activityItem = navController.tabBarItem;
    
    self.activityItem.badgeValue = [NSString stringWithFormat:@"%@", num];
    
}


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
    } else if (viewController == [self.viewControllers objectAtIndex:4]) {
        
        UINavigationController *navVC = (UINavigationController *) self.viewControllers.lastObject;
        ProfileVC *profileView = navVC.childViewControllers.firstObject;
        
        profileView.userNameForProfileView = [[PFUser currentUser] objectForKey:@"username"];
    }
}

    /*
    
    //TODO - revisit. why am I doing this?
    NSLog(@"View Controller Selected: %@", viewController);
    
    if (self.viewControllers.firstObject == viewController) {
        NSLog(@"This Worked");
        
        UINavigationController *navigationController = (UINavigationController *)self.viewControllers.firstObject;
        HomeScreenVC *homeScreenEventsView = navigationController.childViewControllers.firstObject;
        
        homeScreenEventsView.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        homeScreenEventsView.userForEventsQuery = [PFUser currentUser];
        
    } else if (self.viewControllers.lastObject == viewController) {
        NSLog(@"This is the People VC");
        
        UINavigationController *navigationController = (UINavigationController *)self.viewControllers.lastObject;
        
        PeopleVC *peopleViewController = navigationController.childViewControllers.lastObject;
        peopleViewController.typeOfUsers = VIEW_ALL_PEOPLE;
        peopleViewController.profileUsername = [PFUser currentUser];
        
        //Ehhh.  Doing this to make sure ViewWillAppear is called After Setting properties on the People VC
        [peopleViewController viewWillAppear:YES];
        
        
    }
    */



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
