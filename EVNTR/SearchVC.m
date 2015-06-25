//
//  SearchVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNInviteNewFriendsVC.h"
#import "EVNUser.h"
#import "EventDetailVC.h"
#import "EventObject.h"
#import "ProfileVC.h"
#import "SearchHeaderView.h"
#import "SearchVC.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>

@interface SearchVC ()

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResultsArray;

@property (nonatomic, strong) SearchHeaderView *searchTypeSelectionView;
@property (nonatomic, strong) UIActivityIndicatorView *activitySpinner;
@property (nonatomic) BOOL isSearchingEvents;

@end


@implementation SearchVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
    self.isSearchingEvents = YES;
    self.hidesBottomBarWhenPushed = YES;
    self.searchResultsArray = [[NSMutableArray alloc] init];

    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Needed to Avoid Home Disappearing After UISearchController Presented and Tabbing Over to Another VC and Back
    self.navigationController.definesPresentationContext = YES;
    self.definesPresentationContext = YES;
    
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

    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activitySpinner.hidesWhenStopped = YES;
    self.activitySpinner.center = self.searchResultsTable.tableHeaderView.center;
    
    [self.view addSubview:self.activitySpinner];
    
}


#pragma mark - User Actions

- (void) toggleSearchType:(id)sender {
    
    UITapGestureRecognizer *senderTapGR = (UITapGestureRecognizer *)sender;
    
    UILabel *senderLabel = (UILabel *) senderTapGR.view;
    
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
    [self.searchResultsArray removeAllObjects];
    [self.searchResultsTable reloadData];
    
}


#pragma mark - UISearchResultsUpdating Delegate Method

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (self.searchController.searchBar.text.length > 0) {
        
        [self.activitySpinner startAnimating];
        self.searchResultsTable.allowsSelection = NO;
        
        if (self.isSearchingEvents) {
            
            NSDate *currentDateMinusOneDay = [NSDate dateWithTimeIntervalSinceNow:-86400];
            
            PFQuery *searchQuery = [PFQuery queryWithClassName:@"Events"];
            [searchQuery whereKey:@"title" matchesRegex:self.searchController.searchBar.text modifiers:@"i"];
            [searchQuery whereKey:@"typeOfEvent" notEqualTo:[NSNumber numberWithInt:PRIVATE_EVENT_TYPE]];
            [searchQuery whereKey:@"dateOfEvent" greaterThanOrEqualTo:currentDateMinusOneDay]; /* Grab Events in the Future and Ones Within 24 Hours in Past */
            [searchQuery orderByDescending:@"updatedAt"];
            [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                self.searchResultsArray = [NSMutableArray arrayWithArray:objects];
                [self.searchResultsTable reloadData];
                [self.activitySpinner stopAnimating];
                self.searchResultsTable.allowsSelection = YES;
                
            }];
            
        } else {
            
            PFQuery *peopleSearchQuery = [EVNUser query];
            [peopleSearchQuery whereKey:@"username" matchesRegex:self.searchController.searchBar.text modifiers:@"i"];
            [peopleSearchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                self.searchResultsArray = [NSMutableArray arrayWithArray:objects];
                [self.searchResultsTable reloadData];
                [self.activitySpinner stopAnimating];
                self.searchResultsTable.allowsSelection = YES;
                
            }];
        }
    }
}


#pragma mark - Table View Delegate and DataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"searchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    if (self.searchResultsArray.count == 0) {
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"No Results";
            
        } else {
            
            cell.textLabel.text = @"Find Your Friends!";
        }
        
    } else {
        
        if (self.isSearchingEvents) {
            
            EventObject *currentObject = (EventObject *)[self.searchResultsArray objectAtIndex:indexPath.row];
            
            if (currentObject.title) {
                cell.textLabel.text = currentObject.title;
            }
            
        } else {
            
            EVNUser *currentUser = (EVNUser *) [self.searchResultsArray objectAtIndex:indexPath.row];
            
            if (currentUser.username) {
                cell.textLabel.text = currentUser.username;
            }
            
        }
        
        
    }

    
    cell.textLabel.font = [UIFont fontWithName:EVNFontRegular size:15];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchResultsArray.count == 0) {
        return 2;
    } else {
        return self.searchResultsArray.count;
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    
    if (!self.searchResultsArray.count == 0) {
        
        if (self.isSearchingEvents) {
            
            EventObject *event = [self.searchResultsArray objectAtIndex:selectedIndexPath.row];
            
            EventDetailVC *eventVC = (EventDetailVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
            
            eventVC.event = event;
            eventVC.delegate = self;
            
            [self.navigationController pushViewController:eventVC animated:YES];
            
        } else {
            
            EVNUser *selectedUser = [self.searchResultsArray objectAtIndex:selectedIndexPath.row];
            
            ProfileVC *profileVC = (ProfileVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            
            profileVC.userObjectID = selectedUser.objectId;
            
            [self.navigationController pushViewController:profileVC animated:YES];
            
        }
        
    } else {
        
        if (selectedIndexPath.row == 1) {
            
            EVNInviteNewFriendsVC *inviteVC = [[EVNInviteNewFriendsVC alloc] init];
            
            [self.navigationController pushViewController:inviteVC animated:YES];
                        
        }
        
    }
    
    self.searchController.active = NO;


}


#pragma mark - UISearchBar Delegate Methods

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.searchController.searchBar sizeToFit];
    
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.searchController.searchBar sizeToFit];
}



@end
