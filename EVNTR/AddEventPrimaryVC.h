//
//  AddEventPrimaryVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVNConstants.h"
#import "AddEventSecondaryVC.h"

@protocol EventModalProtocol;

@interface AddEventPrimaryVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, EventCreationCompleted>

@property (nonatomic, strong) id <EventModalProtocol> delegate;

@end

@protocol EventModalProtocol <NSObject>

- (void) completedEventCreation:(UIVisualEffectView *)darkBlur;
- (void) canceledEventCreation;

@end
