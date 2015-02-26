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

@interface NewUserFacebookVC ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation NewUserFacebookVC

@synthesize usernameField, emailField, nameField, profileImageView, continueButton, urlForProfilePicture, facebookID, informationFromFB, firstName, location;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    self.usernameField.delegate = self;
    self.emailField.delegate = self;
    self.nameField.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"dictionary: %@", self.informationFromFB);
    

    
    self.usernameField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"firstName"]];
    self.emailField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"email"]];
    self.nameField.text = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"realName"]];
    self.facebookID = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"ID"]];
    self.firstName = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"firstName"]];
    self.location = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"location"]];
    //lesson learned... need to cast it or wrap it through a class method.  otherwise it's just an id type and doesn't work in other things.
    
    NSLog(@"Facebook ID in VIEWWILLAPPEAR: %@ and %@", [self.informationFromFB objectForKey:@"ID"], self.facebookID);


}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.facebookID]];

    NSString *urlString = [NSString stringWithFormat:@"%@", [self.informationFromFB objectForKey:@"profilePictureURL"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"MY NSURL: %@", url);
    
    //grab profile picture and put in UIImageView
    //NSURL *pictureURL = [NSURL URLWithString:[self.informationFromFB objectForKey:@"profilePictureURL"]];
    
    NSLog(@"url: %@ and URL: %@", url, pictureURL);

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerWithFBInformation:(id)sender {
    

    NSLog(@"ID: %@ and firstName: %@", self.facebookID, self.firstName);
    
    __block PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"CURRENT USER: %@", currentUser);
    
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
                        
                        [self performSegueWithIdentifier:@"FBRegisterToOnboard" sender:nil];
                        
                    } else {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Already Taken" message:@"Username already taken or email not valid" delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
                        
                        [errorAlert show];
                    }
                    
                    
                }];
            }
        }];
        
        
        
        
        
    } else {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure to fill in all fields and that your username and password are greater than three characters." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
        
        [errorAlert show];
    }
    
    

    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


