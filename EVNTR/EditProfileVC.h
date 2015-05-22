//
//  EditProfileVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@protocol ProfileEditDelegate;


@interface EditProfileVC : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<ProfileEditDelegate> delegate;

//User Information From Profile Screen
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *hometown;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSData *pictureData;

@end


@protocol ProfileEditDelegate <NSObject>

- (void) canceledEditingProfile;
- (void) saveProfileWithNewInformation:(NSDictionary *)stringDictionary withImageData:(NSData *)imageData;

@end