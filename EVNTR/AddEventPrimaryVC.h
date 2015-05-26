//
//  AddEventPrimaryVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventSecondVC.h"
#import "EVNConstants.h"
#import "EventObject.h"

#import <UIKit/UIKit.h>

@protocol EventModalProtocol;

@interface AddEventPrimaryVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, EventCreationCompleted>

@property (nonatomic, strong) id <EventModalProtocol> delegate;
@property (nonatomic, strong) EventObject *eventToEdit;

@end

@protocol EventModalProtocol <NSObject>

@optional
- (void) completedEventCreation:(UIVisualEffectView *)darkBlur withEvent:(EventObject *)event;
- (void) canceledEventCreation;

- (void) completedEventEditing:(EventObject *)updatedEvent;
- (void) canceledEventEditing;


@end
