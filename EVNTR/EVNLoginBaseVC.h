//
//  EVNLoginBaseVC.h
//  EVNTR
//
//  Created by Alex Ryan on 7/7/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVNLoginBaseVC : UIViewController

@property (nonatomic) BOOL viewIsPulledUpForTextInput;


- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance;
- (void) blurViewDuringLoginWithMessage:(NSString *)message;
- (void) cleanUpBeforeTransition;

@end
