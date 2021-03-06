//
//  AddEventSecondVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "AddEventSecondVC.h"
#import "Amplitude/Amplitude.h"
#import "EVNButton.h"
#import "EVNLocationSearchVC.h"
#import "EVNUser.h"
#import "MBProgressHUD.h"
#import "UIColor+EVNColors.h"

@interface AddEventSecondVC ()

@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (strong, nonatomic) IBOutlet EVNButton *createButton;
@property (strong, nonatomic) IBOutlet EVNButton *setLocationButton;

- (IBAction)createEvent:(id)sender;
- (IBAction)setEventLocation:(id)sender;

@end


@implementation AddEventSecondVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Date Picker Initialization
    NSDate *today = [NSDate date];
    self.eventDatePicker.minimumDate = today;
    self.eventDatePicker.maximumDate = [today dateByAddingTimeInterval:604800]; /* One Week */
    [self.eventDatePicker addTarget:self action:@selector(newDate:) forControlEvents:UIControlEventValueChanged];

    //Event Description Setup
    self.eventDescriptionText.delegate = self;
    [self.eventDescriptionText setTextColor:[UIColor lightGrayColor]];
    
    //Button Setup
    self.createButton.titleText = @"Create Event";
    self.createButton.isRounded = NO;
    self.createButton.hasBorder = NO;
    self.createButton.font = [UIFont fontWithName:@"Lato-Bold" size:21];
    
    self.setLocationButton.isRounded = NO;
    self.setLocationButton.titleText = @"Set Location";
    self.setLocationButton.hasBorder = NO;
    [self.setLocationButton setIsSelected:NO];
    
    if (self.isEditingEvent) {
        
        [self.eventDatePicker setDate:self.event.dateOfEvent animated:YES];
        self.eventDescriptionText.text = self.event.descriptionOfEvent;
        self.eventDescriptionText.textColor = [UIColor blackColor];
        
        self.setLocationButton.titleText = self.event.nameOfLocation;
        [self.setLocationButton setIsSelected:YES];
        
        self.setLocationButton.backgroundColor = [UIColor orangeThemeColor];
        
        self.createButton.titleText = @"Update Event";
        
    } else {
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute) fromDate:today];
        
        NSInteger minutes = [components minute];
        NSInteger seconds = [components second];
        
        float totalSeconds = (60 * minutes) + seconds;
        float thirtyMinuteResult = totalSeconds / 1800.0f;
        float roundedThirty = ceilf(thirtyMinuteResult);
        float addedSeconds = (roundedThirty * 1800.0f) - totalSeconds;
        
        NSDate *newDate = [today dateByAddingTimeInterval:addedSeconds];

        self.event.dateOfEvent = newDate;
        self.eventDescriptionText.text = @"Add details about your event...";
        
    }
    
}


#pragma mark - Create Event Button

