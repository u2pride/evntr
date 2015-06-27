//
//  PeopleVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNConstants.h"
#import "EVNNoResultsView.h"
#import "EVNInviteContainerVC.h"
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
@property (nonatomic, strong) EVNNoResultsView *noResultsView;

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
            
            UIBarButtonItem *reloadIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(findUsersOnParse)];
            self.navigationItem.rightBarButtonItem = reloadIcon;
            
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            [self.navigationItem setTitle:@"Following"];
            
            UIBarButtonItem *reloadIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(findUsersOnParse)];
            self.navigationItem.rightBarButtonItem = reloadIcon;
            
            self.collectionView.allowsMultipleSelection = NO;
            
            break;
        }
        case VIEW_FOLLOWING_TO_INVITE: {
                        
            self.collectionView.allowsMultipleSelection = YES;
            
            // 2 - {from} invited {to} to {activityContent}

            
            //Disable interaction until users are loaded.
            self.collectionView.userInteractionEnabled = NO;
            
            PFQuery *usersInvitedAlready = [PFQuery queryWithClassName:@"Activities"];
            [usersInvitedAlready whereKey:@"userFrom" equalTo:self.userProfile];
            [usersInvitedAlready whereKey:@"activityContent" equalTo:self.eventForInvites];
            [usersInvitedAlready whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
            [usersInvitedAlready includeKey:@"userTo"];
            [usersInvitedAlready findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    
                    for (EVNUser *activity in objects) {
                        
                        //Save User IDs to Compare to Full List of Following
                        [self.previouslyInvitedUsers addObject:activity[@"userTo"]];
                    }
                    
                    //Populate All Invited Users Array with the Existing Invites
                    [self.allInvitedUsers addObjectsFromArray:self.previouslyInvitedUsers];
                    
                    self.collectionView.userInteractionEnabled = YES;

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
                    
                    UITapGestureRecognizer *tapReload = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findUsersOnParse)];
                    
                    [self showNoResultsViewWithHeader:@"Hello?" withSubHeader:@"Whoa, it's really empty in here.  Know where everyone went?" withButtonTitle:@"Refresh" andGesture:tapReload];
                    
                } else {
                    
                    [self hideNoResultsView];
                    
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
                    
                    if ([self.userProfile.objectId isEqualToString:[EVNUser currentUser].objectId]) {

                        [self showNoResultsViewWithHeader:@"No Followers" withSubHeader:@"This can't be right... who wouldn't want to follow you?" withButtonTitle:nil andGesture:nil];
                    
                    } else {

                        [self showNoResultsViewWithHeader:@"No Followers" withSubHeader:@"Their cool-ness has not been discovered yet." withButtonTitle:nil andGesture:nil];
                    }
                    
                } else {
                    
                    [self hideNoResultsView];
                    
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
                    
                    //EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

                    if ([self.userProfile.objectId isEqualToString:[EVNUser currentUser].objectId]) {

                        UITapGestureRecognizer *tapFindFriends = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findFriends)];

                        [self showNoResultsViewWithHeader:@"Following No Users" withSubHeader:@"We can help. Let's help you find some of your friends on Evntr." withButtonTitle:@"Find Your Friends!" andGesture:tapFindFriends];
                        
                    } else {
                        
                        [self showNoResultsViewWithHeader:@"Following No Users" withSubHeader:@"They're not following anyone - no one has quite piqued their interest yet!" withButtonTitle:nil andGesture:nil];
                        
                    }

                    [self reloadCollectionView];
                    
                } else {
                    
                    [self hideNoResultsView];
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self reloadCollectionView];
                }
                
                
            }];
            
            break;
        }
            
        case VIEW_FOLLOWING_TO_INVITE: {
            
            //VC to Invite is Presented Modally - Thus Minor UI Tweaks are Needed to Nav Bar
            self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
            
            //Bar Button Item Text Attributes
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                           [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                           nil]
                                                                 forState:UIControlStateNormal];
            
            [self queryForUsersFollowing:self.userProfile completion:^(NSArray *following) {
                
                if (following.count == 0) {
                    
                    [self showNoResultsViewWithHeader:@"No One to Invite" withSubHeader:@"Once you start to follow users, you will be able to invite them to events." withButtonTitle:nil andGesture:nil];
                    
                } else {
                    
                    [self hideNoResultsView];
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self reloadCollectionView];
                }
                
   
            }];
            
            break;
        }
        
        case VIEW_EVENT_ATTENDERS: {
            
            [self.eventToViewAttenders queryForAttendersWithCompletion:^(NSArray *attenders) {
                
                if ([attenders count] == 0) {
                    
                    [self showNoResultsViewWithHeader:@"No Attendees" withSubHeader:@"Looks like no one is attending this event yet. You could be the first." withButtonTitle:nil andGesture:nil];
                    
                } else {
                    
                    [self hideNoResultsView];
                    
                    self.usersArray = attenders;
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
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {
        [self determineSelectionStateForIndexPath:indexPath];
    }

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



#pragma mark - Helper Methods


- (void) showNoResultsViewWithHeader:(NSString *)header withSubHeader:(NSString *)subHeader withButtonTitle:(NSString *)buttonTitle andGesture:(UITapGestureRecognizer *)gr {
    
    if (!self.noResultsView) {
        
        self.noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.bounds];
        self.noResultsView.headerText = header;
        self.noResultsView.subHeaderText = subHeader;
        
        if (buttonTitle) {
            self.noResultsView.actionButton.hidden = NO;
            self.noResultsView.actionButton.titleText = buttonTitle;
        } else {
            self.noResultsView.actionButton.hidden = YES;
        }
        
        if (gr) {
            [self.noResultsView.actionButton addGestureRecognizer:gr];
        }
        
        [self.view addSubview:self.noResultsView];
    }
    
    self.noResultsView.hidden = NO;
}

- (void) hideNoResultsView {
    
    if (self.noResultsView) {
        [self.noResultsView removeFromSuperview];
        self.noResultsView = nil;
    }

}

- (void) reloadCollectionView {
        
    [self.activitySpinner stopAnimating];
    
    [self.collectionView reloadData];
    
}

- (void) findFriends {
    
    EVNInviteContainerVC *inviteVC = [[EVNInviteContainerVC alloc] init];
    
    [self.navigationController pushViewController:inviteVC animated:YES];
    
}



#pragma mark - Helper Methods for Invite Selection

- (void) determineSelectionStateForIndexPath:(NSIndexPath *)indexPath {
    
    if (self.typeOfUsers == VIEW_FOLLOWING_TO_INVITE) {
        
        PersonCell *cell = (PersonCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        EVNUser *currentUser = (EVNUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
            
            [self removeUser:currentUser fromArray:self.allInvitedUsers];
                        
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (!error){
                    cell.profileImage.file = (PFFile *) object[@"profilePicture"];
                    [cell.profileImage loadInBackground];
                }

            }];
            
        } else {
            
            [self.allInvitedUsers addObject:currentUser];
            
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
    [query includeKey:@"userTo"];
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
                    //Duplicate Attendee Found
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


