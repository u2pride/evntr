//
//  EVNUser.m
//  EVNTR
//
//  Created by Alex Ryan on 4/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation EVNUser

@dynamic profilePicture, twitterHandle, instagramHandle, hometown, realName, bio;


+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"_User";
}

+ (EVNUser *) currentUser {
    return (EVNUser *) [PFUser currentUser];
}



@end
