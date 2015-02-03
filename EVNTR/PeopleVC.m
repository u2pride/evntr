//
//  PeopleVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "PeopleVC.h"
#import <Parse/Parse.h>
#import "PersonCell.h"
#import <CoreGraphics/CoreGraphics.h>
#import "EVNUtility.h"
#import "EVNConstants.h"
#import "ProfileVC.h"

@interface PeopleVC ()

@property (nonatomic, strong) NSArray *selectedPeople;

@end

@implementation PeopleVC

@synthesize typeOfUsers, profileUsername, loadingSpinner;

#pragma mark -
#pragma mark Init

- (void) viewDidLoad {
    [super viewDidLoad];
    //Maybe this is the part of the problem.
    //self.typeOfUsers = VIEW_ALL_PEOPLE;
    //self.profileUsername = nil;
    //[self findUsersOnParse];
    
    //Minor UI Adjustments
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.center = self.view.center;
    [self.view addSubview:self.loadingSpinner];
    [self.loadingSpinner startAnimating];
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {
        UIButton *doneSelectingInvitationsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [doneSelectingInvitationsButton addTarget:self action:@selector(doneSelectingPeopleToInvite) forControlEvents:UIControlEventTouchUpInside];
        [doneSelectingInvitationsButton setTitle:@"DONE" forState:UIControlStateNormal];
        doneSelectingInvitationsButton.frame = CGRectMake(0, 200, 100, 50);
        [self.view addSubview:doneSelectingInvitationsButton];
        
        self.collectionView.allowsMultipleSelection = YES;
    }
    
    //Start Looking for Users
    [self findUsersOnParse];

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)findUsersOnParse {
    
    usersArray = [[NSArray alloc] init];
    usersMutableArray = [[NSMutableArray alloc] init];
    
    switch (typeOfUsers) {
        case VIEW_ALL_PEOPLE: {
            
            PFQuery *query = [PFUser query];
            [query orderByAscending:@"username"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                usersArray = [[NSArray alloc] initWithArray:usersFound];
                [self.collectionView reloadData];
                
            }];
            
            break;
        }
        case VIEW_FOLLOWERS: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"to" equalTo:profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            [query selectKeys:@[@"from"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                NSLog(@"RESULTS OF VIEW_FOLLOWERS QUERY: %@", usersFound);
                
                for (PFObject *object in usersFound) {
                    [usersMutableArray addObject:object[@"from"]];
                }
                usersArray = usersMutableArray;
                
                NSLog(@"Results Given to UICollectionView: %@", usersArray);

                
                [self.collectionView reloadData];
            }];
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"from" equalTo:profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                for (PFObject *object in usersFound) {
                    [usersMutableArray addObject:object[@"to"]];
                }
                
                usersArray = usersMutableArray;
                
                NSLog(@"Results Given to UICollectionView: %@", usersArray);
                
                [self.collectionView reloadData];
            }];
            
            break;
        }
            
        case VIEW_FOLLOWING_TO_INVITE: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"from" equalTo:profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                for (PFObject *object in usersFound) {
                    [usersMutableArray addObject:object[@"to"]];
                }
                
                usersArray = usersMutableArray;
                
                NSLog(@"Results Given to UICollectionView: %@", usersArray);
                
                [self.collectionView reloadData];
            }];

            break;
        }
        default:
            break;
    }
    
    [self.loadingSpinner stopAnimating];
}

#pragma mark -
#pragma mark CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [usersArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"personCell";
    
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFUser *currentUser = (PFUser *)[usersArray objectAtIndex:indexPath.row];
    
    NSLog(@"Current User: %@", currentUser);
    
    //Default Profile Pic Until User Information is Fetched in Background
    cell.profileImage.image = [UIImage imageNamed:@"PersonDefault"];
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        cell.profileImage.file = (PFFile *)object[@"profilePicture"];
        cell.personTitle.text = object[@"username"];
        [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
            cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
            
        }];
    }];
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {

        PersonCell *cell = (PersonCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.profileImage.image = [EVNUtility maskImage:cell.profileImage.image withMask:[UIImage imageNamed:@"MaskImageSelected"]];
        
    } else {
        
        PFUser *selectedUser = (PFUser *)[usersArray objectAtIndex:indexPath.row];
        
        ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        viewUserProfileVC.userNameForProfileView = selectedUser[@"username"];
        
        [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    }
    
}


#pragma mark -
#pragma mark - EventAddVCDelegate Methods

- (void)doneSelectingPeopleToInvite {
    
    NSMutableArray *selectedPeople = [[NSMutableArray alloc] init];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *currentIndex = indexPaths[i];
        PFUser *selectedUser = (PFUser *)[usersArray objectAtIndex:currentIndex.row];
        [selectedPeople addObject:selectedUser];
    }
    
    id<PeopleVCDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(finishedSelectingInvitations:)]) {
        [strongDelegate finishedSelectingInvitations:selectedPeople];
    }
    
}

/*
- (NSArray *)finishedSelectingInvitations {
    
    NSMutableArray *selectedPeople = [[NSMutableArray alloc] init];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *currentIndex = indexPaths[i];
        PFUser *selectedUser = (PFUser *)[usersArray objectAtIndex:currentIndex.row];
        [selectedPeople addObject:selectedUser];
    }
    
    return selectedPeople;
    
    
}

*/


@end


