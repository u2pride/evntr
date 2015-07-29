//
//  AddEventPrimaryVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "AddEventPrimaryVC.h"
#import "AddEventSecondVC.h"
#import "EVNButton.h"
#import "EVNUtility.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>
@import Photos;

@interface AddEventPrimaryVC ()
{
    NSMutableDictionary *stateSnapshot;
    BOOL isEditingEvent;
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

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isEditingEvent = NO;
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    self.eventTitleField.delegate = self;
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];

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
    self.eventCoverPhotoView.clipsToBounds = YES;
    self.eventCoverPhotoView.contentMode = UIViewContentModeScaleAspectFill;
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventCoverPhotoView.userInteractionEnabled = YES;
    
    UIGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEventPhoto)];
    tapgr.delegate = self;
    [self.eventCoverPhotoView addGestureRecognizer:tapgr];

 
    if (self.eventToEdit) {
        
        isEditingEvent = YES;
        self.title = @"Edit Event";
        self.navigationItem.leftBarButtonItems = nil;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentCancel"] style:UIBarButtonItemStylePlain target:self action:@selector(eventEditingCanceled)];
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        /*Customize Cancel Bar Buttton
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                       nil]
                                                             forState:UIControlStateNormal];

        */
        self.selectedEventType = [self.eventToEdit.typeOfEvent intValue];
        self.eventTitleField.text = self.eventToEdit.title;
        [self.eventToEdit coverImage:^(UIImage *image) {
            self.eventCoverPhotoView.image = image;
        }];
        
        self.coverPhotoFile = self.eventToEdit.coverPhoto;
    
        self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
    }
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.eventTitleField.text.length == 0) {
        [self.eventTitleField becomeFirstResponder];
    }
}


#pragma mark - Custom Setters

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



#pragma mark - User Actions

- (void) selectEventPhoto {
    
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [PFAnalytics trackEventInBackground:@"CreateEvent_CameraUsed" block:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.amplitudeInstance logEvent:@"CreateEvent_CameraUsed"];
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [PFAnalytics trackEventInBackground:@"CreateEvent_PhotoPickerUsed" block:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.amplitudeInstance logEvent:@"CreateEvent_PhotoPickerUsed"];
        
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
    
    UIAlertAction *lastPhoto = [UIAlertAction actionWithTitle:@"Use Last Photo Taken" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        [PFAnalytics trackEventInBackground:@"CreateEvent_LastPhotoUsed" block:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.amplitudeInstance logEvent:@"CreateEvent_LastPhotoUsed"];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO], ];
    
        PHFetchResult *fetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastPhotoAsset = [fetchResults firstObject];
        
        PHImageManager *defaultManager = [PHImageManager defaultManager];
        PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [defaultManager requestImageForAsset:lastPhotoAsset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            
            //PHImageManager - Result Handler is Run on Background Thread - UI Needs to Be Updated on Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.eventCoverPhotoView.image = result;
            });
            
            NSData *pictureData = UIImageJPEGRepresentation(result, 0.5);
            self.coverPhotoFile = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
            
            //Editing Event - Add New Cover Photo to the Event
            if (isEditingEvent) {
                self.eventToEdit.coverPhoto = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
            }
            
        }];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [pictureOptionsMenu addAction:lastPhoto];
    [pictureOptionsMenu addAction:takePhoto];
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    if (!stateSnapshot) {
        stateSnapshot = [[NSMutableDictionary alloc] init];
    }
    
    [stateSnapshot setObject:self.eventTitleField.text forKey:@"kTitle"];
    [stateSnapshot setObject:[NSNumber numberWithInt:self.selectedEventType] forKey:@"kType"];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}


- (IBAction)selectedPublic:(id)sender {
    
    if (isEditingEvent) {
        [self showEditingPopup];
    } else {
        self.selectedEventType = PUBLIC_EVENT_TYPE;
    }
    
}

- (IBAction)selectedPublicApproved:(id)sender {
    
    if (isEditingEvent) {
        [self showEditingPopup];
    } else {
        self.selectedEventType = PUBLIC_APPROVED_EVENT_TYPE;
    }
    
}

- (IBAction)selectedPrivate:(id)sender {
    

    if (isEditingEvent) {
        [self showEditingPopup];
    } else {
        self.selectedEventType = PRIVATE_EVENT_TYPE;
    }
    
}

- (IBAction)canceledEventCreation:(id)sender {
    
    [self eventCreationCanceled];
}


- (IBAction)nextButtonPressed:(id)sender {
    
    if (self.eventTitleField.text.length <= MAX_EVENTTITLE_LENGTH && self.eventTitleField.text.length >= MIN_EVENTTITLE_LENGTH && self.coverPhotoFile) {
        [self performSegueWithIdentifier:@"AddEventNextStep" sender:self];

    } else {
        
        if (self.eventTitleField.text.length < MIN_EVENTTITLE_LENGTH) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Title" message:@"Please use a longer title for your event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            [errorAlert show];
            
        } else if (self.eventTitleField.text.length > MAX_EVENTTITLE_LENGTH) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Event Title" message:@"Please use a shorter title for your event." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            [errorAlert show];
            
        } else if (!self.coverPhotoFile) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Cover Photo" message:@"Please select a photo." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            [errorAlert show];
            
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Other" message:@"Fill out all fields. If you have, tweet or email us in settings and we'll help figure out your problem." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            [errorAlert show];
            
        }
        
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
    
    self.eventCoverPhotoView.image = chosenImage;
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenImage, 0.5);
    self.coverPhotoFile = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    
    //Editing Event - Add New Cover Photo to the Event
    if (isEditingEvent) {
        self.eventToEdit.coverPhoto = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    }
    
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }];
}



#pragma mark - UITextField Delegate Methods

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
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

}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self.tapToDismissView removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)tapToDismissKeyboard {
    [self.view endEditing:YES];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AddEventSecondVC *nextStepVC = (AddEventSecondVC *) [segue destinationViewController];
    
    nextStepVC.title = self.eventTitleField.text;
    nextStepVC.delegate = self;
    
    if (self.eventToEdit) {
        
        self.eventToEdit.title = self.eventTitleField.text;
        self.eventToEdit.typeOfEvent = [NSNumber numberWithInt:self.selectedEventType];
        self.coverPhotoFile = self.coverPhotoFile;
        
        nextStepVC.event = self.eventToEdit;
        nextStepVC.isEditingEvent = YES;
        
    } else {
        
        EventObject *newEvent = [EventObject object];
        
        newEvent.title = self.eventTitleField.text;
        newEvent.typeOfEvent = [NSNumber numberWithInt:self.selectedEventType];
        newEvent.coverPhoto = self.coverPhotoFile;
        
        nextStepVC.event = newEvent;
        nextStepVC.isEditingEvent = NO;
        
    }
    
}

#pragma mark - Helper Methods

- (void) showEditingPopup {
    
    UIAlertView *editDisabled = [[UIAlertView alloc] initWithTitle:@"Indecisive Are We?" message:@"It's too late in the game to change your event type and besides, everyone knows once you change type you lose all the hype..." delegate:self cancelButtonTitle:@"Try Again Soon" otherButtonTitles: nil];
    
    [editDisabled show];
    
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
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedEventEditing:)]) {
        
        [strongDelegate completedEventEditing:updatedEvent];
    }
    
}

- (void) eventEditingCanceled {
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEventEditing)]) {
        
        [strongDelegate canceledEventEditing];
    }
}





@end


