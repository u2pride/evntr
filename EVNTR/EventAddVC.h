//
//  EventAddVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface EventAddVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *eventTitleField;
@property (nonatomic, strong) IBOutlet UITextField *eventDescriptionField;
@property (nonatomic, strong) IBOutlet UITextField *eventAttendersField;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationText;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;

- (IBAction)createEvent:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)selectCoverPhoto:(id)sender;
- (IBAction)setEventLocation:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;

@end
