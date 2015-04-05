//
//  AppDelegate.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //User's Location for Queries of Local Events.
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 100;
        self.locationManager.delegate = self;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        //IS THIS FOR ASKING FOR LOCATION?? IF SO, ADD TO ONBBOARDING.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        //Check to see if locationServices is enabled.
        //TODO: if not enabled, then alert the user.
        if([CLLocationManager locationServicesEnabled]){
            NSLog(@"Begun Monintoring Locations");
            [self.locationManager startUpdatingLocation];
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    //Enabling Local Notifications.
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    //Connecting App to Parse and Enabling Analytics
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Background Fetching for Server Updates
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    
    //Initializing the Parse FB Utility
    [PFFacebookUtils initializeFacebook];
    
    return YES;
}


#pragma mark - Notifications

//TODO: use to determine your current privileges granted by user.  gracefully degrade if not allowed anymore.
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //UIUserNotificationType allowedTypes = [notificationSettings types];
}

//TODO: what needs to be accomplished here?
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"NOTIFICATION Recieved");
        UIApplicationState applicationState = application.applicationState;
        if (applicationState == UIApplicationStateBackground) {
            [application presentLocalNotificationNow:notification];
        }
}



#pragma mark -- CLLocationManager Delegate

//CLLocation Manager updates the rest of the app with changes in user location.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"New locations");
    CLLocation *newLocation = [locations lastObject];

    //Check the most recent location update and make sure it's not cached and recent.
    NSDate *lastLocationDate = newLocation.timestamp;
    NSTimeInterval timeSinceLastLocation = [lastLocationDate timeIntervalSinceNow];
    NSLog(@"Time since Last Location: %f", timeSinceLastLocation);
    if (abs(timeSinceLastLocation) < 60) {
        
        NSNumber *latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        NSDictionary *userLocationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:latitude, @"latitude", longitude, @"longitude", nil];
        
        //TOODO: Doing Both UserDefaults and Notifications for Now - Pick one Later - Maybe Do Both Since NSUserDefaults is A Cache of Sorts
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userLocationDictionary forKey:@"userLocation"];
        [userDefaults synchronize];
        
        //Send out a notification that the user location has been updated
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"newLocationResult"]];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    switch ([error code]) {
        case kCLErrorDenied: {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updates Disabled" message:@"Please enable location updates for EVNTR.  Location updates are essential for finding events near you." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorNetwork: {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"done" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorLocationUnknown: {
            NSLog(@"Location Unknown - Rechecking location.");
            
            break;
        }
        default: {
            NSLog(@"Location Manager failed with unknown error");
            break;
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            NSLog(@"kCLAuthorizationStatusDenied");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Got It", nil];
            [alertView show];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
}

//Note:  Interesting.  Can use the appDelegate to set the user location. And then retrieve from the app delegate. Is this better than storing in NSUserDefaults?
//Note:  Source of code: http://stackoverflow.com/questions/26111631/ios-8-parse-com-update-and-pf-geopoint-current-location





#pragma mark - Background Fetch

//Background Fetch - Currently just looks for new invites from the activity table and alerts the user to how many are new.
//Add a last fetch date to the user property?  How does the nsuserdefaults work for multiple users?  Will objects/keys be overwritten if a new user signs in???  Maybe I should add all these properties to the user and saveInBackgroundEventually?
//Append username to kLastBackgroundFetchDate? - http://stackoverflow.com/questions/19023544/best-approach-to-persist-preferences-of-several-user-nsuserdefaults-xml-file
//wonder what this does when no user is logged in? what does [pfuser currentuser] return?

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //Storing Fetch Timestamp in NSUserDefaults
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

    __block NSDate *lastFetchTime = [standardDefaults objectForKey:kLastBackgroundFetchTimeStamp];
    if (!lastFetchTime) {
        lastFetchTime = [NSDate date];
    }
    
    //Perform Fetch Only if User is Logged In
    if ([PFUser currentUser]) {
    
        //Querying for Invite Activities that Are New
        PFQuery *queryForInvites = [PFQuery queryWithClassName:@"Activities"];
        [queryForInvites whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
        [queryForInvites whereKey:@"to" equalTo:[PFUser currentUser]];
        [queryForInvites whereKey:@"createdAt" greaterThanOrEqualTo:lastFetchTime];
        [queryForInvites findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                NSUInteger numberOfNewInvites = objects.count;
                
                if (numberOfNewInvites == 1) {
                    PFObject *newInviteActivity = [objects firstObject];
                    PFUser *userWhoInvited = newInviteActivity[@"from"];
                    
                    [userWhoInvited fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        //Scheduling Local Notification
                        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                        localNotification.alertBody = [NSString stringWithFormat:@"%@ invited you to an event!", userWhoInvited[@"username"]];
                        localNotification.alertAction = @"open";
                        localNotification.timeZone = [NSTimeZone defaultTimeZone];
                        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        
                        //Updating User Defaults - Sending Out Notification to Update Badge
                        [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                        lastFetchTime = [NSDate date];
                        [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityNotifications" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:@"numberOfNotifications"]];
                        
                        completionHandler(UIBackgroundFetchResultNewData);
                    }];
                    
                    
                } else if (numberOfNewInvites > 1) {
                    
                    // Schedule a Local Notification
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
                    localNotification.alertBody = @"You've been invited to more than one event. You're popular.";
                    localNotification.alertAction = @"See the Events!";
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + numberOfNewInvites;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    
                    //Update User Defaults and Send Out Notification for Tab Bar Update
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityNotifications" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:@"numberOfNotifications"]];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                } else {
                    //reset badge count
                    
                    //Update User Defaults
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityNotifications" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:@"numberOfNotifications"]];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                }
            }
        }];
        
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
}

#pragma mark - Facebook Integration - Callback for Login

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self.locationManager stopUpdatingLocation];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //Restart Location Manager
    [self.locationManager startUpdatingLocation];
    
    //Reset the Application Badge Count - Not sure if this is exactly the right place
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];

}

@end