- (IBAction)createEvent:(id)sender {
    
    if (self.event.descriptionOfEvent && self.event.nameOfLocation) {
        
        if (self.isEditingEvent) {
            
            //TODO: Only Save Image if It Has Been Changed
            [self.event.coverPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    self.event[@"coverPhoto"] = self.event.coverPhoto;
                    
                    //Now Save Event to Parse
                    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                                                        
                            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                            MBProgressHUD *HUD = [[MBProgressHUD alloc] init];
                            HUD.center = window.center;
                            HUD.dimBackground = YES;
                            [window addSubview:HUD];
                            HUD.labelText = @"Updating Event";
                            [HUD show:YES];
                            
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                                [self.navigationController popViewControllerAnimated:YES];
                                
                                id<EventCreationCompleted> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(eventEditingComplete:)]) {
                                    
                                    [strongDelegate eventEditingComplete:self.event];
                                }
                                
                                [HUD hide:YES afterDelay:0.5];
                                
                            });
                            
                        } else {
                            
                            //TODO: Test by changing to if(!succeeded)

                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"We had trouble updating your cover photo." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                            
                            [errorAlert show];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                            
                            id<EventCreationCompleted> strongDelegate = self.delegate;
                            
                            if ([strongDelegate respondsToSelector:@selector(eventEditingCanceled)]) {
                                
                                [strongDelegate eventEditingCanceled];
                            }
                        }
                        
                    }];
                    
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"We had trouble saving the image you chose for the cover photo." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                    id<EventCreationCompleted> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(eventEditingCanceled)]) {
                        
                        [strongDelegate eventEditingCanceled];
                    }
                }
            }];

        } else {
            
            self.event[@"parent"] = [EVNUser currentUser];

            //Transition Blur
            UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *darkBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
            darkBlurEffectView.alpha = 0;
            darkBlurEffectView.frame = [UIScreen mainScreen].bounds;
            [self.navigationController.view addSubview:darkBlurEffectView];
            
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            [vibrancyEffectView setFrame:self.view.bounds];
            
            [[darkBlurEffectView contentView] addSubview:vibrancyEffectView];
            
            UILabel *savingEvent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
            savingEvent.text = @"Creating your event...";
            savingEvent.textColor = [UIColor whiteColor];
            savingEvent.textAlignment = NSTextAlignmentCenter;
            savingEvent.font = [UIFont fontWithName:EVNFontRegular size:27];
            savingEvent.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
            [[darkBlurEffectView contentView] addSubview:savingEvent];
            
            [UIView animateWithDuration:3.0 animations:^{
                darkBlurEffectView.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                [self.event.coverPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (succeeded) {
                                
                                int days = 0;
                                NSTimeInterval daysOut = [self.event.dateOfEvent timeIntervalSinceDate:[NSDate date]];
                                days = round( daysOut/ 86400 );
                                
                                NSMutableDictionary *eventprops = [NSMutableDictionary new];
                                
                                if (self.typeOfPhotoUsed && self.event.typeOfEvent) {
                                    
                                    [eventprops setObject:self.typeOfPhotoUsed forKey:@"Picture Type"];
                                    [eventprops setObject:self.event.typeOfEvent forKey:@"Event Type"];
                                    [eventprops setObject:[NSNumber numberWithInt:days] forKey:@"Days Out"];
                                    
                                }
                            
                                [[Amplitude instance] logEvent:@"Event Created" withEventProperties:eventprops];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kUserCreatedNewEvent object:nil userInfo:nil];
                                
                                [self.navigationController popViewControllerAnimated:NO];
                                
                                id<EventCreationCompleted> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(eventCreationComplete:withEvent:)]) {
                                    
                                    [strongDelegate eventCreationComplete:darkBlurEffectView withEvent:self.event];
                                }
                                
                            } else {
                                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"We had trouble creating your event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                                
                                [errorAlert show];
                                
                                [self.navigationController popViewControllerAnimated:NO];
                                
                                id<EventCreationCompleted> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(eventCreationCanceled)]) {
                                    
                                    [strongDelegate eventCreationCanceled];
                                }
                            }
                            
                        }];
                        
                    } else {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"We had trouble saving your event cover image" delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                        
                        [errorAlert show];
                        
                        id<EventCreationCompleted> strongDelegate = self.delegate;
                        
                        if ([strongDelegate respondsToSelector:@selector(eventCreationCanceled)]) {
                            
                            [strongDelegate eventCreationCanceled];
                        }
                        
                    }
                    
                }];
                
            }];
            
        }
        
    } else  {
        
        if (!self.event.descriptionOfEvent) {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Details Missing" message:@"Make sure to add a description to your event." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [self.createButton setIsSelected:NO];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Details Missing" message:@"Make sure to pick an event location." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [self.createButton setIsSelected:NO];
            
        }
        

    }
    
    
    
}


#pragma mark - User Actions

- (IBAction)setEventLocation:(id)sender {
    
    [self performSegueWithIdentifier:@"PresentLocationSearch" sender:nil];

}



#pragma mark - Location Search Delegate Methods

- (void) locationSearchDidCancel {
    
    if ([self.setLocationButton.titleText isEqualToString:@"Set Location"]) {
        [self.setLocationButton setIsSelected:NO];
    } else {
        [self.setLocationButton setIsSelected:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void) locationSelectedWithCoordinates:(CLLocation *)location andName:(NSString *)name {
    
    self.event.locationOfEvent = [PFGeoPoint geoPointWithLocation:location];
    self.event.nameOfLocation = name;
    
    [self.setLocationButton setIsSelected:YES];    
    self.setLocationButton.titleText = name;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Date Picker & TextView Delegates

- (void) newDate:(id)sender {
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.event.dateOfEvent = datePicker.date;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Add details about your event..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    [textView becomeFirstResponder];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add details about your event...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    
    if (textView.text.length > MAX_EVENTDESCR_LENGTH) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Description"
                                                                       message:@"Please use a shorter event description. Ever heard of KISS?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"C'mon" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              
                                                                  [textView becomeFirstResponder];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        self.event.descriptionOfEvent = textView.text;
        [textView resignFirstResponder];
    }
    

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (void)tapToDismissKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Table View Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - Tableview UIScrollView Delegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *navController = (UINavigationController *) [segue destinationViewController];
    
    EVNLocationSearchVC *locationSearch = [navController.viewControllers objectAtIndex:0];
    
    locationSearch.delegate = self;
    
}




@end


