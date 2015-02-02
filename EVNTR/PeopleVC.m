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

@implementation PeopleVC

@synthesize typeOfUsers, profileUsername;

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
            NSLog(@"MaskedImage");
            cell.profileImage.image = [UIImage imageNamed:@"EventDefault"];
            cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
        }];
    }];
    

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PFUser *selectedUser = (PFUser *)[usersArray objectAtIndex:indexPath.row];
    
    ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    viewUserProfileVC.userNameForProfileView = selectedUser[@"username"];
    
    [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    
}





@end


