//
//  EVNLoginBaseVC.m
//  EVNTR
//
//  Created by Alex Ryan on 7/7/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNLoginBaseVC.h"
#import "EVNConstants.h"
#import "FBShimmeringView.h"
#import "UIColor+EVNColors.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface EVNLoginBaseVC ()

@property (strong, nonatomic) UIVisualEffectView *blurOutLogInScreen;
@property (nonatomic, strong) UILabel *blurMessage;
@property (nonatomic, strong) FBShimmeringView *shimmerView;

@end

@implementation EVNLoginBaseVC

#pragma mark - View Controller Lifecycle Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.viewIsPulledUpForTextInput = NO;

}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - User Actions

- (void) loginThruFacebook {
    
    NSArray *permissionsArray = @[ @"email", @"user_friends"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            
            [self cleanUpBeforeTransition];
            
            // Handles cases like Facebook password change or unverified Facebook accounts.
            NSString *alertMessage, *alertTitle;
            
            if ([error.userInfo objectForKey:FBSDKErrorLocalizedDescriptionKey]) {
                alertMessage = [error.userInfo objectForKey:FBSDKErrorLocalizedDescriptionKey];
                alertTitle = [error.userInfo objectForKey:FBSDKErrorLocalizedTitleKey];
                
            } else {
                alertTitle = @"Facebook Issue";
                alertMessage = @"Sorry about this.  Looks like Facebook is having problems logging you in.  Restarting Evntr (double-click the home button and swipe up on Evntr to stop it) should fix this.";
            }
            
            if (alertMessage) {
                
                [[[UIAlertView alloc] initWithTitle:alertTitle
                                            message:alertMessage
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance logEvent:@"Facebook Sign Up Issue"];
            
        } else {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.amplitudeInstance setUserId:user.objectId];
                        
            if (user.isNew) {
                
                [appDelegate.amplitudeInstance logEvent:@"Facebook Sign Up"];
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self grabUserDetailsFromFacebookWithUser:(EVNUser *)user];
                    [self cleanUpBeforeTransition];
                    
                });
                
            } else {
                
                [appDelegate.amplitudeInstance logEvent:@"Facebook Log In"];
                
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setBool:NO forKey:kIsGuest];
                [standardDefaults synchronize];
                
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self performSegueWithIdentifier:@"SegueToHomeView" sender:self];
                    [self cleanUpBeforeTransition];
                    
                });
                
                
            }
            
        }
        
        
        
    }];
    
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect screenRect;
    CGRect windowRect;
    CGRect viewRect;
    
    screenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect = [self.view        convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (!self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:YES withKeyboardSize:movement];
        
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGRect screenRect;
    CGRect windowRect;
    CGRect viewRect;
    
    screenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect = [self.view convertRect:windowRect fromView:nil];
    
    int movement = viewRect.size.height * 0.8;
    
    if (self.viewIsPulledUpForTextInput) {
        [self moveLoginFieldsUp:NO withKeyboardSize:movement];
        
    }
    
}


#pragma mark - UIImagePicker Presentation And Delegate Methods

- (void) presentImagePicker {
    
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.view.tintColor = [UIColor orangeThemeColor];
        
        [self presentViewController:imagePicker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            
        }];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:choosePhoto];
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
}


#pragma mark - Helper Methods

- (void) grabUserDetailsFromFacebookWithUser:(EVNUser *)newUser {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    newUser[@"username"] = @"Evntr User";
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    
    [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            
            [activityIndicator stopAnimating];
            
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *userDetailsForFBRegistration = [[NSMutableDictionary alloc] init];
            
            //NSLog(@"UserData: %@", userData);
            
            if (userData[@"id"]) {
                [userDetailsForFBRegistration setObject:userData[@"id"] forKey:@"ID"];
            }
            
            if (userData[@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"name"] forKey:@"realName"];
            }
            
            //TOOD:  Remove
            if (userData[@"location"][@"name"]) {
                [userDetailsForFBRegistration setObject:userData[@"location"][@"name"] forKey:@"location"];
            }
            
            if (userData[@"first_name"]) {
                [userDetailsForFBRegistration setObject:userData[@"first_name"] forKey:@"firstName"];
            }
            
            if (userData[@"email"]) {
                [userDetailsForFBRegistration setObject:userData[@"email"] forKey:@"email"];
            }
            
            if (userData[@"id"]) {
                
                NSString *facebookID = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                
                [userDetailsForFBRegistration setObject:pictureURL forKey:@"profilePictureURL"];
            }
            
            //Submit Initial User Info In Case they Quit the Process Before Finishing Evntr Register Process
            if (userData[@"email"]) {
                newUser[@"email"] = (NSString *) userData[@"email"];
            }
            
            if (userData[@"first_name"]) {
                newUser[@"username"] = (NSString *) userData[@"first_name"];
            } else {
                newUser[@"username"] = @"Evntr User";
            }
            
            if (userData[@"id"]) {
                newUser[@"facebookID"] = userData[@"id"];
            }
            
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                id<NewUserFacebookDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(createFBRegisterVCWithDetails:)]) {
                    
                    [strongDelegate createFBRegisterVCWithDetails:[NSDictionary dictionaryWithDictionary:userDetailsForFBRegistration]];
                }
                
            }];
            
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hmmmm" message:@"Looks like we had trouble retrieving your Facebook details.  Send us a tweet at @EvntrApp if you continue to have issues." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles: nil];
            
            [errorAlert show];
            
        }
        
    }];
    
    [connection start];
    
}


//Subclasses Should Override this method to hide/show necessary views.
- (void) moveLoginFieldsUp:(BOOL)up withKeyboardSize:(int)distance {
    
    int movement = (up ? -distance : distance);
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        
    } completion:^(BOOL finished) {
        self.viewIsPulledUpForTextInput = (up ? YES : NO);
    }];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //TODO: Call super implementation? stack overflow iphone-what-does-super-touchesbegan-moved-ended-do
    //Tap Dismisses Keyboard
    
    if (self.viewIsPulledUpForTextInput) {
        [self.view endEditing:YES];
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
    
    self.shimmerView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.shimmerView];
    
    self.shimmerView.contentView = self.blurMessage;
    self.shimmerView.shimmering = YES;
    
    [UIView animateWithDuration:0.8 animations:^{
        
        self.blurOutLogInScreen.alpha = 1;
        self.blurMessage.alpha = 1;
        
    } completion:nil];
    
}


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


@end
