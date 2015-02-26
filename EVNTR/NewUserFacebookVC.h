//
//  NewUserFacebookVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol NewUserFacebookDelegate;

#import <UIKit/UIKit.h>

@interface NewUserFacebookVC : UIViewController

@property (nonatomic, weak) id<NewUserFacebookDelegate> delegate;

@property (nonatomic, strong) NSDictionary *informationFromFB;


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) NSString *urlForProfilePicture;
@property (weak, nonatomic) NSString *facebookID;

- (IBAction)registerWithFBInformation:(id)sender;

@end

@protocol NewUserFacebookDelegate <NSObject>

- (void) createFBRegisterVCWithDetails:(NSDictionary *) userDetailsFromFB;

@end
