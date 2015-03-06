//
//  AddEventSecondVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EVNConstants.h"
#import "LocationSearchVC.h"


@protocol EventCreationCompleted;

@interface AddEventSecondVC : UITableViewController <UITextViewDelegate, EventLocationSearch>

@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, assign) int eventType;
@property (nonatomic, strong) PFFile *eventCoverImage;

@property (nonatomic, strong) id <EventCreationCompleted> delegate;

@end

@protocol EventCreationCompleted <NSObject>

- (void) eventCreationComplete:(UIVisualEffectView *)darkBlur;
- (void) eventCreationCanceled;

@end