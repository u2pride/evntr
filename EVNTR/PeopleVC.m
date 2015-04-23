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

//@property (nonatomic, strong) NSMutableArray *selectedPeople;

@property (nonatomic, strong) NSMutableArray *usersMutableArray;
@property (nonatomic, strong) NSArray *usersArray;

@property (nonatomic, strong) NSMutableArray *previouslyInvitedUsers;
@property (nonatomic, strong) NSMutableArray *allInvitedUsers;

@end


@implementation PeopleVC

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
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
                
                if (error || usersFound.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"Hello?";
                    noResultsView.subHeaderText = @"Whoa, it's really empty in here.  Know where everyone went?";
                    noResultsView.actionButton.alpha = 0;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    self.usersArray = [[NSArray alloc] initWithArray:usersFound];
                    [self.collectionView reloadData];
                }
            
            }];
            
            break;
        }
        case VIEW_FOLLOWERS: {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
            [query whereKey:@"to" equalTo:self.userProfile];
            [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [query orderByAscending:@"createdAt"];
            [query selectKeys:@[@"from"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
                
                if (error || usersFound.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No Followers";
                    noResultsView.subHeaderText = @"";
                    noResultsView.actionButton.hidden = YES;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    NSLog(@"Objects Found: %@", usersFound);
                    
                    for (PFObject *object in usersFound) {
                        [self.usersMutableArray addObject:object[@"from"]];
                    }
                    
                    self.usersArray = self.usersMutableArray;
                    
                    [self.collectionView reloadData];

                }
            }];
            
            break;
        }
        case VIEW_FOLLOWING: {
            
            [self queryForUsersFollowing:self.userProfile completion:^(NSArray *following) {
                
                if (following.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No One to Invite";
                    noResultsView.subHeaderText = @"Once you start to follow users, you will be able to invite them to events.";
                    noResultsView.actionButton.alpha = 0;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self.collectionView reloadData];
                }
                
                
            }];
            
            break;
        }
            
        case VIEW_FOLLOWING_TO_INVITE: {
            
            //VC to Invite is Presented Modally - Thus Minor UI Tweaks are Needed to Nav Bar
            //Navigation Bar Font & Color
            NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
            
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
                    noResultsView.actionButton.alpha = 0;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    
                    self.usersArray = [NSArray arrayWithArray:following];
                    [self.collectionView reloadData];
                }
                
   
            }];
            
            break;
        }
        
        case VIEW_EVENT_ATTENDERS: {
            
            PFRelation *attendingRelation = [self.eventToViewAttenders relationForKey:@"attenders"];
            PFQuery *queryForAttenders = [attendingRelation query];
            [queryForAttenders findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error || objects.count == 0) {
                    
                    EVNNoResultsView *noResultsView = [[EVNNoResultsView alloc] initWithFrame:self.view.frame];
                    noResultsView.headerText = @"No Attendees";
                    noResultsView.subHeaderText = @"Looks like no one is attending this event yet. You could be the first.";
                    noResultsView.actionButton.alpha = 0;
                    
                    [self.view addSubview:noResultsView];
                    
                } else {
                    self.usersArray = objects;
                    [self.collectionView reloadData];
                }
                
                
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
    NSLog(@"Start CellForItemAtIndexPath");

    static NSString *cellIdentifier = @"personCell";
    
    PersonCell *cell = (PersonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSLog(@"Cell Now Dequeded");

    PFUser *currentUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
    NSLog(@"Current User Determined");

    //Default Profile Pic Until User Information is Fetched in Background
    cell.profileImage.image = [UIImage imageNamed:@"PersonDefault"];
    NSLog(@"Default Profile Picture Attached");
    
    //Determine if the user has already been invited
    if ([self isUser:currentUser alreadyInArray:self.allInvitedUsers]) {
        
        //Add to Selected Indexes
        //[self.selectedPeople addObject:currentUser];

        //Update Mask with Checkmark
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            NSLog(@"User Already Invited - %@ and %@", currentUser.objectId, currentUser.username);
            
            cell.personTitle.text = object[@"username"];
            
            PFFile *profilePictureData = (PFFile *) object[@"profilePicture"];
            [profilePictureData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
               
                [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                    
                    cell.profileImage.image = maskedImage;
                    
                }];
                
            }];
            
            /* Testing GetData
            cell.profileImage.file = (PFFile *)object[@"profilePicture"];
            cell.personTitle.text = object[@"username"];
            [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                
                [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                   
                    cell.profileImage.image = maskedImage;
                    
                }];
                
                //cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                
            }];
             */
        }];
        
    } else {
        
        NSLog(@"Starting Fetch In Background");

        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            //NSLog(@"User Not Already Invited - %@ and %@", currentUser.objectId, currentUser.username);
            /*
            NSLog(@"User Fetched");

            cell.profileImage.file = (PFFile *)object[@"profilePicture"];
            NSLog(@"File pulled from Object");

            cell.personTitle.text = object[@"username"];
            NSLog(@"Username title text assigned");
            
            NSLog(@"Start Loading Profile Image in Bacground");

            
            [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                NSLog(@"Came Back with Image - %ld", (long)indexPath.row);
                [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
                    NSLog(@"Image Returned as Masked - %ld", (long) indexPath.row);
                    cell.profileImage.image = maskedImage;
                    NSLog(@"Assigned to Cell Profile Image Property - %ld", (long)indexPath.row);
                }];
                
            }];
            
            */
            cell.personTitle.text = object[@"username"];
            //cell.profileImage.file = (PFFile *) object[@"profilePicture"];
            
            //[cell.profileImage loadInBackground];
            
            PFFile *profilePictureData = (PFFile *) object[@"profilePicture"];
            [profilePictureData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
                    
                    cell.profileImage.image = maskedImage;
                    
                }];
                
            }];
            
            
        }];
        
    }
        
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
            
            [self.usersAlreadyInvited removeObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"Remove User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);

                /* test for getdata
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    
                    [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
                       
                        cell.profileImage.image = maskedImage;
                        
                    }];
                    
                    //cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                    
                }];
                 */
            }];
            
            
        } else {
            //Not Selected - Now Select
            
            [self.allInvitedUsers addObject:currentUser];
            
            [self.usersAlreadyInvited addObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"Add User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);

                /* Test for getData
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    
                    cell.profileImage.alpha = 0;
                    
                    [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                        
                        cell.profileImage.image = maskedImage;
                    }];
                    
                    //cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                    
                    cell.profileImage.alpha = 0.0;
                    cell.profileImage.layer.transform = CATransform3DMakeScale(0.2, 0.2, 1);

                    [UIView animateWithDuration:0.24 animations:^{
                        
                        cell.profileImage.alpha = 1.0;
                        cell.profileImage.layer.transform = CATransform3DIdentity;
                    }];
                    
                    
                }];
                */
            }];
            
            
        }
        
    } else {
        
        PFUser *selectedUser = (PFUser *)[self.usersArray objectAtIndex:indexPath.row];
        
        [selectedUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            viewUserProfileVC.userObjectID = selectedUser.objectId;
            viewUserProfileVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:viewUserProfileVC animated:YES];
            
        }];
        

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
            
            [self.usersAlreadyInvited removeObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"Remove User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);

                /* test for getdata
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                cell.personTitle.text = object[@"username"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                    
                    [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"] withCompletion:^(UIImage *maskedImage) {
                       
                        cell.profileImage.image = maskedImage;
                        
                    }];
                    
                    //cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
                    
                }];
                 */
            }];
            
            
        } else {
            //Not Selected - Now Select
            
            [self.allInvitedUsers addObject:currentUser];
            
            [self.usersAlreadyInvited addObject:currentUser];
            
            [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"Add User from PFRelation - %@ and %@", currentUser.objectId, currentUser.username);

                /* test for getdata
                cell.profileImage.file = (PFFile *)object[@"profilePicture"];
                [cell.profileImage loadInBackground:^(UIImage *image, NSError *error) {
                   
                    cell.profileImage.alpha = 0;
                    
                    [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"] withCompletion:^(UIImage *maskedImage) {
                       
                        cell.profileImage.image = maskedImage;
                        
                    }];
                    
                    //cell.profileImage.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"checkMarkMask"]];
                    
                    cell.profileImage.alpha = 0.0;
                    cell.profileImage.layer.transform = CATransform3DMakeScale(0.2, 0.2, 1);
                    
                    [UIView animateWithDuration:0.24 animations:^{
                        
                        cell.profileImage.alpha = 1.0;
                        cell.profileImage.layer.transform = CATransform3DIdentity;
                    }];
                    
                }];
                 */
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



- (void) queryForUsersFollowing:(PFUser *)user completion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
    [query whereKey:@"from" equalTo:user];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [query includeKey:@"to"];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
        
        NSLog(@"RESULTS OF QUERYFORUSERSFOLLOWING: %@", usersFound);
        
        NSMutableArray *finalResults = [[NSMutableArray alloc] init];
        
        if (!error) {
            for (PFObject *object in usersFound) {
                
                PFUser *userFollowing = object[@"to"];
                
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

//TODO - Test this for large lists with scrolling.
- (void)doneSelectingPeopleToInvite {
    
    NSMutableArray *newInvites = [[NSMutableArray alloc] init];
    
    for (PFUser *user in self.allInvitedUsers) {
        
        if (![self isUser:user alreadyInArray:self.previouslyInvitedUsers]) {
            [newInvites addObject:user];
            NSLog(@"New Invite");
        }
    }
    
    
    id<PeopleVCDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(finishedSelectingInvitations:)]) {
        [strongDelegate finishedSelectingInvitations:newInvites];
    }
        
}


@end


