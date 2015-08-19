//
//  SettingsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "Amplitude/Amplitude.h"
#import "EVNFullWebViewController.h"
#import "EVNUser.h"
#import "ProfileVC.h"
#import "SettingsVC.h"

#import <Parse/Parse.h>

@import Social;

@interface SettingsVC ()

@end

@implementation SettingsVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}


#pragma mark - User Actions

- (IBAction)logOut:(id)sender {
    
    [[Amplitude instance] logEvent:@"Logged Out"];
    
    [EVNUser logOut];
    
    //Disable Background Fetch - User Logged Out
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalNever];
    [self performSegueWithIdentifier:@"SettingsToInitialScreen" sender:self];
    
}

- (IBAction)tweetEvntr:(id)sender {
    
    [[Amplitude instance] logEvent:@"Selected Tweet"];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *twitterVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterVC setInitialText:@"@EvntrApp "];
        
        [self presentViewController:twitterVC animated:YES completion:nil];
        
    } else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Twitter Account" message:@"To tweet, make sure to setup Twitter in your iPhone settings.  Click on Settings, back out one page, then look for Twitter." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
        
        [errorAlert addButtonWithTitle:@"Settings"];
        [errorAlert show];
        
    }
    
}

- (IBAction)emailEvntr:(id)sender {
    
    [[Amplitude instance] logEvent:@"Selected Email"];
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:@"Feedback - Evntr"];
    [mailVC setToRecipients:@[@"aryan@evntr.co"]];
    [mailVC setCcRecipients:@[@"kjaved@evntr.co", @"mfisher@evntr.co"]];
    
    [self presentViewController:mailVC animated:YES completion:^{
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
    }];
    
}

- (IBAction)viewTerms:(id)sender {
    
    [[Amplitude instance] logEvent:@"Selected Terms"];
    
    EVNFullWebViewController *termsWeb = [[EVNFullWebViewController alloc] init];
    
    [self.navigationController pushViewController:termsWeb animated:YES];
    
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    }
    
}


#pragma mark - MFMailViewController Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    }];
    
}


@end
