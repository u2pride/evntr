//
//  InitialScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInVC.h"
#import "SignUpVC.h"
#import "NewUserFacebookVC.h"

@interface InitialScreenVC : UIViewController <NewUserFacebookDelegate, NewUserFacebookSignUpDelegate>

- (IBAction)loginButtonTouchDownTrial:(id)sender;
- (IBAction)loginButtonTouchUpInsideExample:(id)sender;
@end
