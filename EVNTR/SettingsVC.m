//
//  SettingsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SettingsVC.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import "ProfileVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"logOutToMain" sender:self];
    
    
}

- (IBAction)envtr2Profile:(id)sender {
    
    //create profile vc
    //pop onto stack
    
    ProfileVC *newUserProfileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    newUserProfileVC.userNameForProfileView = @"EVNTR2";
    
    [self.navigationController pushViewController:newUserProfileVC animated:YES];
    
    
}


@end
