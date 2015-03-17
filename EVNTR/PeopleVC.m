//
//  PeopleVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNUtility.h"
#import "PeopleVC.h"
#import "PersonCell.h"
#import "ProfileVC.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Parse/Parse.h>


@interface PeopleVC ()

@property (nonatomic, strong) NSArray *selectedPeople;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

@property (nonatomic, strong) NSMutableArray *usersMutableArray;
@property (nonatomic, strong) NSArray *usersArray;


//TODO: Delete. Use for testing.
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end


@implementation PeopleVC

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    
    //Maybe this is the part of the problem.
    //self.typeOfUsers = VIEW_ALL_PEOPLE;
    //self.profileUsername = nil;
    //[self findUsersOnParse];
    
    self.selectedIndexes = [[NSMutableArray alloc] init];
    
    switch (self.typeOfUsers) {
        case VIEW_ALL_PEOPLE: {
            
            [self.navigationItem setTitle:@"All People"];
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        case VIEW_FOLLOWERS: {
            
            [self.navigationItem setTitle:@"Followers"];
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            [self.navigationItem setTitle:@"Following"];
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        case VIEW_FOLLOWING_TO_INVITE: {
            
            [self.navigationItem setTitle:@"Invite"];
            
            UIButton *doneSelectingInvitationsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [doneSelectingInvitationsButton addTarget:self action:@selector(doneSelectingPeopleToInvite) forControlEvents:UIControlEventTouchUpInside];
            [doneSelectingInvitationsButton setTitle:@"DONE" forState:UIControlStateNormal];
            [self.view addSubview:doneSelectingInvitationsButton];
            doneSelectingInvitationsButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            self.bottomConstraint = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-80.f];
            
            [self.view addConstraint:self.bottomConstraint];
            
            NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
            
            [self.view addConstraint:constraint2];
            
            NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:200.0f];
            
            [self.view addConstraint:constraint3];
            
            
            
            self.collectionView.allowsMultipleSelection = YES;
            
            break;
        }
        case VIEW_EVENT_ATTENDERS: {
            
            [self.navigationItem setTitle:@"Attendees"];
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        default: {
            break;
        }
    }
    
    //Start Looking for Users
    [self findUsersOnParse];

}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view layoutIfNeeded];
    
    self.bottomConstraint.constant = -160;
    
    [UIView animateWithDuration:2.0 animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        NSLog(@"DONE UPDATING");
        
    }];
    
}


- (void)findUsersOnParse {
    
    self.usersArray = [[NSArray alloc] init];
    self.usersMutableArray = [[NSMutableArray alloc] init];
    
    switch (self.typeOfUsers) {
        case VIEW_ALL_PEOPLE: {
            
            PFQuery *query = [PFUser query];
            [query orderByAscending:@"username"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                self.usersArray = [[NSArray alloc] initWithArray:usersFound];
                [self.collectionView reloadData];
                
            }];
            
            break;
        }
        case VIEW_FOLLOWERS: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"to" equalTo:self.profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            [query selectKeys:@[@"from"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                NSLog(@"Objects Found: %@", usersFound);
                
                for (PFObject *object in usersFound) {
                    [self.usersMutableArray addObject:object[@"from"]];
                }
                
                self.usersArray = self.usersMutableArray;
                
                [self.collectionView reloadData];
            }];
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"from" equalTo:self.profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                NSLog(@"Objects Found: %@", usersFound);

                for (PFObject *object in usersFound) {
                    [self.usersMutableArray addObject:object[@"to"]];
                }
                
                self.usersArray = self.usersMutableArray;
                
                [self.collectionView reloadData];
            }];
            
            break;
        }
            
        case VIEW_FOLLOWING_TO_INVITE: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"from" equalTo:self.profileUsername];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                for (PFObject *object in usersFound) {
                    [self.usersMutableArray addObject:object[@"to"]];
                }
                
                self.usersArray = self.usersMutableArray;
                
                [self.collectionView reloadData];
            }];

            break;
        }
        
        case VIEW_EVENT_ATTENDERS: {
            
            PFRelation *attendingRelation = [self.eventToViewAttenders relationForKey:@"attenders"];
            PFQuery *queryForAttenders = [attendingRelation query];
            [queryForAttenders findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                self.usersArray = objects;
                [self.collectionView reloadData];
                
            }];
            
            
            break;
        }
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.usersArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"personCell";
    
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
    
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
        PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        //already selected - deselect
        if ([self.selectedIndexes containsObject:indexPath]) {
            
            [self.selectedIndexes removeObject:indexPath];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                    
                }];
            }];
            
            
        } else {
            //Not Selected - Now Select
            
            [self.selectedIndexes addObject:indexPath];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                    NSLog(@"cell.profileimage.image = %@", cell.profileImage.image);
                    
                }];
            }];
            
            
        }
        
    } else {
        
        PFUser *selectedUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        viewUserProfileVC.userNameForProfileView = selectedUser[@"username"];
        viewUserProfileVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    }
    
}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {

        PersonCell *cell = (PersonCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            cell.profileImage.file = (PFFile *)object[@"profilePicture"];
            [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                
            }];
        }];
    }
}



#pragma mark - EventAddVCDelegate Methods

//TODO - Test this for large lists with scrolling.
- (void)doneSelectingPeopleToInvite {
    
    NSMutableArray *selectedPeople = [[NSMutableArray alloc] init];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *currentIndex = indexPaths[i];
        PFUser *selectedUser = (PFUser *)[self.usersArray objectAtIndex:currentIndex.row];
        [selectedPeople addObject:selectedUser];
    }
    
    id<PeopleVCDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(finishedSelectingInvitations:)]) {
        [strongDelegate finishedSelectingInvitations:selectedPeople];
    }
    
}


@end


