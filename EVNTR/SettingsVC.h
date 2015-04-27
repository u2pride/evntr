//
//  SettingsVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;


@interface SettingsVC : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

- (IBAction)logOut:(id)sender;
- (IBAction)submitFeedback:(id)sender;
- (IBAction)tweetEvntr:(id)sender;

@end
