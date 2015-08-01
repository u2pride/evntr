//
//  AddEventSecondVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNLocationSearchVC.h"
#import "EventObject.h"

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@protocol EventCreationCompleted;

@interface AddEventSecondVC : UITableViewController <UITextViewDelegate, EventLocationSearch>

@property (nonatomic, strong) EventObject *event;
@property (nonatomic) BOOL isEditingEvent;

//Amplitude
@property (nonatomic, strong) NSString *typeOfPhotoUsed;

@property (nonatomic, weak) id <EventCreationCompleted> delegate;

@end


@protocol EventCreationCompleted <NSObject>

@optional
- (void) eventCreationComplete:(UIVisualEffectView *)darkBlur withEvent:(EventObject *)event;
- (void) eventCreationCanceled;

- (void) eventEditingComplete:(EventObject *)updatedEvent;
- (void) eventEditingCanceled;

@end