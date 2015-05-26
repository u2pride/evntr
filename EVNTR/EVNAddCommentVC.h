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

@property (nonatomic, weak) id <EVNAddCommentProtocol> delegate;

@end

@protocol EVNAddCommentProtocol <NSObject>

- (void) submitCommentWithText:(NSString *)commentString;
- (void) cancelComment;

@end
