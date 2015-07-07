//
//  NewUserFacebookVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNLoginBaseVC.h"
#import <UIKit/UIKit.h>

@interface NewUserFacebookVC : EVNLoginBaseVC <UITextFieldDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSDictionary *informationFromFB;

@end