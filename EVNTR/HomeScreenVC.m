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

@interface HomeScreenVC ()

@end

@implementation HomeScreenVC

- (id) initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Main View";
        self.parseClassName = @"Events";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.textKey = @"text";
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


#pragma mark - PFTableView Data & Custom Cells

- (PFQuery *)queryForTable {
    
    PFQuery *allEvents = [PFQuery queryWithClassName:@"Events"];
    [allEvents whereKey:@"parent" equalTo:[PFUser currentUser]];
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
    cell.eventTitle.text = [object objectForKey:@"Title"];
    cell.numberOfAttenders.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"Attenders"]];
    
    NSLog(@"%@", object);
    
    return cell;
    
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
