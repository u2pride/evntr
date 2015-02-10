//
//  HomeTabsController.m
//  EVNTR
//
//  Created by Alex Ryan on 1/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "HomeTabsController.h"
#import "PeopleVC.h"
#import "HomeScreenVC.h"
#import "EVNConstants.h"

@implementation HomeTabsController


- (void) viewDidLoad {
    self.delegate = self;
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
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
    
}


@end
