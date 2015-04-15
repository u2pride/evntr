//
//  EVNAddCommentVC.h
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol EVNAddCommentProtocol;

@interface EVNAddCommentVC : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) id <EVNAddCommentProtocol> delegate;

@end

@protocol EVNAddCommentProtocol <NSObject>

- (void) cancelComment;
- (void) submitCommentWithText:(NSString *)commentString;

@end
