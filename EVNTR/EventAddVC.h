//
//  EventAddVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventAddVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *eventTitleField;
@property (nonatomic, strong) IBOutlet UITextField *eventDescriptionField;
@property (nonatomic, strong) IBOutlet UITextField *eventAttendersField;

- (IBAction)createEvent:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)selectCoverPhoto:(id)sender;

@end
