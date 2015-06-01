//
//  EVNUser.h
//  EVNTR
//
//  Created by Alex Ryan on 4/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "EVNButton.h"

@interface EVNUser : PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) PFFile *profilePicture;

@property (nonatomic, strong) NSString *hometown;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *bio;

@property (nonatomic, strong) NSNumber *numEvents;
@property (nonatomic, strong) NSNumber *numFollowers;
@property (nonatomic, strong) NSNumber *numFollowing;

+ (EVNUser *) currentUser;

- (NSString *) hometownText;
- (NSString *) nameText;
- (NSString *) bioText;

- (void) followUser:(EVNUser *)userToFollow fromVC:(UIViewController *)activeVC withButton:(EVNButton *)followButton withCompletion:(void (^)(BOOL))completionBlock;

- (void) isCurrentUserFollowingProfile:(EVNUser *)user completion:(void (^)(BOOL isFollowing, BOOL success))completionBlock;

@end
