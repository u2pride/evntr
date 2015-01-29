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
#import "ProfileVC.h"
#import "EventDetailVC.h"

@interface HomeScreenVC ()

@end

@implementation HomeScreenVC

@synthesize userForEventsQuery, typeOfEventTableView;

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
        self.tabBarController.hidesBottomBarWhenPushed = YES;
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

}

- (void)objectsWillLoad {
    // TODO - THIS IS NOT GETTING CALLED WHEN USING THE NAVIGATION, but otherwise is getting called.
    // Switched from viewwillappear to objectswillload
    // Nevermind it is getting called, just after the queryForTable function... hmmm.
    NSLog(@"ObjectsWillLoad");
    
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
    
    //Return All Events for the Basic All Events View
    //Return a Specific Username's events when you are viewing someone's events.
    //TODO - not the best way to do this
    
    if (!userForEventsQuery) {
        self.userForEventsQuery = [PFUser currentUser];
    }
    
    PFQuery *allEvents;
    
    switch (typeOfEventTableView) {
        case 1: {
            allEvents = [PFQuery queryWithClassName:@"Events"];
            [allEvents orderByAscending:@"Title"];
            
            break;
        }
        case 2: {
            
            allEvents = [PFQuery queryWithClassName:@"Events"];
            [allEvents whereKey:@"parent" equalTo:userForEventsQuery];
            [allEvents orderByAscending:@"Title"];
            
            break;
        }
        case 3: {
            allEvents = [PFQuery queryWithClassName:@"Events"];
            [allEvents whereKey:@"parent" equalTo:userForEventsQuery];
            [allEvents orderByAscending:@"Title"];
            
            break;
        }
            
        default:
            break;
    }
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"pushEventDetails"]) {
        
        NSIndexPath *indexPathOfSelectedItem = [self.tableView indexPathForSelectedRow];
        EventDetailVC *eventDetailVC = segue.destinationViewController;
        
        PFObject *event = [self.objects objectAtIndex:indexPathOfSelectedItem.row];
        eventDetailVC.eventObject = event;
        
    } else if ([[segue identifier] isEqualToString:@"AddNewEvent"]) {
    
    }
    
    

}


@end
