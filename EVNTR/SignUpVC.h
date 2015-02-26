//
//  SignUpVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol NewUserFacebookSignUpDelegate;

#import <UIKit/UIKit.h>

@interface SignUpVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<NewUserFacebookSignUpDelegate> delegate;

- (IBAction)signUp:(id)sender;

@end

@protocol NewUserFacebookSignUpDelegate <NSObject>

- (void) createFBRegisterVCWithDetailsFromSignUp:(NSDictionary *) userDetailsFromFB;

@end