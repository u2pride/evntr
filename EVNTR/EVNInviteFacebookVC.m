//
//  EVNInviteFacebookVC.m
//  EVNTR
//
//  Created by Alex Ryan on 7/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteFacebookVC.h"
#import "EVNNoResultsView.h"

@interface EVNInviteFacebookVC ()

@property (nonatomic, strong) EVNNoResultsView *inviteFacebookFriendsView;

@end

@implementation EVNInviteFacebookVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inviteFacebookFriendsView.frame = self.view.bounds;
    
    self.inviteFacebookFriendsView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
    self.inviteFacebookFriendsView.offsetY = 100;
    self.inviteFacebookFriendsView.headerText = @"Invite FB Friends";
    self.inviteFacebookFriendsView.subHeaderText = @"Send an invite to Evntr to some of your friends on Facebook!";
    self.inviteFacebookFriendsView.actionButton.titleText = @"Send Invites";
    [self.inviteFacebookFriendsView.actionButton addTarget:self action:@selector(openFacebookInvite) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.inviteFacebookFriendsView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.view setNeedsUpdateConstraints];
    
}


- (void) openFacebookInvite {
    
    FBSDKAppInviteContent *fbInviteContent = [[FBSDKAppInviteContent alloc] init];
    
    fbInviteContent.appLinkURL = [NSURL URLWithString:@"https://fb.me/1079180432111102"];
    fbInviteContent.appInvitePreviewImageURL = [NSURL URLWithString:@"https://runningforthewind.files.wordpress.com/2013/07/partii-opener.jpg"];
    
    [FBSDKAppInviteDialog showWithContent:fbInviteContent delegate:self];
    
    
}

#pragma mark - FB Invite Delegate Methods

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
    NSLog(@"Success");
    
    UIAlertController *successVerification = [UIAlertController alertControllerWithTitle:@"Invites Sent" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:successVerification animated:YES completion:^{
        
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        });
        
    }];
    
}

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    
    NSLog(@"Failure");
    
    UIAlertController *failureVerification = [UIAlertController alertControllerWithTitle:@"Invites Failed to Send" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:failureVerification animated:YES completion:^{
        
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        });
        
    }];
    
}

@end
