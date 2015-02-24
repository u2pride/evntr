//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"
#import "PeopleVC.h"
#import "EVNUtility.h"

@interface EventDetailVC ()

@property (nonatomic, strong) PFUser *eventUser;
@property (weak, nonatomic) IBOutlet UIButton *rsvpButton;

- (IBAction)rsvpForEvent:(id)sender;
- (IBAction)viewEventAttenders:(id)sender;

@end

@implementation EventDetailVC

@synthesize eventTitle, eventCoverPhoto, creatorName, creatorPhoto, eventDescription, eventObject, eventUser, dateOfEventLabel, loadingSpinner, eventLocationLabel, rsvpButton;


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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSString *username = [[PFUser currentUser] objectForKey:@"username"];
    
    PFRelation *eventAttendersRelation = [eventObject relationForKey:@"attenders"];
    PFQuery *attendingQuery = [eventAttendersRelation query];
    [attendingQuery whereKey:@"username" equalTo:username];
    
    [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSLog(@"Result of Query: %@", object);
        
        if (object) {
            NSLog(@"Currently Attending Event");

            [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
            
        } else {
            NSLog(@"Not Currently Attending Event");
            
            [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
        }
        
    }];
    
    
    /*
    //Determine if the user is Attending Event Already
    PFQuery *queryForCurrentAttendingStatus = [PFQuery queryWithClassName:@"Events"];
    [queryForCurrentAttendingStatus whereKey:@"attenders" containsAllObjectsInArray:@[[PFUser currentUser]]];
    
    [queryForCurrentAttendingStatus getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        

        
    }];
    
    */
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    eventUser = (PFUser *)eventObject[@"parent"];
    [eventUser fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        creatorName.text = user[@"username"];
        creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
            creatorPhoto.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
        }];
    }];
    
    NSLog(@"Event: %@ and User: %@", eventObject, eventUser);

    NSDate *dateFromParse = (NSDate *)eventObject[@"dateOfEvent"];
    
    NSDateFormatter *df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:@"MM/dd 'at' hh:mm a"];
    
    NSString *localDateString = [df_local stringFromDate:dateFromParse];

    //PFGeoPoint *locationOfEvent = eventObject[@"locationOfEvent"];
    //NSString *locationText = [NSString stringWithFormat:@"Lat: %.02f Long: %.02f", locationOfEvent.latitude, locationOfEvent.longitude];
    //eventLocationLabel.text = locationText;
    
    eventTitle.text = eventObject[@"title"];
    dateOfEventLabel.text = localDateString;
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

- (IBAction)rsvpForEvent:(id)sender {
    
    PFRelation *attendersRelation = [self.eventObject relationForKey:@"attenders"];
    NSLog(@"PFRelation: %@", attendersRelation);

    if ([rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
        
        NSLog(@"Removing PFRelation");

        [attendersRelation removeObject:[PFUser currentUser]];
        [eventObject saveInBackground];
        
        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
        
    } else {
        
        NSLog(@"Adding PFRelation");
        
        //Create New Relation and Add User to List of Attenders for Event
        [attendersRelation addObject:[PFUser currentUser]];
        [eventObject saveInBackground];
        
        [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
    }
    


}

- (IBAction)viewEventAttenders:(id)sender {
    
    PeopleVC *viewAttendees = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    
    viewAttendees.typeOfUsers = VIEW_EVENT_ATTENDERS;
    viewAttendees.eventToViewAttenders = eventObject;
    
    [self.navigationController pushViewController:viewAttendees animated:YES];
    
}



@end
