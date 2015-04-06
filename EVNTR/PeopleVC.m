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
#import "EVNParseEventHelper.h"
#import "UIColor+EVNColors.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Parse/Parse.h>


@interface PeopleVC ()

//@property (nonatomic, strong) NSMutableArray *selectedPeople;

@property (nonatomic, strong) NSMutableArray *usersMutableArray;
@property (nonatomic, strong) NSArray *usersArray;

@property (nonatomic, strong) NSMutableArray *previouslyInvitedUsers;
@property (nonatomic, strong) NSMutableArray *allInvitedUsers;

@end


@implementation PeopleVC

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    
    self.previouslyInvitedUsers = [[NSMutableArray alloc] init];
    self.allInvitedUsers = [[NSMutableArray alloc] init];
    
    //Maybe this is the part of the problem.
    //self.typeOfUsers = VIEW_ALL_PEOPLE;
    //self.profileUsername = nil;
    //[self findUsersOnParse];
    
    //self.selectedPeople = [[NSMutableArray alloc] init];
    
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
            
            //Taking the PFRelation and Querying for All the Invited Users
            //TODO:  Change this to a column of objectIDs for all of the users that have been invited?
            PFQuery *invitedRelationQuery = [self.usersAlreadyInvited query];
            [invitedRelationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               
                NSLog(@"List of Users Already Invited: %@", objects);

                for (PFUser *user in objects) {
                    //Save User IDs to Compare to Full List of Following
                    [self.previouslyInvitedUsers addObject:user];
                }
                
                //Populate All Invited Users Array with the Existing Invites
                [self.allInvitedUsers addObjectsFromArray:self.previouslyInvitedUsers];
                
                [self.collectionView reloadData];
                
                NSLog(@"Collection of Users Selected: %@", self.previouslyInvitedUsers);
                
            }];
            
            
            self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
            self.navigationController.navigationBar.translucent = YES;
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
            
            [self.navigationItem setTitle:@"Invite"];
            
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectingPeopleToInvite)];
            
            self.navigationItem.rightBarButtonItem = doneButton;
            
            self.collectionView.allowsMultipleSelection = YES;
            
            
            //UINavigationBar *navBar = [[UINavigationBar alloc] init];
            
            //UINavigationItem *navItem = [[UINavigationItem alloc] init];
            //[navBar pushNavigationItem:navItem animated:NO];
            
            //navItem.rightBarButtonItem = doneButton;
            
            //[self.view addSubview:navBar];
            

            
            /*
            UIButton *doneSelectingInvitationsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [doneSelectingInvitationsButton addTarget:self action:@selector(doneSelectingPeopleToInvite) forControlEvents:UIControlEventTouchUpInside];
            [doneSelectingInvitationsButton setTitle:@"DONE" forState:UIControlStateNormal];
            [self.view addSubview:doneSelectingInvitationsButton];
            doneSelectingInvitationsButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-80.f];
            
            [self.view addConstraint:bottomConstraint];
            
            NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
            
            [self.view addConstraint:constraint2];
            
            NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:doneSelectingInvitationsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:200.0f];
            
            [self.view addConstraint:constraint3];
            */
            
            
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
            
            [EVNParseEventHelper queryForUsersFollowing:self.profileUsername completion:^(NSArray *following) {
                
                self.usersArray = [NSArray arrayWithArray:following];
                
                [self.collectionView reloadData];
                
            }];
            
            /*
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
            */

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

