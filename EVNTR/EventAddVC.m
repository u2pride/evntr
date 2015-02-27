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
#import "PeopleVC.h"
#import "EVNConstants.h"
#import "EVNUtility.h"
#import <AddressBookUI/AddressBookUI.h>

@interface EventAddVC ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImage *imageChosenAsCover;
@property (nonatomic, strong) PFGeoPoint *eventGeoPoint;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray *peopleToInvite;
@property (weak, nonatomic) IBOutlet UISwitch *publicPrivateSwitch;

@end

@implementation EventAddVC

@synthesize eventTitleField, eventDescriptionField, imageChosenAsCover, eventLocationText, eventGeoPoint, eventDatePicker, selectedDate, peopleToInvite, publicPrivateSwitch;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.eventGeoPoint = [[PFGeoPoint alloc] init];
        self.eventDatePicker.timeZone = [NSTimeZone systemTimeZone];
        self.title = @"Add Event";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"New locations");
    CLLocation *newLocation = [locations lastObject];
    [self reverseGeocode:newLocation];
    self.eventGeoPoint = [PFGeoPoint geoPointWithLocation:newLocation];

}

//Note:  Interesting.  Can use the appDelegate to set the user location. And then retrieve from the app delegate. Is this better than storing in NSUserDefaults?
//Note:  Source of code: http://stackoverflow.com/questions/26111631/ios-8-parse-com-update-and-pf-geopoint-current-location
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            NSLog(@"kCLAuthorizationStatusDenied");
        
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            //[self setEventLocation:self];
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            //[self setEventLocation:self];

            break;
        }
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
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

#pragma mark - Setting Event Location

- (IBAction)setEventLocation:(id)sender {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
   
    /*  Removed code.  Was using two CLLocationManagers.
    NSLog(@"Start Updating");
    //Now Call geopointforcurrentlocation
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        NSLog(@"GeoPoint: %@", geoPoint);
        if (!error) {
            self.eventGeoPoint = geoPoint;
        } else {
            self.eventGeoPoint.latitude = 43.000;
            self.eventGeoPoint.longitude = 32.000;
            NSLog(@"Error");
            NSLog(@"GeoPoint2: %@", geoPoint);
        }
    }];
     
     */
    
}

#pragma mark - Setting Event Date

- (IBAction)datePickerValueChanged:(id)sender {
    
    //Update the selectedDate with the Current Date from the Date Picker
    UIDatePicker *datePickerCurrent = (UIDatePicker *)sender;
    self.selectedDate = datePickerCurrent.date;
    
    /* Reference on Conversions of Date
    NSDate* ts_utc = datePickerCurrent.date;
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    [df_local setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    
    NSString* ts_utc_string = [df_utc stringFromDate:ts_utc];
    NSString* ts_local_string = [df_local stringFromDate:ts_utc];
    
    NSLog(@"Selected Date: %@ and UTC: %@ and Local: %@", self.selectedDate, ts_utc_string, ts_local_string);
     */

}

#pragma mark - Reverse Geo-Coding Location

- (void)reverseGeocode:(CLLocation *)location {
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error with Location");
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.eventLocationText.text = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];

        }
        
    }];
}


#pragma mark - Inviting People to Event

- (IBAction)invitePeopleToEvent:(id)sender {
    
    [self.eventDescriptionField resignFirstResponder];
    
    NSLog(@"Pressed");
    
    PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
    invitePeopleVC.profileUsername = [PFUser currentUser];
    invitePeopleVC.delegate = self;
    
    [self presentViewController:invitePeopleVC animated:YES completion:nil];
    
    //[self.navigationController pushViewController:invitePeopleVC animated:YES];
    
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
    
    newEvent[@"parent"] = [PFUser currentUser];
    newEvent[@"locationOfEvent"] = self.eventGeoPoint;
    
    //Date Formatting and Saving
    newEvent[@"dateOfEvent"] = self.selectedDate;
    
    //Set Type of Event - Default is Public For Now
    if (publicPrivateSwitch.on) {
        newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:PUBLIC_EVENT_TYPE];
    } else {
        NSLog(@"Private Event");
        newEvent[@"typeOfEvent"] = [NSNumber numberWithInt:PRIVATE_EVENT_TYPE];
    }

    NSData *eventCoverPhotoData = UIImageJPEGRepresentation(self.imageChosenAsCover, 0.5);
    PFFile *eventCoverPhotoFile = [PFFile fileWithName:@"coverphoto.jpg" data:eventCoverPhotoData];
    
    //Save Cover Photo then Add to the New Event then Save the Event to Parse
    [eventCoverPhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            newEvent[@"coverPhoto"] = eventCoverPhotoFile;
            
            [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                if (error) {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Error Creating Event" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                }
                
                if (succeeded) {
                    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Saved!" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [saveAlert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreated object:nil userInfo:nil];
                    
                    
                    //now invite people
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        PFRelation *invitedRelation = [newEvent relationForKey:@"invitedUsers"];

                        for (PFUser *user in self.peopleToInvite) {
                            
                            //If Private Event - Also Add Invited People to invitedUsers column as a PFRelation - actually maybe not
                            //if (publicPrivateSwitch.on) {
                            [invitedRelation addObject:user];
                            //}
                            
                            NSLog(@"People to Invite: %@", self.peopleToInvite);
                            PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
                            
                            newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
                            newInvitationActivity[@"from"] = [PFUser currentUser];
                            newInvitationActivity[@"to"] = user;
                            newInvitationActivity[@"activityContent"] = newEvent;
                            
                            NSLog(@"New Invitations: %@ with event: %@", newInvitationActivity, newEvent);
                            
                            //save the invitation activities
                            [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                if (succeeded) {
                                    NSLog(@"Saved");
                                } else {
                                    NSLog(@"Error in Saved");
                                }
                            }];
                        }
                        
                        //save the new invitedUsers relations for the Event - best to use saveEventually or saveInBackground? well we are already background so save]
                        [newEvent save];
                    
                    });
                    


                    //[self dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Error Creating Event2" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                    
                    [errorAlert show];
                    
                }
                
            }];
            
            
        }
        
    }];
    


    
}

#pragma mark -
#pragma mark - PeopleVC Delegate Methods

//Used when selecting people to invite to event

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    self.peopleToInvite = selectedPeople;
    
    //selectedPeople is an array of PFUsers... what to do with them??
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
