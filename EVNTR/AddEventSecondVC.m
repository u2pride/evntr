//
//  AddEventSecondVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventSecondVC.h"
#import "LocationSearchVC.h"
#import "EVNButton.h"
#import "EVNUser.h"
#import "UIColor+EVNColors.h"
#import "EVNLocationButton.h"
#import "MBProgressHUD.h"
#import "EVNUser.h"

@interface AddEventSecondVC ()

@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (strong, nonatomic) IBOutlet EVNButton *createButton;
@property (strong, nonatomic) IBOutlet EVNButton *setLocationButton;

@property (nonatomic, strong) UIView *tapToDismissView;

- (IBAction)createEvent:(id)sender;
- (IBAction)setEventLocation:(id)sender;

@end


@implementation AddEventSecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Subscribe to Date Picker Changes
    [self.eventDatePicker addTarget:self action:@selector(newDate:) forControlEvents:UIControlEventValueChanged];
    
    NSDate *today = [NSDate date];
    self.eventDatePicker.minimumDate = today;
    self.eventDatePicker.maximumDate = [today dateByAddingTimeInterval:604800]; /* One Week */
    
    //Event Description Setup
    self.eventDescriptionText.delegate = self;
    [self.eventDescriptionText setTextColor:[UIColor lightGrayColor]];
    
    self.createButton.titleText = @"Create Event";
    self.createButton.isRounded = NO;
    self.createButton.hasBorder = NO;
    self.createButton.font = [UIFont fontWithName:@"Lato-Bold" size:21];
    
    self.setLocationButton.isRounded = NO;
    self.setLocationButton.titleText = @"Set Location";
    self.setLocationButton.hasBorder = NO;
    [self.setLocationButton setIsSelected:NO];
    
    

    NSLog(@"self.isEditingEvent: %@", [NSNumber numberWithBool:self.isEditingEvent]);
    
    if (self.isEditingEvent) {
        
        NSLog(@"INSIDE");
        
        [self.eventDatePicker setDate:self.event.dateOfEvent animated:YES];
        self.eventDescriptionText.text = self.event.descriptionOfEvent;
        self.eventDescriptionText.textColor = [UIColor blackColor];
        
        self.setLocationButton.titleText = self.event.nameOfLocation;
        [self.setLocationButton setIsSelected:YES];
        
        self.setLocationButton.backgroundColor = [UIColor orangeThemeColor];
        
        self.createButton.titleText = @"Update Event";
        
    } else {
        
        //initialize date and event description
        self.event.dateOfEvent = [NSDate date];
        self.eventDescriptionText.text = @"Add details about your event...";
        
    }
    
}




- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
}


#pragma mark - Create Event Button

