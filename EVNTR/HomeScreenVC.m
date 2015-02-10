//
//  HomeScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"
#import "EventTableCell.h"
#import "HomeScreenVC.h"
#import "ProfileVC.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "EVNConstants.h"

@interface HomeScreenVC ()

@end

@implementation HomeScreenVC

@synthesize userForEventsQuery, typeOfEventTableView, isComingFromNavigation;

//Question:  What's best to do in initWithCoder v. ViewDidLoad?
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Events";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        self.userForEventsQuery = [PFUser currentUser];
        self.tabBarController.hidesBottomBarWhenPushed = YES;
        self.isComingFromNavigation = NO;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isComingFromNavigation) {
        
        SWRevealViewController *revealViewController = self.revealViewController;
        
        if (revealViewController) {
            [self.sidebarButton setTarget: self.revealViewController];
            [self.sidebarButton setAction: @selector(revealToggle:)];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
        
    } else {
        //setup view when viewing events from profiles - Probably don't need this.
        
        //Remove Navigation Menu and Other Bar Button Items so Back Button Appears.
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = nil;
        /*
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(returnToProfile)];
        
        self.navigationItem.rightBarButtonItem = cancelButton;
         */
    }
    
    
    NSLog(@"type: %d", self.typeOfEventTableView);
    
    switch (self.typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            [self.navigationItem setTitle:@"Public Events"];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            NSLog(@"EventsView - My Events");
            [self.navigationItem setTitle:@"My Events"];
            
            break;
        }
        case OTHER_USER_EVENTS: {
            NSLog(@"EventsView - User Events");
            [self.navigationItem setTitle:@"User Events"];
            
            break;
        }
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)objectsWillLoad {
    // TODO - THIS IS NOT GETTING CALLED WHEN USING THE NAVIGATION, but otherwise is getting called.
    // Nevermind it is getting called, just after the queryForTable function... hmmm.
}


//- (void)returnToProfile {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    
//}


#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    //Return All Events for the Basic All Events View
    //Return a Specific Username's events when you are viewing someone's events.
    
    PFQuery *eventsQuery;
    
    switch (typeOfEventTableView) {
        case ALL_PUBLIC_EVENTS: {
            eventsQuery = [PFQuery queryWithClassName:@"Events"];
            [eventsQuery orderByDescending:@"createdAt"];
            [eventsQuery whereKey:@"typeOfEvent" equalTo:[NSNumber numberWithInt:PUBLIC_EVENT_TYPE]];
            
            break;
        }
        case CURRENT_USER_EVENTS: {
            
            eventsQuery = [PFQuery queryWithClassName:@"Events"];
            [eventsQuery whereKey:@"parent" equalTo:userForEventsQuery];
            [eventsQuery orderByAscending:@"Title"];
            
            break;
        }
        case OTHER_USER_EVENTS: {
            eventsQuery = [PFQuery queryWithClassName:@"Events"];
            [eventsQuery whereKey:@"parent" equalTo:userForEventsQuery];
            [eventsQuery orderByAscending:@"Title"];
            
            break;
        }
            
        default:
            break;
    }
    
    return eventsQuery;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *cellIdentifier = @"eventCell";
    
    EventTableCell *cell = (EventTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.eventCoverImage.image = [UIImage imageNamed:@"EventDefault"];
        cell.eventCoverImage.file = (PFFile *)[object objectForKey:@"coverPhoto"];
        [cell.eventCoverImage loadInBackground];
        cell.eventTitle.text = [object objectForKey:@"title"];
        //cell.numberOfAttenders.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"attenders"]];
    }
    
    
    return cell;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //open view with the event details
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        
        PFObject *event = [self.objects objectAtIndex:indexPathOfSelectedItem.row];
        eventDetailVC.eventObject = event;
        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
        //nothing needed yet
        
    }
    
}


@end
