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
#import "UIColor+EVNColors.h"
#import "EVNCustomButton.h"
#import "EVNDefaultButton.h"
#import "EVNLocationButton.h"

@interface AddEventSecondVC ()

@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (strong, nonatomic) IBOutlet EVNLocationButton *setLocationButton;
@property (strong, nonatomic) IBOutlet EVNButton *createButton;


- (IBAction)createEvent:(id)sender;
- (IBAction)setLocation:(id)sender;

@end


@implementation AddEventSecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Subscribe to Date Picker Changes
    [self.eventDatePicker addTarget:self action:@selector(newDate:) forControlEvents:UIControlEventValueChanged];
    
    //initialize date
    self.eventToCreate.eventDate = [NSDate date];
    
    //Event Description Setup
    self.eventDescriptionText.delegate = self;
    self.eventDescriptionText.text = @"Add details about your event...";
    [self.eventDescriptionText setTextColor:[UIColor lightGrayColor]];
    
    self.createButton.titleText = @"Create Event";
    self.createButton.isRounded = NO;
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"self: %@", self);
    
}


#pragma mark - Create Event Button

- (IBAction)createEvent:(id)sender {
    
    NSLog(@"self.eventToCreate.eventDescription: %@ and eventLocationName: %@", self.eventToCreate.eventDescription, self.eventToCreate.eventLocationName);
    
    if (self.eventToCreate.eventDescription && self.eventToCreate.eventLocationName) {
        
        PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
        
        newEvent[@"title"] = self.eventToCreate.eventTitle;
        newEvent[@"description"] = self.eventDescriptionText.text;
        newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:self.eventToCreate.eventType];
        newEvent[@"parent"] = [PFUser currentUser];
        newEvent[@"dateOfEvent"] = self.eventToCreate.eventDate;
        newEvent[@"locationOfEvent"] = self.eventToCreate.eventCoordinates;
        newEvent[@"nameOfLocation"] = self.eventToCreate.eventLocationName;
        
        
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
        savingEvent.center = self.view.center;
        [[darkBlurEffectView contentView] addSubview:savingEvent];
        
        [UIView animateWithDuration:3.0 animations:^{
            darkBlurEffectView.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            //Save Cover image to parse
            [self.eventToCreate.eventCoverImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    newEvent[@"coverPhoto"] = self.eventToCreate.eventCoverImage;
                    
                    //Now Save Event to Parse
                    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            
                            //Notify VCs of new event creation - TODO: updates profile view.
                            [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreated object:nil userInfo:nil];
                            
                            [self.navigationController popViewControllerAnimated:NO];
                            
                            id<EventCreationCompleted> strongDelegate = self.delegate;
                            
                            if ([strongDelegate respondsToSelector:@selector(eventCreationComplete:)]) {
                                
                                [strongDelegate eventCreationComplete:darkBlurEffectView];
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

        
        
    } else  {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Details Missing" message:@"Make sure to pick an event location and add a description to the event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
        
        [errorAlert show];
        
        [self.createButton setIsSelected:NO];
    }
    
    
    
}


- (IBAction)setLocation:(id)sender {
    
    [self performSegueWithIdentifier:@"PresentLocationSearch" sender:nil];
    
}


#pragma mark - Location Search Delegate Methods

- (void) locationSearchDidCancel {
    
    if ([self.setLocationButton.titleLabel.text isEqualToString:@"Set Location"]) {
        [self.setLocationButton setSelected:NO];
        [self.setLocationButton setHighlighted:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void) locationSelectedWithCoordinates:(CLLocation *)location andName:(NSString *)name {
    
    self.eventToCreate.eventCoordinates = [PFGeoPoint geoPointWithLocation:location];
    self.eventToCreate.eventLocationName = name;
    
    
    [self.setLocationButton setTitle:name forState:UIControlStateNormal];
    [self.setLocationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.setLocationButton.backgroundColor = [UIColor orangeThemeColor];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark - Date Picker & TextView Delegates

- (void) newDate:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.eventToCreate.eventDate = datePicker.date;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add details about your event..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add details about your event...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        NSLog(@"WE HERE");
    }
    
    self.eventToCreate.eventDescription = textView.text;
    
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


