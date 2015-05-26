//
//  EVNUser.m
//  EVNTR
//
//  Created by Alex Ryan on 4/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import "EVNConstants.h"
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@implementation EVNUser

@dynamic profilePicture, twitterHandle, instagramHandle, hometown, realName, bio, username, email;

#pragma mark - Required for Subclassing Parse PFUser

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"_User";
}

+ (EVNUser *) currentUser {
    return (EVNUser *) [PFUser currentUser];
}


#pragma mark - Helper Methods

- (NSString *) hometownText {
    
    if (self.hometown.length != 0) {
        return self.hometown;
    } else {
        return @"Unknown Location";
    }
    
}

- (NSString *) nameText {
    
    if (self.realName.length != 0) {
        return self.realName;
    } else {
        return self.username;
    }
    
}

- (NSString *) bioText {
    
    if (self.bio.length != 0) {
        return self.bio;
    } else {
        return @"My bio is empty.  I think I'm just too flattered that you would ask me about myself.";
    }
    
}


- (void) numberOfEventsWithCompletion:(void (^)(int))completionBlock {
    
    PFQuery *countEventsQuery = [PFQuery queryWithClassName:@"Events"];
    [countEventsQuery whereKey:@"parent" equalTo:self];
    [countEventsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if (error) {
            completionBlock(0);
        } else {
            completionBlock(number);
        }
    
    }];
    
}


- (void) numberOfFollowersWithCompletion:(void (^)(int))completionBlock {

    PFQuery *countFollowersQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowersQuery whereKey:@"to" equalTo:self];
    [countFollowersQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if (error) {
            completionBlock(0);
        } else {
            completionBlock(number);
        }
        
    }];
    
}


- (void) numberOfFollowingWithCompletion:(void (^)(int))completionBlock {
    
    PFQuery *countFollowingQuery = [PFQuery queryWithClassName:@"Activities"];
    [countFollowingQuery whereKey:@"from" equalTo:self];
    [countFollowingQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [countFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
        if (error) {
            completionBlock(0);
        } else {
            completionBlock(number);
        }
    
    }];
    
    
}


- (void) followUser:(EVNUser *)userToFollow fromVC:(UIViewController *)activeVC withButton:(EVNButton *)followButton withCompletion:(void (^)(BOOL))completionBlock {
    
    followButton.enabled = NO;
    [followButton startedTask];
    
    if ([followButton.titleText isEqualToString:kFollowString]) {
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        newFollowActivity[@"from"] = [EVNUser currentUser];
        newFollowActivity[@"to"] = userToFollow;
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                followButton.titleText = kFollowingString;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:activeVC userInfo:nil];
                
            } else {
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to Follow" message:@"If you continue to get this error, send us a tweet or email from settings and we'll help you figure it out." delegate:activeVC cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                [errorAlert show];
                
            }
            
            followButton.enabled = YES;
            [followButton endedTask];
            
        }];
        
        
    } else if ([followButton.titleText isEqualToString:kFollowingString]) {
        
        UIAlertController *unfollowSheet = [UIAlertController alertControllerWithTitle:userToFollow.username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *unfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
            [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [findFollowActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
            [findFollowActivity whereKey:@"to" equalTo:userToFollow];
            
            [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFObject *previousFollowActivity = [objects firstObject];
                [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        followButton.titleText = kFollowString;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFollowActivity object:activeVC userInfo:nil];
                    
                    } else {
                        
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to UnFollow" message:@"If you continue to get this error, send us a tweet or email from settings and we'll help you figure it out." delegate:activeVC cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                        [errorAlert show];
                        
                    }
                    
                    followButton.enabled = YES;
                    [followButton endedTask];
                    
                }];
            }];
            
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            followButton.enabled = YES;
            [followButton endedTask];
            
        }];
        
        
        [unfollowSheet addAction:unfollow];
        [unfollowSheet addAction:cancelAction];
        
        [activeVC presentViewController:unfollowSheet animated:YES completion:nil];
        
        
    } else {
        
        followButton.enabled = YES;
        [followButton endedTask];
        
    }
    
}


- (void) isCurrentUserFollowingProfile:(EVNUser *)user completion:(void (^)(BOOL, BOOL))completionBlock {
    
    //Determine whether the current user is following this user
    PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
    [followActivity whereKey:@"from" equalTo:[EVNUser currentUser]];
    [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [followActivity whereKey:@"to" equalTo:user];
    [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            completionBlock (NO, NO);
        } else {
            if (objects.count > 0) {
                completionBlock(YES, YES);
            } else {
                completionBlock(NO, YES);
            }
        }
        
    }];
    
    
}

@end
