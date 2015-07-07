//
//  EVNLoginBaseVC.h
//  EVNTR
//
//  Created by Alex Ryan on 7/7/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import <UIKit/UIKit.h>

@protocol NewUserFacebookDelegate;


@interface EVNLoginBaseVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<NewUserFacebookDelegate> delegate;
@property (nonatomic) BOOL viewIsPulledUpForTextInput;

- (void) presentImagePicker;

- (void) loginThruFacebook;
- (void) grabUserDetailsFromFacebookWithUser:(EVNUser *)newUser;

- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance;
- (void) blurViewDuringLoginWithMessage:(NSString *)message;
- (void) cleanUpBeforeTransition;

@end


@protocol NewUserFacebookDelegate <NSObject>

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB;

@end