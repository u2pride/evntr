//
//  AddEventPrimaryVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AddEventSecondaryVC.h"
#import "CustomEventTypeButton.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>

@interface AddEventPrimaryVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitleField;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *publicButton;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *publicApprovedButton;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *privateButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventCoverPhotoView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) PFFile *coverPhotoFile;
@property (nonatomic) int selectedEventType;


- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)selectedPublicType:(id)sender;
- (IBAction)selectedPublicApprovedType:(id)sender;
- (IBAction)selectedPrivateType:(id)sender;
- (IBAction)canceledEventCreation:(id)sender;

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

    
    // Initialize button states & event type
    self.publicButton.selected = YES;
    self.privateButton.selected = NO;
    self.publicApprovedButton.selected = NO;
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    
    // Initialize ImageView & Attach Tap Gesture
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventCoverPhotoView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEventPhoto)];
    tapgr.delegate = self;
    [self.eventCoverPhotoView addGestureRecognizer:tapgr];
    
    //Setting Delegate of Event Title Field to Allow Removal of Keyboard on Return
    self.eventTitleField.delegate = self;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: Use same as what was selected before selecting photo
    self.publicButton.selected = YES;
    self.privateButton.selected = NO;
    self.publicApprovedButton.selected = NO;
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
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}


#pragma mark - Selecting Buttons for Event Type & Next Button

- (IBAction)selectedPublicType:(id)sender {
    
    self.selectedEventType = PUBLIC_EVENT_TYPE;
    self.publicButton.selected = YES;
    self.publicApprovedButton.selected = NO;
    self.privateButton.selected = NO;
    
}

- (IBAction)selectedPublicApprovedType:(id)sender {
    
    self.selectedEventType = PUBLIC_APPROVED_EVENT_TYPE;
    self.publicButton.selected = NO;
    self.publicApprovedButton.selected = YES;
    self.privateButton.selected = NO;
}

- (IBAction)selectedPrivateType:(id)sender {
    
    self.selectedEventType = PRIVATE_EVENT_TYPE;
    self.publicButton.selected = NO;
    self.publicApprovedButton.selected = NO;
    self.privateButton.selected = YES;
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
    
    //TODO: Restore eventTitle and button state That the User Has Inputted

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
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
    
    AddEventSecondaryVC *nextStepVC = (AddEventSecondaryVC *) [segue destinationViewController];
    
    nextStepVC.title = self.eventTitleField.text;
    nextStepVC.eventTitle = self.eventTitleField.text;
    nextStepVC.eventType = self.selectedEventType;
    nextStepVC.eventCoverImage = self.coverPhotoFile;
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


