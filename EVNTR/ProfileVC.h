//
//  ProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditProfileVC.h"

@interface ProfileVC : UIViewController <UINavigationControllerDelegate, ProfileEditDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//User Information
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) IBOutlet UILabel *twitterLabel;
@property (strong, nonatomic) IBOutlet UILabel *instagramLabel;

@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;

// Username of the Profile Page
@property (strong, nonatomic) NSString *userNameForProfileView;

//Navigation
@property BOOL isComingFromEditProfile;

//Loading Spinner
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;





@end
