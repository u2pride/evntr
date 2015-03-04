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
#import <Parse/Parse.h>
#import "UIColor+EVNColors.h"

@interface AddEventPrimaryVC () {
    PFFile *coverPhotoFile;
    int selectedEventType;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitleField;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *publicButton;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *publicApprovedButton;
@property (weak, nonatomic) IBOutlet CustomEventTypeButton *privateButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventCoverPhotoView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)selectedPublicType:(id)sender;
- (IBAction)selectedPublicApprovedType:(id)sender;
- (IBAction)selectedPrivateType:(id)sender;


@end

@implementation AddEventPrimaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize button states & event type
    self.publicButton.selected = YES;
    self.privateButton.selected = NO;
    self.publicApprovedButton.selected = NO;
    selectedEventType = PUBLIC_EVENT_TYPE;
    
    // Initialize ImageView & Attach Tap Gesture
    self.eventCoverPhotoView.image = [UIImage imageNamed:@"takePicture"];
    self.eventCoverPhotoView.userInteractionEnabled = YES;
    UIGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEventPhoto)];
    tapgr.delegate = self;
    [self.eventCoverPhotoView addGestureRecognizer:tapgr];
    
    //Change Navigation Bar Color to Theme
    self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Initialize button states & event type
    self.publicButton.selected = YES;
    self.privateButton.selected = NO;
    self.publicApprovedButton.selected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//Triggered when user taps UIImageView to pick an image
- (void) selectEventPhoto {
    
    NSLog(@"HERERERE");
    
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


- (IBAction)nextButtonPressed:(id)sender {
    
    if (self.eventTitleField.text.length > 3 && coverPhotoFile) {
        
        [self performSegueWithIdentifier:@"AddEventNextStep" sender:self];
        
        
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please upload a photo or select a title that is greater than 3 characters." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
        
        [errorAlert show];
    }
    
    
    
}

- (IBAction)selectedPublicType:(id)sender {
    
    selectedEventType = PUBLIC_EVENT_TYPE;
    self.publicButton.selected = YES;
    self.publicApprovedButton.selected = NO;
    self.privateButton.selected = NO;
    
}

- (IBAction)selectedPublicApprovedType:(id)sender {
    
    selectedEventType = PUBLIC_APPROVED_EVENT_TYPE;
    self.publicButton.selected = NO;
    self.publicApprovedButton.selected = YES;
    self.privateButton.selected = NO;
}

- (IBAction)selectedPrivateType:(id)sender {
    
    selectedEventType = PRIVATE_EVENT_TYPE;
    self.publicButton.selected = NO;
    self.publicApprovedButton.selected = NO;
    self.privateButton.selected = YES;
}


#pragma mark - Delegate Methods for ImagePicker

//create a PFFile From the Image
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.eventCoverPhotoView.image = chosenImage;
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenImage, 0.5);
    coverPhotoFile = [PFFile fileWithName:@"eventCoverPhoto.jpg" data:pictureData];
    

    //Restore eventTitle and button state That the User Has Inputted

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    AddEventSecondaryVC *nextStepVC = (AddEventSecondaryVC *) [segue destinationViewController];
    
    nextStepVC.eventTitle = self.eventTitleField.text;
    nextStepVC.eventType = selectedEventType;
    nextStepVC.eventCoverImage = coverPhotoFile;
    
    NSLog(@"%@ ---- %d ----- %@", self.eventTitleField.text, selectedEventType, coverPhotoFile);
    
    
}


@end



/*

*/


