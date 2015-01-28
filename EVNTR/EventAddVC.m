//
//  EventAddVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventAddVC.h"
#import <Parse/Parse.h>

@interface EventAddVC ()

@property (strong, nonatomic) UIImage *imageChosenAsCover;

@end

@implementation EventAddVC

@synthesize eventTitleField, eventDescriptionField, eventAttendersField, imageChosenAsCover;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

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

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.imageChosenAsCover = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)createEvent:(id)sender {
    
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
    newEvent[@"Title"] = self.eventTitleField.text;
    newEvent[@"Description"] = self.eventDescriptionField.text;

    NSNumberFormatter *numfromString = [[NSNumberFormatter alloc] init];
    NSNumber *attenders = [numfromString numberFromString:self.eventAttendersField.text];
    
    newEvent[@"Attenders"] = attenders;
    newEvent[@"parent"] = [PFUser currentUser];
    
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
