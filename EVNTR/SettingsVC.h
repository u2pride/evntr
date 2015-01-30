//
//  SettingsVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsVC : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

- (IBAction)logOut:(id)sender;

- (IBAction)evntr1Profile:(id)sender;
- (IBAction)envtr2Profile:(id)sender;
- (IBAction)evntr3Profile:(id)sender;
- (IBAction)evntr4Profile:(id)sender;

@end
