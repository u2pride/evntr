//
//  ProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EditProfileVC.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController <UINavigationControllerDelegate, ProfileEditDelegate>

@property (strong, nonatomic) NSString *userObjectID;

@end
