//
//  EventAddVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventAddVC.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface EventAddVC ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImage *imageChosenAsCover;
@property (nonatomic, strong) PFGeoPoint *eventGeoPoint;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation EventAddVC

@synthesize eventTitleField, eventDescriptionField, eventAttendersField, imageChosenAsCover, eventLocationText, eventGeoPoint, eventDatePicker, selectedDate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.eventGeoPoint = nil;
        self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        self.dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];

        self.eventDatePicker.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"New locations");
    CLLocation *newLocation = [locations lastObject];
    eventLocationText.text = [NSString stringWithFormat:@"Lat: %f", newLocation.coordinate.latitude];
    
}

#pragma mark - Adding a Cover Photo

- (IBAction)selectCoverPhoto:(id)sender {
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [pictureOptionsMenu addAction:takePhoto];
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}

- (IBAction)setEventLocation:(id)sender {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"Start Updating");
    //Now Call geopointforcurrentlocation
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        NSLog(@"GeoPoint: %@", geoPoint);
        if (!error) {
            self.eventGeoPoint = geoPoint;
        } else {
            self.eventGeoPoint = nil;
            NSLog(@"Error");
        }
    }];
    
}

- (IBAction)datePickerValueChanged:(id)sender {
    
    //Todo - Clean this code.
    
    UIDatePicker *datePickerCurrent = (UIDatePicker *)sender;
    self.selectedDate = datePickerCurrent.date;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"cccc, MMM d, hh:mm aa"];
    NSString *stringDate = [self.dateFormatter stringFromDate:self.selectedDate];
    
    self.selectedDate = [self.dateFormatter dateFromString:stringDate];
    
    NSLog(@"Selected Date: %@ and Other: %@", self.selectedDate, stringDate);
}



#pragma mark - Delegate Methods for ImagePicker

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageChosenAsCover = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Creating an Event in Parse

- (void)createEvent:(id)sender {
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
    newEvent[@"title"] = self.eventTitleField.text;
    newEvent[@"description"] = self.eventDescriptionField.text;

    NSNumberFormatter *numfromString = [[NSNumberFormatter alloc] init];
    NSNumber *attenders = [numfromString numberFromString:self.eventAttendersField.text];
    
    newEvent[@"attenders"] = attenders;
    newEvent[@"parent"] = [PFUser currentUser];
    newEvent[@"locationOfEvent"] = self.eventGeoPoint;
    
    //Date Formatting and Saving
    NSLog(@"date: %@", self.selectedDate);
    newEvent[@"dateOfEvent"] = self.selectedDate;

    NSData *eventCoverPhotoData = UIImageJPEGRepresentation(self.imageChosenAsCover, 0.5);
    PFFile *eventCoverPhotoFile = [PFFile fileWithName:@"coverphoto.jpg" data:eventCoverPhotoData];
    
    //Save Cover Photo then Add to the New Event then Save the Event to Parse
    [eventCoverPhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            newEvent[@"coverPhoto"] = eventCoverPhotoFile;
            
            [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                if (error) {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"ERROR!" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                }
                
                if (succeeded) {
                    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Saved!" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [saveAlert show];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"NO SUCCESS" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                }
                
            }];
            
            
        }
        
    }];
    


    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
