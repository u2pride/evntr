//
//  EVNInviteContactsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNInviteContactsVC.h"
#import <Parse/Parse.h>

@interface EVNInviteContactsVC ()

@property (nonatomic, strong) EVNNoResultsView *messageFriendsView;

@end

@implementation EVNInviteContactsVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.messageFriendsView = [self.delegate messageViewToDisplay];
    
    /*
    self.messageFriendsView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
    self.messageFriendsView.headerText = @"Text A Friend";
    self.messageFriendsView.subHeaderText = @"Click to text your friends an app store link for Evntr.";
    self.messageFriendsView.actionButton.titleText = @"Message";
    
    self.messageFriendsView.offsetY = 100;

    [self.messageFriendsView.actionButton addTarget:self action:@selector(sendInviteMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.messageFriendsView];
    */
    
    self.messageFriendsView = [self.delegate messageViewWithSelector:@selector(sendInviteMessage) andSender:self];
    
    [self.view addSubview:self.messageFriendsView];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.view setNeedsUpdateConstraints];
    
}




#pragma mark - User Actions

- (void) sendInviteMessage {
    
    [self.messageFriendsView.actionButton startedTask];
    
    [PFAnalytics trackEventInBackground:@"SendingTextMessage" block:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.amplitudeInstance logEvent:@"SendingTextMessage"];
    
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        
        messageVC.body = @"I just discovered Evntr! \U0001F525 Check it out and get a live feed of what everyone is doing around you.  https://appsto.re/us/AFfm6.i";
        messageVC.messageComposeDelegate = self;
        
        [self presentViewController:messageVC animated:YES completion:^{
            
            [self.messageFriendsView.actionButton endedTask];
            
        }];
    
    }
    
}



#pragma mark - MFMessageCompose Delegate

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (result == MessageComposeResultSent) {
            
            UIAlertController *sentVerification = [UIAlertController alertControllerWithTitle:@"Message Sent" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:sentVerification animated:YES completion:^{
                
                double delayInSeconds = 0.75;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                });
                
            }];
            
        } else if (result == MessageComposeResultCancelled) {
            
            
            UIAlertController *sentFailure = [UIAlertController alertControllerWithTitle:@"Message Cancelled" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:sentFailure animated:YES completion:^{
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                });
                
            }];
            
        } else {
            
            UIAlertController *sentFailure = [UIAlertController alertControllerWithTitle:@"Failed To Send Message" message:@"Try Again" preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:sentFailure animated:YES completion:^{
                
                double delayInSeconds = 1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                });
                
            }];
            
        }
        
    }];
    
}



@end
