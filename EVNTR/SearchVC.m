//
//  SearchVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SearchVC.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"
#import "EventDetailVC.h"

@interface SearchVC ()

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic, strong) NSMutableArray *searchResultsArray;

@end

//TODO: Support iOS7 for searching.
@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
    self.searchResultsArray = [[NSMutableArray alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    
    self.searchResultsTable.delegate = self;
    self.searchResultsTable.dataSource = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchResultsTable.tableHeaderView = self.searchController.searchBar;
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
}




#pragma mark -
#pragma mark - UISearchResultsUpdating Delegate Method

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {

    PFQuery *searchQuery = [PFQuery queryWithClassName:@"Events"];
    [searchQuery whereKey:@"title" containsString:self.searchController.searchBar.text];
    [searchQuery whereKey:@"typeOfEvent" notEqualTo:[NSNumber numberWithInt:PRIVATE_EVENT_TYPE]];
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResultsArray = [NSMutableArray arrayWithArray:objects];
        [self.searchResultsTable reloadData];
    }];
    
}



#pragma mark -
#pragma mark - Search Results Table View Delegate and DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"searchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    
    PFObject *currentObject = [self.searchResultsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [currentObject objectForKey:@"title"];
    
    return cell;
    
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultsArray.count;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.searchController.active = NO;
    
    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    PFObject *selectedObject = [self.searchResultsArray objectAtIndex:selectedIndexPath.row];
    
    EventDetailVC *eventVC = (EventDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    eventVC.eventObject = selectedObject;
    
    [self.navigationController pushViewController:eventVC animated:YES];
    
}



@end
