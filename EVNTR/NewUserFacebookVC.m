//
//  NewUserFacebookVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "EVNButton.h"
#import "FBShimmeringView.h"
#import "NewUserFacebookVC.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"

@interface NewUserFacebookVC ()

@property (strong, nonatomic) IBOutlet EVNButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) NSString *urlForProfilePicture;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *location;

@property (strong, nonatomic) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;


- (IBAction)registerWithFBInfo:(id)sender;

@end

@implementation NewUserFacebookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.usernameField.delegate = self;
    self.emailField.delegate = self;
    self.nameField.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    NSLog(@"Passed informationFromFB: %@", self.informationFromFB);
    
    self.usernameField.text = ([self.informationFromFB objectForKey:@"firstName"]) ? (NSString *)[self.informationFromFB objectForKey:@"firstName"] : @"";
    self.emailField.text = ([self.informationFromFB objectForKey:@"email"]) ? (NSString *)[self.informationFromFB objectForKey:@"email"] : @"";
    self.nameField.text = ([self.informationFromFB objectForKey:@"realName"]) ? (NSString *)[self.informationFromFB objectForKey:@"realName"] : @"";
    
    self.facebookID = ([self.informationFromFB objectForKey:@"ID"]) ? (NSString *)[self.informationFromFB objectForKey:@"ID"] : @"";
    self.firstName = ([self.informationFromFB objectForKey:@"firstName"]) ? (NSString *)[self.informationFromFB objectForKey:@"firstName"] : @"";
    self.location = ([self.informationFromFB objectForKey:@"location"]) ? (NSString *)[self.informationFromFB objectForKey:@"location"] : @"";

    NSLog(@"%@ - %@ - %@ - %@ - %@ - %@", self.usernameField.text, self.emailField.text, self.nameField.text, self.facebookID, self.firstName, self.location);
     
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Grab Facebook Profile Picture
    if ([self.informationFromFB objectForKey:@"profilePictureURL"]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"profilePictureURL"]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   
                                   if (connectionError == nil && data != nil) {
                                       NSLog(@"got a fb profile image");
                                       UIImage *profileImageFromData = [UIImage imageWithData:data];
                                       self.profileImageView.image = [EVNUtility maskImage:profileImageFromData withMask:[UIImage imageNamed:@"MaskImage"]];
                                       
                                       
                                   } else {
                                       NSLog(@"didnt get a fb profile image");
                                   }
                               }];
        
    }
    
    
}


- (IBAction)registerWithFBInfo:(id)sender {
    
    __block PFUser *currentUser = [PFUser currentUser];
    
    [self blurViewDuringLoginWithMessage:@"Registering..."];
    
    //Validate that the user has submitted a user name and password
    if (self.usernameField.text.length > 3 && self.nameField.text.length > 3 && self.emailField.text.length > 0) {
        
        NSData *pictureDataForParse = UIImageJPEGRepresentation(self.profileImageView.image, 0.5);
        
        PFFile *profilePictureFile = [PFFile fileWithName:@"profilepic.jpg" data:pictureDataForParse];
        
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded){
                currentUser[@"profilePicture"] = profilePictureFile;
                
                currentUser.username = self.usernameField.text;
                currentUser.email = self.emailField.text;
                currentUser[@"realName"] = self.nameField.text;
                currentUser[@"facebookID"] = [NSString stringWithFormat:@"%@", self.facebookID];
                currentUser[@"hometown"] = [NSString stringWithFormat:@"%@", self.location];
                
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        NSLog(@"Successfully created new user with FB profile and saved user's information to database.");
                        
                        //Set isGuest Object
                        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                        [standardDefaults setBool:NO forKey:kIsGuest];
                        [standardDefaults synchronize];
                        
                        [self performSegueWithIdentifier:@"FBRegisterToOnboard" sender:nil];
                        
                    } else {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Already Taken" message:@"Username already taken or email not valid" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [errorAlert show];
                    }
                    
                }];
            }
            
            [self cleanUpBeforeTransition];
            
        }];
        
        
    } else {
        
        [self cleanUpBeforeTransition];
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure to fill in all fields and that your username and password are greater than three characters." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        
        [errorAlert show];
    }

}


- (void) blurViewDuringLoginWithMessage:(NSString *)message {
    
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurOutLogInScreen = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.blurOutLogInScreen.alpha = 0;
    self.blurOutLogInScreen.frame = self.view.bounds;
    [self.view addSubview:self.blurOutLogInScreen];
    
    self.blurMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.blurMessage.alpha = 0;
    self.blurMessage.text = message;
    self.blurMessage.font = [UIFont fontWithName:EVNFontRegular size:24];
    self.blurMessage.textAlignment = NSTextAlignmentCenter;
    self.blurMessage.textColor = [UIColor whiteColor];
    self.blurMessage.center = self.view.center;
    //[self.view addSubview:self.blurMessage];
    
    self.shimmerView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.shimmerView];
    
    self.shimmerView.contentView = self.blurMessage;
    self.shimmerView.shimmering = YES;
    
    [UIView animateWithDuration:0.8 animations:^{
        self.blurOutLogInScreen.alpha = 1;
        self.blurMessage.alpha = 1;
    } completion:^(BOOL finished) {
        
        
    }];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - private methods

- (void) cleanUpBeforeTransition {
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.blurMessage.alpha = 0;
        self.blurOutLogInScreen.alpha = 0;
        self.shimmerView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self.blurMessage removeFromSuperview];
        [self.blurOutLogInScreen removeFromSuperview];
        [self.shimmerView removeFromSuperview];
        
    }];
    
    
}

-(void)dealloc {
    NSLog(@"newuserfacebokvc is being deallocated");
}


@end


