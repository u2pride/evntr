//
//  EVNUser.m
//  EVNTR
//
//  Created by Alex Ryan on 4/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "Amplitude/Amplitude.h"
#import "EVNUser.h"
#import "EVNConstants.h"
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@implementation EVNUser

@dynamic profilePicture, hometown, realName, bio, username, email, numEvents, numFollowers, numFollowing;

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

#pragma mark - Finding Followers and Following

+ (void) queryForUsersFollowing:(EVNUser *)user withLimit:(int)limit withSkip:(int)skip completion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
    [query setSkip:skip];
    [query setLimit:limit];
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


+ (void) queryForUsersFollowers:(EVNUser *)user withLimit:(int)limit withSkip:(int)skip completion:(void (^)(NSArray *))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activities"];
    [query setSkip:skip];
    [query setLimit:limit];
    [query whereKey:@"userTo" equalTo:user];
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [query includeKey:@"userFrom"];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *usersFound, NSError *error) {
        
        NSMutableArray *finalResults = [[NSMutableArray alloc] init];
        
        if (!error) {
            for (PFObject *object in usersFound) {
                
                EVNUser *userFollower = object[@"userFrom"];
                
                if (![finalResults containsObject:userFollower]) {
                    
                    if (userFollower) {
                        [finalResults addObject:userFollower];
                    }
                    
                } else {
                    //Duplicate Attendee Found
                }
            }
        }
        
        completionBlock(finalResults);
        
    }];
    
}


#pragma mark - Helper Methods

- (NSString *) hometownText {
    
    if (self.hometown.length != 0) {
        return self.hometown;
    } else {
        if ([self.objectId isEqualToString:[EVNUser currentUser].objectId]) {
            [self setInitialLocationForUser];
        }
        return @"Unknown Location";
    }
    
}

//Grab the Location of the User on First Profile Access if no location set already
- (void) setInitialLocationForUser {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = [appDelegate.locationManagerGlobal location];
    
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (!error && placemarks) {
            
            CLPlacemark *placemark = [placemarks firstObject];
            NSString *locationForUser = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
            
            self.hometown = locationForUser;
            [self saveInBackground];
            
        }
        
    }];
    
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


- (void) followUser:(EVNUser *)userToFollow fromVC:(UIViewController *)activeVC withButton:(EVNButton *)followButton withCompletion:(void (^)(BOOL))completionBlock {
    
    [followButton startedTask];
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    
    if (self.numFollowers && self.numFollowing) {
            
        [props setObject:self.numFollowers forKey:@"Total Followers"];
        [props setObject:self.numFollowing forKey:@"Total Following"];
        
        [[Amplitude instance] setUserProperties:props replace:YES];
        
        
    }
    
    if ([followButton.titleText isEqualToString:kFollowString]) {
        
        PFObject *newFollowActivity = [PFObject objectWithClassName:@"Activities"];
        newFollowActivity[@"type"] = [NSNumber numberWithInt:FOLLOW_ACTIVITY];
        newFollowActivity[@"userFrom"] = [EVNUser currentUser];
        newFollowActivity[@"userTo"] = userToFollow;
        
        [newFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [[Amplitude instance] logEvent:@"Followed User"];
                
                followButton.titleText = kFollowingString;
                
                NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:userToFollow.objectId forKey:kFollowedUserObjectId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewFollow object:activeVC userInfo:userInfoDict];
                
            } else {
                
                [[Amplitude instance] logEvent:@"Follow User Error"];
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to Follow" message:@"If you continue to get this error, send us a tweet or email from Settings and we'll help you figure it out." delegate:activeVC cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                [errorAlert show];
                
            }
            
            [followButton endedTask];
            
        }];
        
        
    } else if ([followButton.titleText isEqualToString:kFollowingString]) {
        
        UIAlertController *unfollowSheet = [UIAlertController alertControllerWithTitle:userToFollow.username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *unfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            PFQuery *findFollowActivity = [PFQuery queryWithClassName:@"Activities"];
            [findFollowActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
            [findFollowActivity whereKey:@"userFrom" equalTo:[EVNUser currentUser]];
            [findFollowActivity whereKey:@"userTo" equalTo:userToFollow];
            
            [findFollowActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    
                    PFObject *previousFollowActivity = [objects firstObject];
                    [previousFollowActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            
                            [[Amplitude instance] logEvent:@"Unfollowed User"];
                            
                            followButton.titleText = kFollowString;
                            
                            NSDictionary *userInfoDict = [NSDictionary dictionaryWithObject:userToFollow.objectId forKey:kUnfollowedUserObjectId];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNewUnfollow object:activeVC userInfo:userInfoDict];
                            
                        } else {
                            
                            [[Amplitude instance] logEvent:@"Unfollow User Error"];
                            
                            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to UnFollow" message:@"If you continue to get this error, send us a tweet or email from settings and we'll help you figure it out." delegate:activeVC cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                            [errorAlert show];
                            
                        }
                        
                        [followButton endedTask];
                        
                    }];
                    
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to UnFollow" message:@"If you continue to get this error, send us a tweet or email from settings and we'll help you figure it out." delegate:activeVC cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                    [errorAlert show];
                    
                    [followButton endedTask];
                    
                }
                
            }];
            
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [followButton endedTask];
            
        }];
        
        
        [unfollowSheet addAction:unfollow];
        [unfollowSheet addAction:cancelAction];
        
        [activeVC presentViewController:unfollowSheet animated:YES completion:nil];
        
        
    } else {
        
        [followButton endedTask];
        
    }
    
}


- (void) isCurrentUserFollowingProfile:(EVNUser *)user completion:(void (^)(BOOL, BOOL))completionBlock {
    
    //Determine whether the current user is following this user
    PFQuery *followActivity = [PFQuery queryWithClassName:@"Activities"];
    [followActivity whereKey:@"userFrom" equalTo:[EVNUser currentUser]];
    [followActivity whereKey:@"type" equalTo:[NSNumber numberWithInt:FOLLOW_ACTIVITY]];
    [followActivity whereKey:@"userTo" equalTo:user];
    [followActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            if (error.code == kPFErrorObjectNotFound) {
                completionBlock(NO, YES);
            } else {
                completionBlock (NO, NO);
            }
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
