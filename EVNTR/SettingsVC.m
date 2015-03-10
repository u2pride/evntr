//
//  SettingsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SettingsVC.h"
#import <Parse/Parse.h>
#import "ProfileVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Minor UI Adjustments
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
}



- (IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"SettingsToInitialScreen" sender:self];
    
    
}

- (IBAction)evntr1Profile:(id)sender {
    
    ProfileVC *newUserProfileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    newUserProfileVC.userNameForProfileView = @"EVNTR";
    
    [self.navigationController pushViewController:newUserProfileVC animated:YES];
    
}

- (IBAction)envtr2Profile:(id)sender {
    
    ProfileVC *newUserProfileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    newUserProfileVC.userNameForProfileView = @"EVNTR2";
    
    [self.navigationController pushViewController:newUserProfileVC animated:YES];
    
    
}

- (IBAction)evntr3Profile:(id)sender {
    
    ProfileVC *newUserProfileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    newUserProfileVC.userNameForProfileView = @"EVNTR3";
    
    [self.navigationController pushViewController:newUserProfileVC animated:YES];
    
}

- (IBAction)evntr4Profile:(id)sender {
    
    ProfileVC *newUserProfileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    newUserProfileVC.userNameForProfileView = @"EVNTR4";
    
    [self.navigationController pushViewController:newUserProfileVC animated:YES];
    
}


@end
