//
//  SignUpVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNLoginBaseVC.h"
#import <UIKit/UIKit.h>

@interface SignUpVC : EVNLoginBaseVC <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (IBAction)signUp:(id)sender;

@end


