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

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
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
    
    //Enabling Local Notifications.
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    //Connecting App to Parse and Enabling Analytics
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Background Fetching for Server Updates
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    
    
    return YES;
}

//TODO: use to determine your current privileges granted by user.  gracefully degrade if not allowed anymore.
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    UIUserNotificationType allowedTypes = [notificationSettings types];
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
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"New locations");
    CLLocation *newLocation = [locations lastObject];

    //Check the most recent location update and make sure it's not cached and recent.
    NSDate *lastLocationDate = newLocation.timestamp;
    NSTimeInterval timeSinceLastLocation = [lastLocationDate timeIntervalSinceNow];
    NSLog(@"Time since Last Location: %f", timeSinceLastLocation);
    if (abs(timeSinceLastLocation) < 60) {
        //self.currentLocation = newLocation;
        
        NSNumber *latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        NSDictionary *userLocationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:latitude, @"latitude", longitude, @"longitude", nil];
        
        //Doing Both UserDefaults and Notifications for Now - Pick one Later
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userLocationDictionary forKey:@"userLocation"];
        [userDefaults synchronize];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"newLocationResult"]];
        

        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LM Failed with Error");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            NSLog(@"kCLAuthorizationStatusDenied");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            //[self setEventLocation:self];
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            //[self setEventLocation:self];
            
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



//Background Fetch - Currently just looks for new invites from the activity table and alerts the user to how many are new.
///////////////////////////NOTES////////////////////////////////
//NOTE: Add a last fetch date to the user property?  How does the nsuserdefaults work for multiple users?  Will objects/keys be overwritten if a new user signs in???  Maybe I should add all these properties to the user and saveInBackgroundEventually?
//Append username to kLastBackgroundFetchDate?
//wonder what this does when no user is logged in? what does [pfuser currentuser] return?
///////////////////////////NOTES////////////////////////////////

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //Background Fetch for New Invites - Storing Fetch Timestamp
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];


    __block NSDate *lastFetchTime = [standardDefaults objectForKey:kLastBackgroundFetchTimeStamp];
    if (!lastFetchTime) {
        lastFetchTime = [NSDate date];
    }
    
    //Perform Fetch Only if User is Logged In
    if ([PFUser currentUser]) {
    
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
                        
                        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                        localNotification.alertBody = [NSString stringWithFormat:@"%@ invited you to an event!", userWhoInvited[@"username"]];
                        localNotification.alertAction = @"Ready for some fun?";
                        localNotification.timeZone = [NSTimeZone defaultTimeZone];
                        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        
                        //Update User Defaults and Notification - TODO: Pick one
                        [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                        lastFetchTime = [NSDate date];
                        [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityNotifications" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:@"numberOfNotifications"]];
                        
                        completionHandler(UIBackgroundFetchResultNewData);
                    }];
                    
                    
                } else if (numberOfNewInvites > 1) {
                    // Schedule the notification
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
                    localNotification.alertBody = @"You've been invited to more than one event. You're popular.";
                    localNotification.alertAction = @"See Events!";
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + numberOfNewInvites;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    
                    //Update User Defaults
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newActivityNotifications" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:@"numberOfNotifications"]];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                } else {
                    //reset badge count
                    [UIApplication sharedApplication].applicationIconBadgeNumber = numberOfNewInvites;
                    
                    
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
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
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
    
    [self.locationManager startUpdatingLocation];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
