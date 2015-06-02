//
//  InitialScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "LogInVC.h"
#import "NewUserFacebookVC.h"
#import "SignUpVC.h"

#import <UIKit/UIKit.h>

@interface InitialScreenVC : UIViewController <NewUserFacebookDelegate, NewUserFacebookSignUpDelegate, UIAlertViewDelegate>

@end
