//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "HomeScreenVC.h"
#import <Parse/Parse.h>
#import "SWRevealViewController.h"
#import <ParseUI/ParseUI.h>
#import "EventTableCell.h"
#import "EventDetailVC.h"

@interface HomeScreenVC ()

@property (nonatomic, strong) PFObject *selectedEvent;

@end

@implementation HomeScreenVC

@synthesize userForEventsQuery, typeOfEventTableView, selectedEvent;

- (id) initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Main View";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.textKey = @"text";
        self.typeOfEventTableView = 1;
        self.userForEventsQuery = [PFUser currentUser];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    



    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // TODO - THIS IS NOT GETTING CALLED WHEN USING THE NAVIGATION, but otherwise is getting called.
    // Nevermind it is getting called, just after the queryForTable function... hmmm.
    NSLog(@"ViewWillAppear");
    if (self.typeOfEventTableView == 2 || self.typeOfEventTableView == 3) {
        NSLog(@"Inside");
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(returnToProfile)];
        
        
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
}


- (void)returnToProfile {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    NSLog(@"THIS IS THE USER:  %@", userForEventsQuery);
    
    if (!userForEventsQuery) {
        self.userForEventsQuery = [PFUser currentUser];
    }
    
    PFQuery *allEvents = [PFQuery queryWithClassName:@"Events"];
    [allEvents whereKey:@"parent" equalTo:userForEventsQuery];
    [allEvents orderByAscending:@"Title"];
    
    return allEvents;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    
    if (cell == nil) {
         cell = [[EventTableCell alloc] init];
    }
    
    cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
    cell.eventCoverImage.file = (PFFile *)[object objectForKey:@"coverPhoto"];
    [cell.eventCoverImage loadInBackground];
    cell.eventTitle.text = [object objectForKey:@"title"];
    cell.numberOfAttenders.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"attenders"]];
    
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.objects.count) {
        PFObject *event = [self.objects objectAtIndex:indexPath.row];
        selectedEvent = event;
    } else if (self.paginationEnabled) {
        [self loadNextPage];
    }
    
    //[super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    NSLog(@"Selected Event: %@", selectedEvent);
    
    [self performSegueWithIdentifier:@"PushEventDetails" sender:self];
    
}
 


// TODO:  Reset typeOfEventTableView on dismissal of the view



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"PrepareforSegue");
    
    if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        NSLog(@"AddNewEventSegue");

    } else if ([[segue identifier] isEqualToString:@"PushEventDetails"]) {
        NSLog(@"DetailEventViewSegue");
        NSLog(@"selected event: %@", selectedEvent);
        EventDetailVC *eventDetailVC = (EventDetailVC *)[segue destinationViewController];
        eventDetailVC.eventObject = selectedEvent;
        
    }
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
