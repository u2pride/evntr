//
//  EVNUser.h
//  EVNTR
//
//  Created by Alex Ryan on 4/30/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface EVNUser : PFObject <PFSubclassing>

@property (nonatomic, strong) PFFile *profilePicture;

@property (nonatomic, strong) NSString *hometown;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *twitterHandle;
@property (nonatomic, strong) NSString *instagramHandle;


+ (EVNUser *) currentUser;

@end
