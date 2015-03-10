//
//  NewUserFacebookVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "NewUserFacebookVC.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"

@interface NewUserFacebookVC ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) NSString *urlForProfilePicture;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) UIVisualEffectView *blurOutLogInScreen;

- (IBAction)registerWithFBInformation:(id)sender;

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

    self.usernameField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"firstName"]];
    self.emailField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"email"]];
    self.nameField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"realName"]];
    self.facebookID = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"ID"]];
    self.firstName = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"firstName"]];
    self.location = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"location"]];
    //lesson learned... need to cast it or wrap it through a class method.  otherwise it's just an id type and doesn't work in other things.

}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *urlString = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"profilePictureURL"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError == nil && data != nil) {
                                   NSLog(@"got an image");
                                   UIImage *profileImageFromData = [UIImage imageWithData:data];
                                   self.profileImageView.image = [EVNUtility maskImage:profileImageFromData withMask:[UIImage imageNamed:@"MaskImage"]];
                                   
                                   
                               } else {
                                   NSLog(@"ERROR");
                               }
                           }];
    
}



- (IBAction)registerWithFBInformation:(id)sender {
    
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
            
            self.blurOutLogInScreen.alpha = 0;
            [self.blurOutLogInScreen removeFromSuperview];
            
        }];
        
        
    } else {
        
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
    
    UILabel *loginInTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    loginInTextLabel.alpha = 0;
    loginInTextLabel.text = message;
    loginInTextLabel.font = [UIFont fontWithName:@"Lato-Regular" size:24];
    loginInTextLabel.textAlignment = NSTextAlignmentCenter;
    loginInTextLabel.textColor = [UIColor whiteColor];
    loginInTextLabel.center = self.view.center;
    [self.view addSubview:loginInTextLabel];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.blurOutLogInScreen.alpha = 1;
        loginInTextLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end


