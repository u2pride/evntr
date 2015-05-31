//
//  PeopleVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EVNUtility.h"
#import "PeopleVC.h"
#import "PersonCell.h"
#import "ProfileVC.h"
#import "UIColor+EVNColors.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Parse/Parse.h>


@interface PeopleVC ()

@property (nonatomic, strong) NSMutableArray *usersMutableArray;
@property (nonatomic, strong) NSArray *usersArray;

@property (nonatomic, strong) NSMutableArray *previouslyInvitedUsers;
@property (nonatomic, strong) NSMutableArray *allInvitedUsers;

@property (nonatomic, strong) UIActivityIndicatorView *activitySpinner;

@end


@implementation PeopleVC

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [EVNUtility setupNavigationBarWithController:self.navigationController andItem:self.navigationItem];
    
    self.previouslyInvitedUsers = [[NSMutableArray alloc] init];
    self.allInvitedUsers = [[NSMutableArray alloc] init];
    
    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activitySpinner.hidesWhenStopped = YES;
    self.activitySpinner.center = CGPointMake(self.view.center.x, self.view.center.y / 2.0);
    [self.view addSubview:self.activitySpinner];
    
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
            
            NSLog(@"ViewFollowingToInivte");
            
            self.collectionView.allowsMultipleSelection = YES;
            
            //Taking the PFRelation and Querying for All the Invited Users
            //TODO:  Change this to a column of objectIDs for all of the users that have been invited?
            PFQuery *invitedRelationQuery = [self.usersAlreadyInvited query];
            [invitedRelationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               
                if (!error) {
                    
                    for (EVNUser *user in objects) {
                        //Save User IDs to Compare to Full List of Following
                        [self.previouslyInvitedUsers addObject:user];
                    }
                    
                    //Populate All Invited Users Array with the Existing Invites
                    [self.allInvitedUsers addObjectsFromArray:self.previouslyInvitedUsers];
                    
                    [self reloadCollectionView];
                    
                }

            }];
            
            self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
            self.navigationController.navigationBar.translucent = NO;
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
            
            [self.navigationItem setTitle:@"Invite"];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectingPeopleToInvite)];
            
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
    
    [self findUsersOnParse];

}



- (void)findUsersOnParse {
    
    [self.activitySpinner startAnimating];
    
    self.usersArray = [[NSArray alloc] init];
    self.usersMutableArray = [[NSMutableArray alloc] init];
    
    switch (self.typeOfUsers) {
        case VIEW_ALL_PEOPLE: {
            
            PFQuery *query = [EVNUser query];
            [query orderByAscending:@"username"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                if (error || [usersFound count] == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"Hello?";
                    noResultsView.subHeaderText = @"Whoa, it's really empty in here.  Know where everyone went?";
                    noResultsView.actionButton.titleText = @"Refresh";
                    
                    UITapGestureRecognizer *tapReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findUsersOnParse)];
                    [noResultsView.actionButton addGestureRecognizer:tapReload];
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    self.usersArray = [[NSArray alloc] initWithArray:usersFound];
                    [self reloadCollectionView];
                }
            
            }];
            
            break;
        }
        case VIEW_FOLLOWERS: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"userTo" equalTo:self.userProfile];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            [query selectKeys:@[@"userFrom"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                if (error || [usersFound count] == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No Followers";
                    noResultsView.subHeaderText = @"This can't be right... who wouldn't want to follow you?";
                    noResultsView.actionButton.titleText = @"Refresh";
                    
                    UITapGestureRecognizer *tapReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findUsersOnParse)];
                    [noResultsView.actionButton addGestureRecognizer:tapReload];
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    
                    for (PFObject *object in usersFound) {
                        [self.usersMutableArray addObject:object[@"userFrom"]];
                    }
                    
                    self.usersArray = self.usersMutableArray;
                    
                    [self reloadCollectionView];

                }
            }];
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            [self queryForUsersFollowing:self.userProfile completion:^(NSArray *following) {
                
                if (following.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                    noResultsView.headerText = @"Following No Users";
                    noResultsView.subHeaderText = @"Looks like you aren't following anyone.";
                    noResultsView.actionButton.titleText = @"Refresh";
                    
                    UITapGestureRecognizer *tapReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findUsersOnParse)];
                    [noResultsView.actionButton addGestureRecognizer:tapReload];
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self reloadCollectionView];
                }
                
                
            }];
            
            break;
        }
            
        case VIEW_FOLLOWING_TO_INVITE: {
            
            //VC to Invite is Presented Modally - Thus Minor UI Tweaks are Needed to Nav Bar
            //TODO: UTLITY Navigation Bar Font & Color
            //NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
            
            //Bar Button Item Text Attributes
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                           nil]
                                                                 forState:UIControlStateNormal];
            
            [self queryForUsersFollowing:self.userProfile completion:^(NSArray *following) {
                
                if (following.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No One to Invite";
                    noResultsView.subHeaderText = @"Once you start to follow users, you will be able to invite them to events.";
                    noResultsView.actionButton.hidden = YES;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self reloadCollectionView];
                }
                
   
            }];
            
            break;
        }
        
        case VIEW_EVENT_ATTENDERS: {
            
            PFRelation *attendingRelation = [self.eventToViewAttenders relationForKey:@"attenders"];
            PFQuery *queryForAttenders = [attendingRelation query];
            [queryForAttenders findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error || [objects count] == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No Attendees";
                    noResultsView.subHeaderText = @"Looks like no one is attending this event yet. You could be the first.";
                    noResultsView.actionButton.titleText = @"Refresh";
                    
                    UITapGestureRecognizer *tapReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findUsersOnParse)];
                    [noResultsView.actionButton addGestureRecognizer:tapReload];
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    self.usersArray = objects;
                    [self reloadCollectionView];
                }
                
                
            }];
            
            
            break;
        }
        default:
            break;
    }
    
}


