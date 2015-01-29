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

@implementation PeopleVC


#pragma mark -
#pragma mark Init

- (void) viewDidLoad {
    [super viewDidLoad];
    //Maybe this is the part of the problem.
    [self findUsersOnParse];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)findUsersOnParse {
    
    int typeOfUsers = 1;
    
    switch (typeOfUsers) {
        case 1: {
            
            PFQuery *query = [PFUser query];
            [query orderByAscending:@"username"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                usersArray = [[NSArray alloc] initWithArray:usersFound];
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
    
    cell.profileImage.image = [UIImage imageNamed:@"PersonDefault"];
    cell.profileImage.file = (PFFile *)currentUser[@"profilePicture"];
    cell.personTitle.text = currentUser[@"username"];
    [cell.profileImage loadInBackground];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end


