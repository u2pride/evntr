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

@property (nonatomic, strong) PFUser *eventUser;

@end

@implementation EventDetailVC

@synthesize eventTitle, eventCoverPhoto, creatorName, creatorPhoto, eventDescription, eventObject, eventUser, dateOfEventLabel, loadingSpinner;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.center = self.view.center;
    [self.view addSubview:self.loadingSpinner];
    [self.loadingSpinner startAnimating];
    
    //[self startLoadingAnimationAndBlur];
    
    
    // Do any additional setup after loading the view.
    creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    eventCoverPhoto.image = [UIImage imageNamed:@"EventDefault"];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    eventUser = (PFUser *)eventObject[@"parent"];
    [eventUser fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        creatorName.text = user[@"username"];
        creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [creatorPhoto loadInBackground];
    }];
    
    NSLog(@"Event: %@ and User: %@", eventObject, eventUser);

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"cccc, MMM d, hh:mm aa"];
    NSDate *dateFromParse = (NSDate *)eventObject[@"dateOfEvent"];
    
    NSString *stringDate = [dateFormatter stringFromDate:dateFromParse];

    eventTitle.text = eventObject[@"title"];
    dateOfEventLabel.text = stringDate;
    eventDescription.text = eventObject[@"description"];
    eventCoverPhoto.file = (PFFile *)eventObject[@"coverPhoto"];
    [eventCoverPhoto loadInBackground];
    
    [self.loadingSpinner stopAnimating];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Loading View
- (void)startLoadingAnimationAndBlur {
    NSLog(@"Blur");
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    NSLog(@"Frame W: %f", visualEffectView.frame.size.width);
    NSLog(@"Frame H: %f", visualEffectView.frame.size.height);
    NSLog(@"Frame X: %f", visualEffectView.frame.origin.x);
    NSLog(@"Frame Y: %f", visualEffectView.frame.origin.y);

    [visualEffectView setFrame:self.view.bounds];
    
    NSLog(@"Frame W: %f", visualEffectView.frame.size.width);
    NSLog(@"Frame H: %f", visualEffectView.frame.size.height);
    NSLog(@"Frame X: %f", visualEffectView.frame.origin.x);
    NSLog(@"Frame Y: %f", visualEffectView.frame.origin.y);
    
    
    [self.view addSubview:visualEffectView];
    
}

- (void)stopLoadingAnimationAndBlur {
    
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