//TODO: Move code to PersonCell View and Out of View Controller - Masking Code - Have isSelected-ish Property.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"personCell";
    
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
    
    //Default Profile Pic Until User Information is Fetched in Background
    cell.profileImage.image = [UIImage imageNamed:@"PersonDefault"];
    
    //Determine if the user has already been invited
    if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
    
    //if ([self.allInvitedUsers containsObject:currentUser]) {
        
        NSLog(@"User Already Invited - %@ and %@", currentUser.objectId, currentUser.username);
        
        //Add to Selected Indexes
        //[self.selectedPeople addObject:currentUser];

        //Update Mask with Checkmark
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            cell.profileImage.file = (PFFile *)object[@"profilePicture"];
            cell.personTitle.text = object[@"username"];
            [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                
            }];
        }];
        
    } else {
        
        NSLog(@"User Not Already Invited - %@ and %@", currentUser.objectId, currentUser.username);
        
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            cell.profileImage.file = (PFFile *)object[@"profilePicture"];
            cell.personTitle.text = object[@"username"];
            [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                
            }];
        }];
        
    }
    
    //Update Font
    cell.personTitle.font = [UIFont fontWithName:@"Lato-Regular" size:12.0];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"DIDSELECT CALLED");

    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {

        PersonCell *cell = (PersonCell *)[collectionView cellForItemAtIndexPath:indexPath];
        PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        //already selected - deselect
        if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
            
            [self removeUser:currentUser fromArray:self.allInvitedUsers];
            //[self.allInvitedUsers removeObject:currentUser];
            
            NSLog(@"Remove User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);
            [self.usersAlreadyInvited removeObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                    
                }];
            }];
            
            
        } else {
            //Not Selected - Now Select
            
            [self.allInvitedUsers addObject:currentUser];
            
            NSLog(@"Add User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);
            [self.usersAlreadyInvited addObject:currentUser];
            
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
    
    NSLog(@"DIDDESELCT CALLED");
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {
        
        PersonCell *cell = (PersonCell *)[collectionView cellForItemAtIndexPath:indexPath];
        PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        //already selected - deselect
        if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
            
            [self removeUser:currentUser fromArray:self.allInvitedUsers];
            //[self.allInvitedUsers removeObject:currentUser];
            
            NSLog(@"Remove User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);
            [self.usersAlreadyInvited removeObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                    
                }];
            }];
            
            
        } else {
            //Not Selected - Now Select
            
            [self.allInvitedUsers addObject:currentUser];
            
            NSLog(@"Add User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);
            [self.usersAlreadyInvited addObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                    NSLog(@"cell.profileimage.image = %@", cell.profileImage.image);
                    
                }];
            }];
            
            
        }
        
    }
    /*
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
     
     */
}



- (BOOL) isUser:(PFUser *)user alreadyInArray:(NSMutableArray *) array  {
    
    for (PFUser *userInArray in array) {
        if ([userInArray.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
    
}


- (void) removeUser:(PFUser *)user fromArray:(NSMutableArray *)arrayOfUsers {
    
    PFUser *userToRemove;
    
    for (PFUser *userInArray in arrayOfUsers) {
        if ([userInArray.objectId isEqualToString:user.objectId]) {
            userToRemove = userInArray;
        }
    }
    
    if (userToRemove) {
        [arrayOfUsers removeObject:userToRemove];
    }
    
    
}



#pragma mark - EventAddVCDelegate Methods

//TODO - Test this for large lists with scrolling.
- (void)doneSelectingPeopleToInvite {
    
    /*
    NSMutableArray *selectedPeople = [[NSMutableArray alloc] init];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *currentIndex = indexPaths[i];
        PFUser *selectedUser = (PFUser *)[self.usersArray objectAtIndex:currentIndex.row];
        [selectedPeople addObject:selectedUser];
    }
    */
    
    NSMutableArray *newInvites = [[NSMutableArray alloc] init];
    
    for (PFUser *user in self.allInvitedUsers) {
        
        if (![self isUser:user alreadyInArray:self.previouslyInvitedUsers]) {
            [newInvites addObject:user];
            NSLog(@"NEWWWWWWWWWWWWWWW INVITEEEEEEEEEEEE");
        }
    }
    
    id<PeopleVCDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(finishedSelectingInvitations:)]) {
        [strongDelegate finishedSelectingInvitations:newInvites];
    }
        
}


@end


