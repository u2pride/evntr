//
//  NavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "NavigationVC.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import "ProfileVC.h"
#import "HomeScreenVC.h"
#import "EVNConstants.h"
#import "CellWithBadge.h"
#import "EVNConstants.h"

@interface NavigationVC ()

@property (weak, nonatomic) IBOutlet CellWithBadge *activityCellWithBadge;

@end

@implementation NavigationVC {
    NSArray *menuItems;
}

@synthesize activityCellWithBadge;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menuItems = @[@"title", @"home", @"profile", @"activity", @"settings"];
    
    //Update the Badge for Number of Invitations
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFQuery *queryForInvites = [PFQuery queryWithClassName:@"Activities"];
        [queryForInvites whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
        [queryForInvites whereKey:@"to" equalTo:[PFUser currentUser]];
        activityCellWithBadge.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)[queryForInvites countObjects]];
        
        
    });
    */
    
    //Register for Notifications so you can update the badge on the navigation menu - necessary?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name: UIApplicationWillEnterForegroundNotification object:nil];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [self updateNavigationMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refresh:(id)sender {
    [self updateNavigationMenu];
}


- (void)updateNavigationMenu {
    
    NSLog(@"keyfornotificationcount = %@", kNumberOfNotifications);
    
    //New code
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *numNotifications = [standardDefaults objectForKey:kNumberOfNotifications];
    activityCellWithBadge.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)numNotifications.integerValue];
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ViewMyProfileFromNavigation"]) {
        UINavigationController *navigationControllerForProfileView = (UINavigationController *)[segue destinationViewController];
        
        ProfileVC *profileViewController = (ProfileVC *)[navigationControllerForProfileView topViewController];
        profileViewController.userNameForProfileView = [[PFUser currentUser] objectForKey:@"username"];
        profileViewController.isComingFromNavigation = YES;
        
        
    } else if ([[segue identifier] isEqualToString:@"HomeViewFromNavigation"]) {
        
        UITabBarController *tabBarController = segue.destinationViewController;
        [tabBarController setSelectedIndex:0];
        UINavigationController *navController = [tabBarController.viewControllers objectAtIndex:0];
        HomeScreenVC *homeScreenVC = [navController.viewControllers objectAtIndex:0];
        
        homeScreenVC.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        homeScreenVC.userForEventsQuery = [PFUser currentUser];
        homeScreenVC.isComingFromNavigation = YES;
        
        //not sure if I need this.
        //[homeScreenVC viewWillAppear:YES];
        
    } else {
        
    }
    
}


@end
