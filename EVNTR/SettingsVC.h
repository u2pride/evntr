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

@end
