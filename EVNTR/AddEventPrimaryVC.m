//
//  AddEventPrimaryVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AddEventSecondVC.h"
#import "CustomEventTypeButton.h"
#import "EVNButton.h"
#import "NewEventModel.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>

@interface AddEventPrimaryVC ()
{
    NSMutableDictionary *stateSnapshot;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitleField;

@property (strong, nonatomic) IBOutlet EVNButton *publicButton;
@property (strong, nonatomic) IBOutlet EVNButton *publicApprovedButton;
@property (strong, nonatomic) IBOutlet EVNButton *privateButton;
@property (strong, nonatomic) IBOutlet EVNButton *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *eventCoverPhotoView;


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
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    //Configuring Buttons
    self.publicButton.titleText = @"Public";
    self.publicApprovedButton.titleText = @"Public-Approved";
    self.privateButton.titleText = @"Private";
    self.nextButton.titleText = @"Next";
    self.nextButton.isSelected = YES;
    self.nextButton.isRounded = NO;
    self.nextButton.isStateless = YES;
    
    [self.publicApprovedButton sizeToFit];
    
    
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    
    // Initialize ImageView & Attach Tap Gesture
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventCoverPhotoView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEventPhoto)];
    tapgr.delegate = self;
    [self.eventCoverPhotoView addGestureRecognizer:tapgr];
    
    //Setting Delegate of Event Title Field to Allow Removal of Keyboard on Return
    self.eventTitleField.delegate = self;
    
    self.selectedEventType = PUBLIC_EVENT_TYPE;

}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [pictureOptionsMenu addAction:takePhoto];
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.eventCoverPhotoView.image = chosenImage;
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenImage, 0.5);
    self.coverPhotoFile = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    
    //Restore Selections
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    //Restore Selections
    self.eventTitleField.text = [stateSnapshot objectForKey:@"kTitle"];
    self.selectedEventType = [[stateSnapshot objectForKey:@"kType"] intValue];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    
    NewEventModel *eventInProgress = [[NewEventModel alloc] initWithTitle:self.eventTitleField.text eventType:self.selectedEventType coverImage:self.coverPhotoFile];
    
    nextStepVC.title = self.eventTitleField.text;

    nextStepVC.eventToCreate = eventInProgress;
    
    nextStepVC.delegate = self;
    
}


#pragma mark - Delegate Methods for EventCreation

- (void) eventCreationComplete:(UIVisualEffectView *)darkBlur {
            
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventTitleField.text = @"";
    self.publicButton.selected = YES;
    self.publicApprovedButton.selected = YES;
    self.privateButton.selected = YES;

    self.coverPhotoFile = nil;
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedEventCreation:)]) {
    
        [strongDelegate completedEventCreation:darkBlur];
    }

}


- (void) eventCreationCanceled {
    
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventTitleField.text = @"";
    self.publicButton.selected = YES;
    self.publicApprovedButton.selected = YES;
    self.privateButton.selected = YES;
    
    self.coverPhotoFile = nil;
    
    id<EventModalProtocol> strongDelegate = self.delegate;
        
    if ([strongDelegate respondsToSelector:@selector(canceledEventCreation)]) {
            
        [strongDelegate canceledEventCreation];
    }
    
}



- (IBAction)canceledEventCreation:(id)sender {
    
    id<EventModalProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEventCreation)]) {
        
        [strongDelegate canceledEventCreation];
    }
}






@end


