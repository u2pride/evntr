//
//  ProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *setPictureButton;

@property (strong, nonatomic) IBOutlet UILabel *twitterLabel;
@property (strong, nonatomic) IBOutlet UILabel *instagramLabel;

@property (strong, nonatomic) IBOutlet UILabel *numberEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;


// Tells the Profile VC what User Profile to display
@property (strong, nonatomic) NSString *userNameForProfileView;


- (IBAction)takePicture:(id)sender;
- (IBAction)viewMyEvents:(id)sender;
- (IBAction)viewFollowers:(id)sender;
- (IBAction)viewFollowing:(id)sender;

- (IBAction)followUser:(id)sender;

@end
