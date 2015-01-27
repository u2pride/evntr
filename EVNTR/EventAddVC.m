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

@end

@implementation EventAddVC

@synthesize eventTitleField, eventDescriptionField, eventAttendersField;

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

- (void)createEvent:(id)sender {
    
    PFObject *newEvent = [PFObject objectWithClassName:@"Events"];
    newEvent[@"Title"] = self.eventTitleField.text;
    newEvent[@"Description"] = self.eventDescriptionField.text;

    NSNumberFormatter *numfromString = [[NSNumberFormatter alloc] init];
    NSNumber *attenders = [numfromString numberFromString:self.eventAttendersField.text];
    
    newEvent[@"Attenders"] = attenders;
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
