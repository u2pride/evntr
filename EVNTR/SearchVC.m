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
#import "EVNUser.h"
#import "EventDetailVC.h"
#import "SearchHeaderView.h"
#import "ProfileVC.h"
#import "EventObject.h"
#import "UIColor+EVNColors.h"

@interface SearchVC ()

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic, strong) NSMutableArray *searchResultsArray;

@property (nonatomic, strong) SearchHeaderView *searchTypeSelectionView;
@property (nonatomic) BOOL isSearchingEvents;

@end


@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.navigationController.definesPresentationContext = YES;
    self.definesPresentationContext = YES;
    
    self.title = @"Search";
    self.searchResultsArray = [[NSMutableArray alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    self.isSearchingEvents = YES;
    
    self.searchResultsTable.delegate = self;
    self.searchResultsTable.dataSource = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"";
    self.searchController.searchBar.text = @"";
    self.searchController.searchBar.delegate = self;

    //Tint Color for Cancel on Search Bar
    [self.searchController.searchBar setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor orangeThemeColor]];
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.searchTypeSelectionView = [[SearchHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];

    self.searchResultsTable.tableHeaderView = self.searchTypeSelectionView;
    
    UITapGestureRecognizer *tapEvents = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSearchType:)];
    UITapGestureRecognizer *tapPeople = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSearchType:)];

    self.searchTypeSelectionView.eventLabel.userInteractionEnabled = YES;
    self.searchTypeSelectionView.peopleLabel.userInteractionEnabled = YES;

    [self.searchTypeSelectionView.eventLabel addGestureRecognizer:tapEvents];
    [self.searchTypeSelectionView.peopleLabel addGestureRecognizer:tapPeople];


    
}




- (void) toggleSearchType:(id)sender {
    
    NSLog(@"sender: %@", sender);
    UITapGestureRecognizer *senderTapGR = (UITapGestureRecognizer *)sender;
    
    UILabel *senderLabel = (UILabel *) senderTapGR.view;
    
    NSLog(@"sender2: %@", senderLabel);
    
    if (senderLabel == self.searchTypeSelectionView.eventLabel) {
        self.isSearchingEvents = YES;
        self.searchTypeSelectionView.eventLabel.textColor = [UIColor orangeThemeColor];
        self.searchTypeSelectionView.peopleLabel.textColor = [UIColor blackColor];

    } else {
        self.isSearchingEvents = NO;
        self.searchTypeSelectionView.eventLabel.textColor = [UIColor blackColor];
        self.searchTypeSelectionView.peopleLabel.textColor = [UIColor orangeThemeColor];

    }
    
    self.searchController.searchBar.text = @"";
    self.searchResultsArray = [[NSMutableArray alloc] init];
    [self.searchResultsTable reloadData];
    

}


#pragma mark -
#pragma mark - UISearchResultsUpdating Delegate Method

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (self.searchController.searchBar.text.length > 0) {
        
        if (self.isSearchingEvents) {
            
            NSDate *currentDateMinusOneDay = [NSDate dateWithTimeIntervalSinceNow:-86400];
            
            PFQuery *searchQuery = [PFQuery queryWithClassName:@"Events"];
            [searchQuery whereKey:@"title" containsString:self.searchController.searchBar.text];
            [searchQuery whereKey:@"typeOfEvent" notEqualTo:[NSNumber numberWithInt:PRIVATE_EVENT_TYPE]];
            [searchQuery whereKey:@"dateOfEvent" greaterThanOrEqualTo:currentDateMinusOneDay]; /* Grab Events in the Future and Ones Within 24 Hours in Past */
            [searchQuery orderByDescending:@"updatedAt"];
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.searchResultsArray = [NSMutableArray arrayWithArray:objects];
                [self.searchResultsTable reloadData];
            }];
            
        } else {
            
            PFQuery *peopleSearchQuery = [EVNUser query];
            [peopleSearchQuery whereKey:@"username" matchesRegex:self.searchController.searchBar.text modifiers:@"i"];
            //[peopleSearchQuery whereKey:@"username" containsString:self.searchController.searchBar.text];
            //[peopleSearchQuery whereKey:@"realName" containsString:self.searchController.searchBar.text];
            [peopleSearchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.searchResultsArray = [NSMutableArray arrayWithArray:objects];
                [self.searchResultsTable reloadData];
                
                NSLog(@"query: %@ and results %@", peopleSearchQuery, objects);
            }];
            
        }
        
    }
    
}


#pragma mark -
#pragma mark - Search Results Table View Delegate and DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"searchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    if (self.isSearchingEvents) {
        
        cell.textLabel.font = [UIFont fontWithName:EVNFontRegular size:15];
        
        EventObject *currentObject = (EventObject *)[self.searchResultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = currentObject.title;
        
    } else {
        
        cell.textLabel.font = [UIFont fontWithName:EVNFontRegular size:15];
        
        EVNUser *currentUser = (EVNUser *) [self.searchResultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = currentUser.username;
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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
    
    if (self.isSearchingEvents) {
        
        EventObject *event = [self.searchResultsArray objectAtIndex:selectedIndexPath.row];
        
        EventDetailVC *eventVC = (EventDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
        
        eventVC.event = event;
        
        [self.navigationController pushViewController:eventVC animated:YES];
        
    } else {
        
        EVNUser *selectedUser = [self.searchResultsArray objectAtIndex:selectedIndexPath.row];
        
        ProfileVC *profileVC = (ProfileVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileVC.userObjectID = selectedUser.objectId;
        
        [self.navigationController pushViewController:profileVC animated:YES];
        
    }

}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.searchController.searchBar sizeToFit];
    
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    //self.searchController.active = NO;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.searchController.searchBar sizeToFit];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //self.searchController.active = NO;

    //[self.searchController.searchBar resignFirstResponder];
    
}

-(void)dealloc {
    NSLog(@"searchvc is being deallocated");
}



@end
