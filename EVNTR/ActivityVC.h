//
//  ActivityVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface ActivityVC : PFQueryTableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

//Add properties to enable customization.  add username and activity type parameters.

@end
