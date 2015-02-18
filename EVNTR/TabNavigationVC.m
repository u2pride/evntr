//
//  TabNavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "TabNavigationVC.h"
#import "AppDelegate.h"

@interface TabNavigationVC ()

@property (strong, nonatomic) UITabBarItem *activityItem;

@end

@implementation TabNavigationVC

@synthesize activityItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActivity:) name:@"newActivityNotifications" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) newActivity:(NSNotification *)notification {
    NSLog(@"YAY");
    
    NSDictionary *notificationDictionary = notification.userInfo;
    
    NSNumber *num = [notificationDictionary objectForKey:@"numberOfNotifications"];
    
    
    UINavigationController *navController = (UINavigationController *)[self.childViewControllers objectAtIndex:3];
        
    self.activityItem = navController.tabBarItem;
    
    self.activityItem.badgeValue = [NSString stringWithFormat:@"%@", num];
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    /*

    UINavigationController *navController = (UINavigationController *)[self.childViewControllers objectAtIndex:3];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    NSLog(@"viewDidLoad for tabNavigation");
    
    self.activityItem = navController.tabBarItem;
    
    NSLog(@"Activity Item: %@", activityItem);
    
 */
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