- (IBAction)createEvent:(id)sender {
    
    NSDictionary *dimensions = @{ @"UserID": [EVNUser currentUser].objectId};
    [PFAnalytics trackEventInBackground:@"EventCreation" dimensions:dimensions block:nil];

    NSLog(@"self.eventToCreate.eventDescription: %@ and eventLocationName: %@", self.event.descriptionOfEvent, self.event.nameOfLocation);
    
    if (self.event.descriptionOfEvent && self.event.nameOfLocation) {
        
        if (self.isEditingEvent) {
            

            
            /*
            self.event[@"title"] = self.event.title;
            self.event[@"descriptionOfEvent"] = self.eventDescriptionText.text;
            self.event[@"typeOfEvent"] = [NSNumber numberWithInt:self.eventToCreate.eventType];
            self.event[@"parent"] = [EVNUser currentUser];
            self.event[@"dateOfEvent"] = self.eventToCreate.eventDate;
            self.event[@"locationOfEvent"] = self.eventToCreate.eventCoordinates;
            self.event[@"nameOfLocation"] = self.eventToCreate.eventLocationName;
            */
            
            //TODO: Only Save Image if It Has Been Changed
            //Save Cover image to parse
            [self.event.coverPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    NSLog(@"Succeeded saving photo");
                    
                    //self.event[@"coverPhoto"] = self.event.coverPhoto;
                    
                    self.event[@"coverPhoto"] = self.event.coverPhoto;
                    
                    //Now Save Event to Parse
                    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            
                            NSLog(@"Succeeeded saving event");
                            
                            //Notify VCs of new event creation - TODO: updates profile view.
                            [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreated object:nil userInfo:nil];
                            
                            //Progress Indicator - Start
                            
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
                                
                                [HUD hide:YES afterDelay:1.0];
                            });
                            
                                
                        } else {
                            
                            NSLog(@"Failed saving event");

                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error updating event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                            
                            [errorAlert show];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                            
                            id<EventCreationCompleted> strongDelegate = self.delegate;
                            
                            if ([strongDelegate respondsToSelector:@selector(eventEditingCanceled)]) {
                                
                                [strongDelegate eventEditingCanceled];
                            }
                        }
                        
                    }];
                    
                } else {
                    
                    NSLog(@"Failed saving photo");

                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving event cover image" delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                    id<EventCreationCompleted> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(eventCreationCanceled)]) {
                        
                        [strongDelegate eventCreationCanceled];
                    }
                    
                    //TOOD - allow user to go back and update the cover image.
                }
                
                
            }];

            
            
        } else {
            
            /*
            PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
            
            newEvent[@"title"] = self.eventToCreate.eventTitle;
            newEvent[@"description"] = self.eventDescriptionText.text;
            newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:self.eventToCreate.eventType];
            newEvent[@"parent"] = [EVNUser currentUser];
            newEvent[@"dateOfEvent"] = self.eventToCreate.eventDate;
            newEvent[@"locationOfEvent"] = self.eventToCreate.eventCoordinates;
            newEvent[@"nameOfLocation"] = self.eventToCreate.eventLocationName;
            */
            
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
            savingEvent.center = self.view.center;
            [[darkBlurEffectView contentView] addSubview:savingEvent];
            
            [UIView animateWithDuration:3.0 animations:^{
                darkBlurEffectView.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                //Save Cover image to parse
                [self.event.coverPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        //newEvent[@"coverPhoto"] = self.eventToCreate.eventCoverImage;
                        
                        //Now Save Event to Parse
                        [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (succeeded) {
                                
                                //Notify VCs of new event creation - TODO: updates profile view.
                                [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreated object:nil userInfo:nil];
                                
                                [self.navigationController popViewControllerAnimated:NO];
                                
                                id<EventCreationCompleted> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(eventCreationComplete:withEvent:)]) {
                                    
                                    [strongDelegate eventCreationComplete:darkBlurEffectView withEvent:self.event];
                                }
                                
                                
                            } else {
                                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                                
                                [errorAlert show];
                                
                                [self.navigationController popViewControllerAnimated:NO];
                                
                                id<EventCreationCompleted> strongDelegate = self.delegate;
                                
                                if ([strongDelegate respondsToSelector:@selector(eventCreationCanceled)]) {
                                    
                                    [strongDelegate eventCreationCanceled];
                                }
                            }
                            
                        }];
                        
                    } else {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error saving event cover image" delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
                        
                        [errorAlert show];
                        
                        id<EventCreationCompleted> strongDelegate = self.delegate;
                        
                        if ([strongDelegate respondsToSelector:@selector(eventCreationCanceled)]) {
                            
                            [strongDelegate eventCreationCanceled];
                        }
                        
                        //TOOD - allow user to go back and update the cover image.
                    }
                    
                    
                }];
                
                
            }];
            
            
        }
        

        
    } else  {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Details Missing" message:@"Make sure to pick an event location and add a description to the event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
        
        [errorAlert show];
        
        [self.createButton setIsSelected:NO];
    }
    
    
    
}

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
    
    NSLog(@"New Date Being Set");
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.event.dateOfEvent = datePicker.date;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if ([textView.text isEqualToString:@"Add details about your event..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    
    self.tapToDismissView = [[UIView alloc] initWithFrame:self.view.frame];
    self.tapToDismissView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tapToDismissView];
    
    //Gesture Recognizer to Dismiss Keyboard on Tap in View
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    tapToDismiss.cancelsTouchesInView = YES;
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionDown;
    swipeUp.cancelsTouchesInView = YES;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionUp;
    swipeDown.cancelsTouchesInView = YES;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.cancelsTouchesInView = YES;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.cancelsTouchesInView = YES;
    
    [self.tapToDismissView addGestureRecognizer:tapToDismiss];
    [self.tapToDismissView addGestureRecognizer:swipeUp];
    [self.tapToDismissView addGestureRecognizer:swipeDown];
    [self.tapToDismissView addGestureRecognizer:swipeLeft];
    [self.tapToDismissView addGestureRecognizer:swipeRight];
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.tapToDismissView removeFromSuperview];

    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add details about your event...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        NSLog(@"WE HERE");
    }
    
    self.event.descriptionOfEvent = textView.text;
    
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        //[self performSegueWithIdentifier:@"PresentLocationSearch" sender:nil];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *navController = (UINavigationController *) [segue destinationViewController];
    
    LocationSearchVC *locationSearchVC = [navController.viewControllers objectAtIndex:0];
    
    locationSearchVC.delegate = self;
    
    //id: PresentLocationSearch
    
}



@end


