//
//  ResetPasswordModalVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol ResetPasswordDelegate;


#import <UIKit/UIKit.h>

@interface ResetPasswordModalVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<ResetPasswordDelegate> delegate;

@end

@protocol ResetPasswordDelegate <NSObject>

-(void)resetPasswordSuccess;
-(void)resetPasswordFailed;
-(void)resetPasswordCanceled;

@end