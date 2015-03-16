//
//  AddEventSecondVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventSecondVC.h"
#import "LocationSearchVC.h"
#import "UIColor+EVNColors.h"
#import "EVNCustomButton.h"
#import "EVNDefaultButton.h"
#import "EVNLocationButton.h"

@interface AddEventSecondVC ()

@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;
@property (strong, nonatomic) IBOutlet EVNLocationButton *setLocationButton;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) PFGeoPoint *selectedLocationGeoPoint;
@property (nonatomic, strong) NSString *selectedLocationTitle;

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
    self.selectedDate = [NSDate date];
    
    //Event Description Setup
    self.eventDescriptionText.delegate = self;
    self.eventDescriptionText.text = @"Add details about your event...";
    [self.eventDescriptionText setTextColor:[UIColor lightGrayColor]];
    
}



#pragma mark - Create Event Button

- (IBAction)createEvent:(id)sender {
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
    
    newEvent[@"title"] = self.eventTitle;
    newEvent[@"description"] = self.eventDescriptionText.text;
    newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:self.eventType];
    newEvent[@"parent"] = [PFUser currentUser];
    newEvent[@"dateOfEvent"] = self.selectedDate;
    newEvent[@"locationOfEvent"] = self.selectedLocationGeoPoint;
    newEvent[@"nameOfLocation"] = self.selectedLocationTitle;
    
    
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
        [self.eventCoverImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                newEvent[@"coverPhoto"] = self.eventCoverImage;
                
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
    
    self.selectedLocationGeoPoint = [PFGeoPoint geoPointWithLocation:location];
    self.selectedLocationTitle = name;
    
    
    [self.setLocationButton setTitle:name forState:UIControlStateNormal];
    [self.setLocationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.setLocationButton.backgroundColor = [UIColor orangeThemeColor];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark - Date Picker & TextView Delegates

- (void) newDate:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.selectedDate = datePicker.date;
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
    }
    
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


