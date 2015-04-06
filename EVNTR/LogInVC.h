//
//  LogInVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol NewUserFacebookDelegate;

#import <UIKit/UIKit.h>
#import "ResetPasswordModalVC.h"

@interface LogInVC : UIViewController <ResetPasswordDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<NewUserFacebookDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;

@end


@protocol NewUserFacebookDelegate <NSObject>

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB;

@end

