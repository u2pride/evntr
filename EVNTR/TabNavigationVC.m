//
//  TabNavigationVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "TabNavigationVC.h"
#import "HomeScreenVC.h"
#import "ProfileVC.h"
#import "EVNConstants.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "UIColor+EVNColors.h"

@interface TabNavigationVC ()

@property (strong, nonatomic) UITabBarItem *activityItem;

@end

@implementation TabNavigationVC

@synthesize activityItem, isNewUserWithFacebookLogin;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActivity:) name:@"newActivityNotifications" object:nil];
    
    //Should we register for the notification on the user returning to the app? maybe if we used userprefs to store new activity count. but not with other notificaiton.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name: UIApplicationWillEnterForegroundNotification object:nil];
    
    //Update Color of Navigation Bars
    for (UINavigationController *navController in self.viewControllers) {
        navController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        navController.navigationBar.translucent = YES;
        
        //Set Font Color to White
        [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
    
    self.tabBar.barTintColor = [UIColor orangeThemeColor];
    self.tabBar.tintColor = [UIColor whiteColor];

    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    //If User Logged in Through Facebook
    if (isNewUserWithFacebookLogin) {
        [self grabUserDetailsFromFacebook];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Update Activity Badge - From Background Fetch
- (void) newActivity:(NSNotification *)notification {
    
    NSDictionary *notificationDictionary = notification.userInfo;
    NSNumber *num = [notificationDictionary objectForKey:@"numberOfNotifications"];
    
    UINavigationController *navController = (UINavigationController *)[self.childViewControllers objectAtIndex:3];
    self.activityItem = navController.tabBarItem;
    
    self.activityItem.badgeValue = [NSString stringWithFormat:@"%@", num];
    
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    
    //Events View Controller
    if (viewController == [self.viewControllers objectAtIndex:0]) {
        
        UINavigationController *navVC = (UINavigationController *) self.viewControllers.firstObject;
        HomeScreenVC *eventsView = navVC.childViewControllers.firstObject;
        
        eventsView.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        eventsView.userForEventsQuery = [PFUser currentUser];
        
    //Profile VC
    } else if (viewController == [self.viewControllers objectAtIndex:4]) {
        
        UINavigationController *navVC = (UINavigationController *) self.viewControllers.lastObject;
        ProfileVC *profileView = navVC.childViewControllers.firstObject;
        
        profileView.userNameForProfileView = [[PFUser currentUser] objectForKey:@"username"];
    }
}

//Grab User Details From Facebook - Name, Hometown, and Profile Picture
- (void)grabUserDetailsFromFacebook {
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSLog(@"FB User Data: %@", result);
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *firstName = userData[@"first_name"];
            //NSString *gender = userData[@"gender"];
            //NSString *birthday = userData[@"birthday"];
            // NSString *relationship = userData[@"relationship_status"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {
                     // Set the image in the header imageView
                     
                     //
                     UIImage *profileImage2 = [UIImage imageWithData:data];

                     NSLog(@"ABOUT TO GET THE PROFILE IMAGE DATA with data - %@", data);
                     
                     NSData *pictureData = UIImageJPEGRepresentation(profileImage2, 0.5);
                     
                     PFFile *profileImage = [PFFile fileWithName:@"profilepic.jpg" data:pictureData];
                     [profileImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             NSLog(@"YAY");
                             [[PFUser currentUser] setValue:profileImage forKey:@"profilePicture"];
                         }
                         
                     }];
                 }
                 
                 [[PFUser currentUser] setObject:firstName forKey:@"username"];
                 [[PFUser currentUser] setObject:facebookID forKey:@"facebookID"];
                 [[PFUser currentUser] setObject:name forKey:@"realName"];
                 [[PFUser currentUser] setObject:location forKey:@"hometown"];
                 
                 //Save User Details to Parse
                 [[PFUser currentUser] saveInBackground];

             }];
            

            
        }
    }];
    
}

    /*
    
    //TODO - revisit. why am I doing this?
    NSLog(@"View Controller Selected: %@", viewController);
    
    if (self.viewControllers.firstObject == viewController) {
        NSLog(@"This Worked");
        
        UINavigationController *navigationController = (UINavigationController *)self.viewControllers.firstObject;
        HomeScreenVC *homeScreenEventsView = navigationController.childViewControllers.firstObject;
        
        homeScreenEventsView.typeOfEventTableView = ALL_PUBLIC_EVENTS;
        homeScreenEventsView.userForEventsQuery = [PFUser currentUser];
        
    } else if (self.viewControllers.lastObject == viewController) {
        NSLog(@"This is the People VC");
        
        UINavigationController *navigationController = (UINavigationController *)self.viewControllers.lastObject;
        
        PeopleVC *peopleViewController = navigationController.childViewControllers.lastObject;
        peopleViewController.typeOfUsers = VIEW_ALL_PEOPLE;
        peopleViewController.profileUsername = [PFUser currentUser];
        
        //Ehhh.  Doing this to make sure ViewWillAppear is called After Setting properties on the People VC
        [peopleViewController viewWillAppear:YES];
        
        
    }
    */



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
