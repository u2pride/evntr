//
//  ProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EditProfileVC.h"
#import "UICountingLabel.h"

#import <Parse/Parse.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <UIKit/UIKit.h>

//TODO REMOVE FB DELEGATE

@interface ProfileVC : UIViewController <UINavigationControllerDelegate, ProfileEditDelegate, FBSDKAppInviteDialogDelegate>

@property (strong, nonatomic) NSString *userObjectID;

@end
