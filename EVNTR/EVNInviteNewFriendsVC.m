//
//  EVNInviteNewFriendsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 6/24/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNFacebookFriendCell.h"
#import "EVNInviteNewFriendsVC.h"
#import "EVNNoResultsView.h"
#import "EVNUser.h"
#import "EVNUtility.h"
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

#pragma mark - Initialization Methods

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _facebookFriends = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}


#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tableView registerClass:[EVNFacebookFriendCell class] forCellReuseIdentifier:reuseIdentifier];
    
    EVNNoResultsView *connectView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
    connectView.offsetY = 100;
    connectView.headerText = @"Facebook Friends";
    connectView.subHeaderText = @"Connect with your Facebook Friends that are on Evntr.";
    connectView.actionButton.titleText = @"Find Friends";
    [connectView.actionButton addTarget:self action:@selector(requestFriendPermission) forControlEvents:UIControlEventTouchUpInside];
    //[connectView.actionButton addTarget:self action:@selector(sendInviteMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:connectView];

    
}


- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
}



#pragma mark - Helper Methods

- (void) fadeInView:(UIView *)viewFade {
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [self.view bringSubviewToFront:viewFade];
        
        [UIView animateWithDuration:1.25 animations:^{
            
            self.view.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            
        }];
        
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



#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.facebookFriends.count > 0) {
        
        EVNFacebookFriendCell *cell = (EVNFacebookFriendCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == self.facebookFriends.count) {
            self.buttonWithRefresh = cell.viewButton;
            [self additionalFriendsWithLimit:@15 andOffset:[NSNumber numberWithInteger:self.facebookFriends.count]];
            
        } else {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                cell.friendNameLabel.alpha = 0.25;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    cell.friendNameLabel.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    
                    
                }];
                
            }];
            
            [self viewProfile:cell.viewButton];
            
        }
        
    }

}



#pragma mark - UITableViewDataSource Methods

- (EVNFacebookFriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EVNFacebookFriendCell *theCell = (EVNFacebookFriendCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    theCell.viewButton.layer.borderWidth = 0;
    
    
    if (self.facebookFriends.count == 0) {
        
        theCell.friendNameLabel.text = @"No Friends Found";
        theCell.viewButton.titleText = @"";
        
    } else {
        
        if (indexPath.row == self.facebookFriends.count) {
            theCell.friendNameLabel.text = @"More";
            theCell.friendNameLabel.textColor = [UIColor orangeThemeColor];
            theCell.viewButton.titleText = @"";
        } else {
            theCell.friendNameLabel.text = (NSString *)[[self.facebookFriends objectAtIndex:indexPath.row] objectForKey:@"name"];
            theCell.friendNameLabel.textColor = [UIColor blackColor];
            theCell.viewButton.titleText = @"View";
            
            theCell.viewButton.fbIdToFollow = (NSString *)[[self.facebookFriends objectAtIndex:indexPath.row] objectForKey:@"id"];
            
            [theCell.viewButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }
    
    return theCell;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!self.facebookFriends) {
        
        return 0;
        
    } else if (self.facebookFriends.count == 0) {
        
        return 1;
        
    } else {
        
        if (self.moreFacebookFriendsURL) {
            return self.facebookFriends.count + 1;
        } else {
            return self.facebookFriends.count;
        }
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


#pragma mark - User Actions

- (void) requestFriendPermission {
    
    [self fadeInView:self.tableView];
    
    [PFFacebookUtils linkUser:[EVNUser currentUser] permissions:@[ @"user_friends" ] block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
               
                if (!error) {
                    
                    // Store the current user's Facebook ID on the user
                    [[EVNUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"facebookID"];
                    [[EVNUser currentUser] saveInBackground];
                }
            
            }];
            
            [self additionalFriendsWithLimit:@15 andOffset:@0];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like we can't connect with your Facebook account.  Connect us from the Settings page for help." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
    }];
    
}


//Currrently:  Pulls back friends from facebook that use evntr (me/friends)
//Future:  Links the friends pulled back with Parse accounts before displaying (and enable following from this screen).
- (void) viewProfile:(id)sender {
    
    EVNButtonExtended *viewProfileButton = (EVNButtonExtended *)sender;
    
    [viewProfileButton startedTask];
    
    NSString *facebookID = viewProfileButton.fbIdToFollow;
    
    PFQuery *findUserQuery = [PFUser query];
    [findUserQuery whereKey:@"facebookID" equalTo:facebookID];
    [findUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
                        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

            ProfileVC *userProfile = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            EVNUser *userForProfile = (EVNUser *) object;
            
            userProfile.userObjectID = userForProfile.objectId;
            
            [self.navigationController pushViewController:userProfile animated:YES];
            
            [viewProfileButton endedTask];
            
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"User Not Found" message:@"Looks like this user is no longer using Evntr." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            
            [errorAlert show];
            
            [viewProfileButton endedTask];

        }
        
    }];
    
    
}


@end
