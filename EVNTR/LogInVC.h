//
//  LogInVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNLoginBaseVC.h"
#import "ResetPasswordModalVC.h"

#import <UIKit/UIKit.h>

@interface LogInVC : EVNLoginBaseVC <ResetPasswordDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;

@end




