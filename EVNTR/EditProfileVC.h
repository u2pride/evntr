//
//  EditProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ProfileEditDelegate;
@class ProfileVC;

@interface EditProfileVC : UITableViewController

//TODO: move inside implmentation?
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *hometownTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (nonatomic, weak) id<ProfileEditDelegate> delegate;


@end

@protocol ProfileEditDelegate <NSObject>

-(void)canceledEditingProfile;
-(void)saveProfileEdits:(PFUser *)updatedUser;

@end