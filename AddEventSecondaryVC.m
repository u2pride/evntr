//
//  AddEventSecondaryVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventSecondaryVC.h"

@interface AddEventSecondaryVC ()
{
    NSDate *selectedDate;
    PFGeoPoint *selectedLocationGeoPoint;
    NSString *selectedLocationTitle;
}
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;

- (IBAction)setLocation:(id)sender;
- (IBAction)createEvent:(id)sender;

@end

@implementation AddEventSecondaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Subscribe to Date Picker Changes
    [self.eventDatePicker addTarget:self action:@selector(newDate:) forControlEvents:UIControlEventValueChanged];
    
    //initialize date
    selectedDate = [NSDate date];
    
    //setting delegates
    self.eventDescriptionText.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newDate:(id)sender {
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    selectedDate = datePicker.date;
    
}


- (IBAction)setLocation:(id)sender {
    
    
    
}

- (IBAction)createEvent:(id)sender {
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
    
    newEvent[@"title"] = self.eventTitle;
    newEvent[@"description"] = self.eventDescriptionText.text;
    newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:self.eventType];
    newEvent[@"parent"] = [PFUser currentUser];
    newEvent[@"dateOfEvent"] = selectedDate;
    newEvent[@"locationOfEvent"] = selectedLocationGeoPoint;
    newEvent[@"nameOfLocation"] = selectedLocationTitle;
    
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
                    
                    //Notify VCs of new event creation - updates profile view.
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
                        
                        NSLog(@"FOUND STRONG DELEGATE 1");

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



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}


#pragma mark - Location Search Delegate Methods

- (void) locationSearchDidCancel {
    
    NSLog(@"Location Search Canceled");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void) locationSelectedWithCoordinates:(CLLocation *)location andName:(NSString *)name {
    
    NSLog(@"Returned with Location Data %@ %@", location, name);
    
    selectedLocationGeoPoint = [PFGeoPoint geoPointWithLocation:location];
    selectedLocationTitle = name;
    
    [self dismissViewControllerAnimated:YES completion:nil];


}
    
    



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *navController = (UINavigationController *) [segue destinationViewController];
    
    LocationSearchVC *locationSearchVC = [navController.viewControllers objectAtIndex:0];
    
    locationSearchVC.delegate = self;
    
    //id: PresentLocationSearch
    
}



@end