#pragma mark - CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.usersArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"personCell";
    
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    EVNUser *currentUser = (EVNUser *)[self.usersArray objectAtIndex:indexPath.row];
    
    cell.profileImage.image = [UIImage imageNamed:@"PersonDefault"];
    
    if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
        
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!error){
                
                PFFile *profilePictureData = (PFFile *) object[@"profilePicture"];
                
                cell.personTitle.text = object[@"username"];
                cell.profileImage.file = profilePictureData;
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    
                    [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                        
                        cell.profileImage.image = maskedImage;
                        
                    }];
                    
                }];
                
            }
            
        }];
        
    } else {
        
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {

            if (!error) {
                
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                
                [cell.profileImage loadInBackground];
                
            }

        }];
        
    }
        
    return cell;
}


#pragma mark - Collection View Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {

        [self determineSelectionStateForIndexPath:indexPath];
        
    } else {
        
        EVNUser *selectedUser = (EVNUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        [selectedUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!error) {
                
                ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                viewUserProfileVC.userObjectID = selectedUser.objectId;
                viewUserProfileVC.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:viewUserProfileVC animated:YES];
                
            }

        }];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self determineSelectionStateForIndexPath:indexPath];
    
}


- (void) collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        
        cell.alpha = 1;
        cell.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
    }];
}



#pragma mark - Helper Loading Methods

- (void) reloadCollectionView {
    
    [self.activitySpinner stopAnimating];
    
    [self.collectionView reloadData];
    
}



#pragma mark - Helper Methods for Invite Selection

- (void) determineSelectionStateForIndexPath:(NSIndexPath *)indexPath {
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {
        
        PersonCell *cell = (PersonCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        EVNUser *currentUser = (EVNUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
            
            [self removeUser:currentUser fromArray:self.allInvitedUsers];
            
            [self.usersAlreadyInvited removeObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (!error){
                    cell.profileImage.file = (PFFile *) object[@"profilePicture"];
                    [cell.profileImage loadInBackground];
                }

            }];
            
        } else {
            
            [self.allInvitedUsers addObject:currentUser];
            
            [self.usersAlreadyInvited addObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    
                if (!error) {
                    
                    cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                    [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                        
                        cell.profileImage.alpha = 0;
                        
                        [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                            
                            cell.profileImage.image = maskedImage;
                            
                        }];
                        
                        cell.profileImage.alpha = 0.0;
                        cell.profileImage.layer.transform = CATransform3DMakeScale(0.2, 0.2, 1);
                        
                        [UIView animateWithDuration:0.24 animations:^{
                            
                            cell.profileImage.alpha = 1.0;
                            cell.profileImage.layer.transform = CATransform3DIdentity;
                        }];
                        
                    }];
                    
                }

            }];
            
            
        }
        
    }
    
}


- (BOOL) isUser:(EVNUser *)user alreadyInArray:(NSMutableArray *) array  {
    
    for (EVNUser *userInArray in array) {
        if ([userInArray.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
    
}


- (void) removeUser:(EVNUser *)user fromArray:(NSMutableArray *)arrayOfUsers {
    
    EVNUser *userToRemove;
    
    for (EVNUser *userInArray in arrayOfUsers) {
        if ([userInArray.objectId isEqualToString:user.objectId]) {
            userToRemove = userInArray;
        }
    }
    
    if (userToRemove) {
        [arrayOfUsers removeObject:userToRemove];
    }
    
    
}



- (void) queryForUsersFollowing:(EVNUser *)user completion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
    [query whereKey:@"userFrom" equalTo:user];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [query includeKey:@"to"];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
        
        NSMutableArray *finalResults = [[NSMutableArray alloc] init];
        
        if (!error) {
            for (PFObject *object in usersFound) {
                
                EVNUser *userFollowing = object[@"userTo"];
                
                if (![finalResults containsObject:userFollowing]) {
                    
                    if (userFollowing) {
                        [finalResults addObject:userFollowing];
                    }
                    
                } else {
                    NSLog(@"Developer Note:  Duplicate attendee found.");
                }
            }
        }
        
        completionBlock(finalResults);
        
    }];
    
}



#pragma mark - EventAddVCDelegate Methods

- (void)doneSelectingPeopleToInvite {
    
    NSMutableArray *newInvites = [[NSMutableArray alloc] init];
    
    for (EVNUser *user in self.allInvitedUsers) {
        
        if (![self isUser:user alreadyInArray:self.previouslyInvitedUsers]) {
            [newInvites addObject:user];
        }
    }
    
    id<PeopleVCDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(finishedSelectingInvitations:)]) {
        [strongDelegate finishedSelectingInvitations:newInvites];
    }
        
}


@end


