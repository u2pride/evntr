//
//  AddEventPrimaryVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AddEventSecondVC.h"
#import "EVNButton.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>

@interface AddEventPrimaryVC ()
{
    NSMutableDictionary *stateSnapshot;
    BOOL isEditing;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitleField;

@property (strong, nonatomic) IBOutlet EVNButton *publicButton;
@property (strong, nonatomic) IBOutlet EVNButton *publicApprovedButton;
@property (strong, nonatomic) IBOutlet EVNButton *privateButton;
@property (strong, nonatomic) IBOutlet EVNButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *eventCoverPhotoView;
@property (nonatomic, strong) UIView *tapToDismissView;


@property (nonatomic, strong) PFFile *coverPhotoFile;
@property (nonatomic) int selectedEventType;

- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)canceledEventCreation:(id)sender;

- (IBAction)selectedPublic:(id)sender;
- (IBAction)selectedPublicApproved:(id)sender;
- (IBAction)selectedPrivate:(id)sender;


@end


@implementation AddEventPrimaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isEditing = NO;
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;

    //Setting Delegate of Event Title Field to Allow Removal of Keyboard on Return
    self.eventTitleField.delegate = self;
    
    //Configuring Buttons
    self.publicButton.titleText = @"Public";
    self.publicApprovedButton.titleText = @"Public-Approved";
    self.privateButton.titleText = @"Private";
    self.nextButton.titleText = @"Next";
    self.nextButton.font = [UIFont fontWithName:@"Lato-Light" size:21];
    self.nextButton.isSelected = YES;
    self.nextButton.isRounded = NO;
    self.nextButton.isStateless = YES;
    
    [self.publicApprovedButton sizeToFit];
    
    // Initialize ImageView & Attach Tap Gesture
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventCoverPhotoView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEventPhoto)];
    tapgr.delegate = self;
    [self.eventCoverPhotoView addGestureRecognizer:tapgr];
    
    self.selectedEventType = PUBLIC_EVENT_TYPE;

    /*
    //Determing Whether the User is Editing or Creating an Event
    //Editing - Comes from EventDetailVC - Asks Delegate for the Event Details
    if ([self.delegate isKindOfClass:NSClassFromString(@"EventDetailVC")]) {
        
        id<EventModalProtocol> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(eventDetailsToEdit)]) {
            
            //NSDictionary *values = [strongDelegate eventDetailsToEdit];

            NSNumber *type = [values objectForKey:@"type"];
            NSString *title = [values objectForKey:@"title"];
            UIImage *image = [values objectForKey:@"image"];
            PFFile *imageFile = [values objectForKey:@"file"];
            
            self.selectedEventType = [type intValue];
            self.eventTitleField.text = title;
            self.eventCoverPhotoView.image = image;
            self.coverPhotoFile = imageFile;
            
            NSString *description = [values objectForKey:@"description"];
            PFGeoPoint *coordinates = [values objectForKey:@"coordinates"];
            NSString *locationName = [values objectForKey:@"locationName"];
            NSDate *date = [values objectForKey:@"date"];
            
            PFObject *eventObject = [values objectForKey:@"object"];
            
            //TOOD: Create NewEvent initializer that takes in an event object so I don't have to do all of this here.
            self.eventEditing = [[NewEventModel alloc] initWithTitle:title eventType:[type intValue] coverImage:imageFile eventDescription:description location: coordinates locationName:locationName eventDate:date backingObject:eventObject];
            

        }
        
    }
    
     */

    
    if (self.eventToEdit) {
        
        self.selectedEventType = [self.eventToEdit.typeOfEvent intValue];
        self.eventTitleField.text = self.eventToEdit.title;
        [self.eventToEdit coverImage:^(UIImage *image) {
            self.eventCoverPhotoView.image = image;
        }];
        
        NSLog(@"CoverPhotoFile Before Edit: %@", self.eventToEdit.coverPhoto);
        self.coverPhotoFile = self.eventToEdit.coverPhoto;
        
        isEditing = YES;
    
        self.title = @"Edit Event";
        self.navigationItem.leftBarButtonItems = nil;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(eventEditingCanceled)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    

    
}




- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.eventTitleField becomeFirstResponder];
    
}


- (void) setSelectedEventType:(int)selectedEventType {
    
    switch (selectedEventType) {
        case PUBLIC_EVENT_TYPE: {
            
            self.publicButton.isSelected = YES;
            self.publicApprovedButton.isSelected = NO;
            self.privateButton.isSelected = NO;
            
            break;
        }
        case PRIVATE_EVENT_TYPE: {
            
            self.publicButton.isSelected = NO;
            self.publicApprovedButton.isSelected = NO;
            self.privateButton.isSelected = YES;
            
            break;
        }
        case PUBLIC_APPROVED_EVENT_TYPE: {
            
            self.publicButton.isSelected = NO;
            self.publicApprovedButton.isSelected = YES;
            self.privateButton.isSelected = NO;
            
            break;
        }
            
        default:
            break;
    }
    
    _selectedEventType = selectedEventType;
    
}



#pragma mark - Selecting Cover Photo

