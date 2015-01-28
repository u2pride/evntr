//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"
#import <Parse/Parse.h>

@interface EventDetailVC ()

@end

@implementation EventDetailVC

@synthesize eventTitle, eventCoverPhoto, creatorName, creatorPhoto, eventDescription, eventObject, eventUser;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    eventUser = (PFUser *)eventObject[@"parent"];
    
    eventTitle.text = eventObject[@"title"];
    eventDescription.text = eventObject[@"description"];
    eventCoverPhoto.image = [UIImage imageNamed:@"EventDefault"];
    eventCoverPhoto.file = (PFFile *)eventObject[@"coverPhoto"];
    [eventCoverPhoto loadInBackground];
    
    creatorName.text = eventUser[@"username"];
    creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    creatorPhoto.file = (PFFile *)eventUser[@"profilePicture"];
    [creatorPhoto loadInBackground];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
