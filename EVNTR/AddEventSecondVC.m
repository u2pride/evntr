//
//  AddEventSecondVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/5/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventSecondVC.h"
#import "LocationSearchVC.h"


@interface AddEventSecondVC ()
{
    NSDate *selectedDate;
    PFGeoPoint *selectedLocationGeoPoint;
    NSString *selectedLocationTitle;
}
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionText;
@property (weak, nonatomic) IBOutlet UILabel *locationButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;

- (IBAction)createEvent:(id)sender;

@end

@implementation AddEventSecondVC


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
    self.eventDescriptionText.text = @"Add details about your event...";
    [self.eventDescriptionText setTextColor:[UIColor lightGrayColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newDate:(id)sender {
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    selectedDate = datePicker.date;
    
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
 replacementText:(NSString *)text {
    
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
    
    self.locationButton.text = name;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"PresentLocationSearch" sender:nil];
    }
    
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






















/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//@end