- (void) selectEventPhoto {
    
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
        imagePicker.view.tintColor = [UIColor orangeThemeColor];
        imagePicker.navigationBar.tintColor = [UIColor orangeThemeColor];
        imagePicker.navigationController.navigationBar.tintColor = [UIColor orangeThemeColor];

        
        [self presentViewController:imagePicker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        }];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [pictureOptionsMenu addAction:takePhoto];
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    if (!stateSnapshot) {
        stateSnapshot = [[NSMutableDictionary alloc] init];
    }
    
    NSLog(@"event text: %@", self.eventTitleField.text);
    
    [stateSnapshot setObject:self.eventTitleField.text forKey:@"kTitle"];
    [stateSnapshot setObject:[NSNumber numberWithInt:self.selectedEventType] forKey:@"kType"];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}


#pragma mark - Selecting Buttons for Event Type & Next Button

- (IBAction)selectedPublic:(id)sender {
    
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    
}

- (IBAction)selectedPublicApproved:(id)sender {
    
    self.selectedEventType = PUBLIC_APPROVED_EVENT_TYPE;
    
}

- (IBAction)selectedPrivate:(id)sender {
    
    self.selectedEventType = PRIVATE_EVENT_TYPE;
    
}


- (IBAction)nextButtonPressed:(id)sender {
    
    if (self.eventTitleField.text.length > 3 && self.coverPhotoFile) {
        
        [self performSegueWithIdentifier:@"AddEventNextStep" sender:self];
        
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please upload a photo or select a title that is greater than 3 characters." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
        [errorAlert show];
    }
}



#pragma mark - Delegate Methods for ImagePicker & TextField

//create a PFFile From the Image
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [self.eventTitleField resignFirstResponder];
        
    }];

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.eventCoverPhotoView.image = chosenImage;
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenImage, 0.5);
    self.coverPhotoFile = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    
    //Editing Event - Add New Cover Photo to the Event
    if (isEditing) {
        self.eventToEdit.coverPhoto = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    }
    
    //Restore Selections
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    //Restore Selections
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    AddEventSecondVC *nextStepVC = (AddEventSecondVC *) [segue destinationViewController];
    
    nextStepVC.title = self.eventTitleField.text;
    nextStepVC.delegate = self;

    
    //If there is an Event Already Exisitng - We are editing the event
    if (self.eventToEdit) {
        
        self.eventToEdit.title = self.eventTitleField.text;
        self.eventToEdit.typeOfEvent = [NSNumber numberWithInt:self.selectedEventType];
        self.coverPhotoFile = self.coverPhotoFile;
        
        nextStepVC.event = self.eventToEdit;
        nextStepVC.isEditingEvent = YES;
        
        NSLog(@"FIRST STEP: %@", [NSNumber numberWithBool:nextStepVC.isEditingEvent] );
        
    } else {
        
        //Create New Event Object
        
        EventObject *newEvent = [EventObject object];
        
        newEvent.title = self.eventTitleField.text;
        newEvent.typeOfEvent = [NSNumber numberWithInt:self.selectedEventType];
        newEvent.coverPhoto = self.coverPhotoFile;
        
        nextStepVC.event = newEvent;
        nextStepVC.isEditingEvent = NO;

    }
    
}

#pragma mark - Tap To Dismiss Keyboard
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    self.tapToDismissView = [[UIView alloc] initWithFrame:self.view.frame];
    self.tapToDismissView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tapToDismissView];
    
    //Gesture Recognizer to Dismiss Keyboard on Tap in View
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissKeyboard)];
    tapToDismiss.cancelsTouchesInView = YES;
    [self.tapToDismissView addGestureRecognizer:tapToDismiss];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.tapToDismissView removeFromSuperview];
    
}

- (void)tapToDismissKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Delegate Methods for EventCreation

- (void) eventCreationComplete:(UIVisualEffectView *)darkBlur withEvent:(EventObject *)event {

    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventTitleField.text = @"";
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    
    self.coverPhotoFile = nil;
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedEventCreation:withEvent:)]) {
    
        [strongDelegate completedEventCreation:darkBlur withEvent:event];
    }

}


- (void) eventCreationCanceled {
    
    [self.eventTitleField resignFirstResponder];
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventTitleField.text = @"";
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    
    self.coverPhotoFile = nil;
    
    id<EventModalProtocol> strongDelegate = self.delegate;
        
    if ([strongDelegate respondsToSelector:@selector(canceledEventCreation)]) {
            
        [strongDelegate canceledEventCreation];
    }
    
}



#pragma mark - Event Editing Delegates

- (void) eventEditingComplete:(EventObject *)updatedEvent {
    NSLog(@"Event Editing Complete");
        
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedEventEditing:)]) {
        
        [strongDelegate completedEventEditing:updatedEvent];
    }
    
}


- (void) eventEditingCanceled {
    NSLog(@"Event Editing Canceled");
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEventEditing)]) {
        
        [strongDelegate canceledEventEditing];
    }
}




#pragma mark -- Button Press on Storyboard


- (IBAction)canceledEventCreation:(id)sender {
    
    [self eventCreationCanceled];
}






@end


