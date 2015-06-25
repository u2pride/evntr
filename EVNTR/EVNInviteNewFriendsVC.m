//
//  EVNInviteNewFriendsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 6/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteNewFriendsVC.h"
#import "EVNNoResultsView.h"
#import "EVNFacebookFriendCell.h"
#import "EVNUser.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface EVNInviteNewFriendsVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *facebookFriends;
@property (nonatomic, strong) NSString *moreFacebookFriendsURL;

@property (nonatomic, strong) EVNButtonExtended *buttonWithRefresh;

@end

static NSString *reuseIdentifier = @"CellIdentifier";

@implementation EVNInviteNewFriendsVC

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Find Your Friends";
        _facebookFriends = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    EVNNoResultsView *connectView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
    connectView.backgroundColor = [UIColor clearColor];
    connectView.headerText = @"Find Friends!";
    connectView.subHeaderText = @"Press the button below to connect with your Facebook Friends that also use Evntr.";
    connectView.actionButton.titleText = @"Connect";
    [connectView.actionButton addTarget:self action:@selector(requestFriendPermission) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectView];
    
    
    [self.tableView registerClass:[EVNFacebookFriendCell class] forCellReuseIdentifier:reuseIdentifier];
    
}


- (void) requestFriendPermission {
    
    // Request Friends Permission
    
    [self.view bringSubviewToFront:self.tableView];
    
    [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[ @"user_friends" ] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"User has friend access now!");
            
            [self additionalFriendsWithLimit:@5 andOffset:@0];
            
        } else {
            NSLog(@"failed with error: %@", error);
        }
    }];
    
}


- (void) additionalFriendsWithLimit:(NSNumber *)limit andOffset:(NSNumber *)offset {
    
    [self.buttonWithRefresh startedTask];
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    
    [friendsRequest.parameters setObject:limit forKey:@"limit"];
    [friendsRequest.parameters setObject:offset forKey:@"offset"];
    NSLog(@"friendsRequest params - %@", friendsRequest.parameters);
    
    FBRequestConnection *newRequestConnection = [[FBRequestConnection alloc] init];
    [newRequestConnection addRequest:friendsRequest completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSLog(@"Connection: %@", connection);
        NSLog(@"Results: %@", result);
        NSLog(@"Error: %@", error);
        
        if ([result objectForKey:@"paging"]) {
            NSLog(@"Next URL - %@", [result objectForKey:@"paging"]);
            self.moreFacebookFriendsURL = (NSString *)[[result objectForKey:@"paging"] objectForKey:@"next"];
        } else {
            self.moreFacebookFriendsURL = nil;
        }
        
        [self.facebookFriends addObjectsFromArray:[result objectForKey:@"data"]];
        
        [self.buttonWithRefresh endedTask];
        
        [self.tableView reloadData];
        
    }];
    
    [newRequestConnection start];
    
}


- (void) requestMoreFriends {
    
    NSURL *urlMore = [NSURL URLWithString:self.moreFacebookFriendsURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:urlMore completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSArray *moreFriends = [json objectForKey:@"data"];
        
        [self.facebookFriends addObjectsFromArray:moreFriends];
        [self.tableView reloadData];
        
        
    }] resume];
    
}

/*
- (void) followUserInEvntr:(id)sender {
    
    EVNButtonExtended *followButton = (EVNButtonExtended *)sender;
    
    NSString *facebookID = followButton.fbIdToFollow;
    
    //Possibly change to findUser (not plural) in background.
    PFQuery *findUserWithFBID = [PFUser query];
    [findUserWithFBID whereKey:@"facebookID" equalTo:facebookID];
    [findUserWithFBID findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects && !error) {
            
            EVNUser *userFollow = (EVNUser *)[objects firstObject];
            
            [[EVNUser currentUser] followUser:userFollow fromVC:self withButton:followButton withCompletion:^(BOOL success) {
            
                //never called - followUser method needs to call the completion block
                
            }];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"User Not Found" message:@"Looks like this user has gone missing.  Make sure they've downloaded the latest version." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
        
    }];
    
}
*/



#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EVNFacebookFriendCell *cell = (EVNFacebookFriendCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == self.facebookFriends.count) {
        NSLog(@"clicked for more");
        //[self requestMoreFriends];
        

        self.buttonWithRefresh = cell.followButton;
        
        [self additionalFriendsWithLimit:@5 andOffset:[NSNumber numberWithInteger:self.facebookFriends.count]];
        
    } else {
        
        
        [UIView animateWithDuration:0.3 animations:^{
            
            cell.friendNameLabel.alpha = 0.25;
            
        } completion:^(BOOL finished) {
           
            [UIView animateWithDuration:0.3 animations:^{
                
                cell.friendNameLabel.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                
            }];
            
        }];
        
        [self viewProfile:cell.followButton];
        
    }
    
}



#pragma mark - UITableViewDataSource Methods

- (EVNFacebookFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EVNFacebookFriendCell *theCell = (EVNFacebookFriendCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    theCell.followButton.layer.borderWidth = 0;
    
    if (indexPath.row == self.facebookFriends.count) {
        theCell.friendNameLabel.text = @"More";
        theCell.friendNameLabel.textColor = [UIColor orangeThemeColor];
        theCell.followButton.titleText = @"";
    } else {
        theCell.friendNameLabel.text = (NSString *)[[self.facebookFriends objectAtIndex:indexPath.row] objectForKey:@"name"];
        theCell.friendNameLabel.textColor = [UIColor blackColor];
        theCell.followButton.titleText = @"View";
        
        theCell.followButton.fbIdToFollow = (NSString *)[[self.facebookFriends objectAtIndex:indexPath.row] objectForKey:@"id"];
        
        [theCell.followButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        //[theCell.followButton addTarget:self action:@selector(followUserInEvntr:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    return theCell;
    
}

- (void) viewProfile:(id)sender {
    
    EVNButtonExtended *viewProfileButton = (EVNButtonExtended *)sender;
    
    [viewProfileButton startedTask];
    
    NSString *facebookID = viewProfileButton.fbIdToFollow;
    
    PFQuery *findUserQuery = [PFUser query];
    [findUserQuery whereKey:@"facebookID" equalTo:facebookID];
    [findUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            
            NSLog(@"object: %@", object);
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

            ProfileVC *userProfile = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            EVNUser *userForProfile = (EVNUser *) object;
            
            userProfile.userObjectID = userForProfile.objectId;
            
            [self.navigationController pushViewController:userProfile animated:YES];
            
            [viewProfileButton endedTask];
            
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Search Party" message:@"Looks like we can't find this user.  We're sending out a search party!" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [viewProfileButton endedTask];

        }
        
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"OURCOUNT: %lu", (unsigned long)self.facebookFriends.count);
    
    if (self.moreFacebookFriendsURL) {
        return self.facebookFriends.count + 1;
    } else {
        return self.facebookFriends.count;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}




@end
