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

- (IBAction)submitFeedback:(id)sender {
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
   
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:@"Evntr App Feedback"];
    [mailVC setToRecipients:@[@"aryan@evntr.co"]];
    [mailVC setCcRecipients:@[@"kjaved@evntr.co"]];
    
    [self presentViewController:mailVC animated:YES completion:nil];
    
}

#pragma mark - MFMailViewController Delegate Methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    }];
    
    
}



@end
