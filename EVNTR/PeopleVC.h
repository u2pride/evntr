//
//  PeopleVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface PeopleVC : UICollectionViewController
{
    NSArray *usersArray;
    NSMutableArray *usersMutableArray;
}

@property (nonatomic, assign) int typeOfUsers;
@property (nonatomic, strong) PFUser *profileUsername;

@end
