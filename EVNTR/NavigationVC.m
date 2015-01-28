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

@interface NavigationVC ()

@end

@implementation NavigationVC {
    NSArray *menuItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menuItems = @[@"title", @"home", @"profile", @"settings"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ViewMyProfileFromNavigation"]) {
        UINavigationController *navigationControllerForProfileView = (UINavigationController *)[segue destinationViewController];
        
        ProfileVC *profileViewController = (ProfileVC *)[[navigationControllerForProfileView childViewControllers] firstObject];
        profileViewController.userNameForProfileView = [PFUser currentUser][@"username"];
    } else if ([[segue identifier] isEqualToString:@"HomeViewFromNavigation"]) {
        
    }
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
