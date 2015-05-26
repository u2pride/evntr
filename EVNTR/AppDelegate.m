//
//  AppDelegate.m
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNConstants.h"
#import "EVNUser.h"

#import <AVFoundation/AVFoundation.h>
#import <Bolts/Bolts.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *locationUpdateTimer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //App is Launch By User - Reset Badge Number
    if (!launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [application setApplicationIconBadgeNumber:0];
    }
    
    NSLog(@"NUMBER 1 - applicationDidFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    //Enabling Local Notifications.
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    //Connecting App to Parse and Enabling Analytics
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    

    //Initializing the Parse FB Utility
    [PFFacebookUtils initializeFacebook];
    
    //TODO NO, this Doesn't work for Auto SignIn - ONly do this for cold launches
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self startLocationManager];

    });
    
    //Audio Session - Continue Playing Background Music
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    
    return YES;

}



- (void) startLocationManager {
    
    NSLog(@"Starting Location Manager....");
    if (!self.locationManagerGlobal) {
        self.locationManagerGlobal = [[CLLocationManager alloc] init];
        self.locationManagerGlobal.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManagerGlobal.distanceFilter = 600;
        self.locationManagerGlobal.delegate = self;
        NSLog(@"Created Location Manager");
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([self.locationManagerGlobal respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            NSLog(@"Requesting In Use Authorization");
            [self.locationManagerGlobal requestWhenInUseAuthorization];
            NSLog(@"Start Updating Locations");
            [self.locationManagerGlobal startUpdatingLocation];
        } else {
            [self.locationManagerGlobal startUpdatingLocation];
        }
    }
    
}


#pragma mark -- CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"New location Found...");
    CLLocation *newLocation = [locations lastObject];

    //Check the most recent location update and make sure it's not cached and recent.
    NSDate *lastLocationDate = newLocation.timestamp;
    NSTimeInterval timeSinceLastLocation = [lastLocationDate timeIntervalSinceNow];
    if (fabs(timeSinceLastLocation) < 60) {
        
        NSNumber *latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
        NSDictionary *userLocationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:latitude, @"latitude", longitude, @"longitude", nil];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userLocationDictionary forKey:kLocationCurrent];
        [userDefaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newLocationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:@"newLocationResult"]];
        
        
        NSLog(@"Stopping Location Manager - Fresh Location Found Found %@ and %@...", latitude, longitude);
        [self.locationManagerGlobal stopUpdatingLocation];
        
        //Add a Timer to Get New Location Every 5 Mins & Invalidate After Close/Background
        self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(startLocationManager) userInfo:nil repeats:YES];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    switch ([error code]) {
        case kCLErrorDenied: {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updates Disabled" message:@"Please enable location updates for EVNTR.\n\nLocation updates are essential for finding events near you." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorNetwork: {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection so Evntr can find events nearby." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
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
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Evntr can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Got It", nil];
            [alertView show];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            NSLog(@"App Has Been Authorized to Use Location While in Use");
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



#pragma mark - Background Fetch

//Background Fetch - Currently just looks for new invites from the activity table and alerts the user to how many are new.
//Add a last fetch date to the user property?  How does the nsuserdefaults work for multiple users?  Will objects/keys be overwritten if a new user signs in???  Maybe I should add all these properties to the user and saveInBackgroundEventually?
//Append username to kLastBackgroundFetchDate? - http://stackoverflow.com/questions/19023544/best-approach-to-persist-preferences-of-several-user-nsuserdefaults-xml-file

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    //Storing Fetch Timestamp in NSUserDefaults
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

    __block NSDate *lastFetchTime = [standardDefaults objectForKey:kLastBackgroundFetchTimeStamp];
    if (!lastFetchTime) {
        lastFetchTime = [NSDate date];
    }
    
    //Perform Fetch Only if User is Logged In
    if ([EVNUser currentUser]) {
    
        //Querying for Invite Activities that Are New
        PFQuery *queryForInvites = [PFQuery queryWithClassName:@"Activities"];
        [queryForInvites whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
        [queryForInvites whereKey:@"to" equalTo:[EVNUser currentUser]];
        [queryForInvites whereKey:@"createdAt" greaterThanOrEqualTo:lastFetchTime];
        [queryForInvites includeKey:@"from"];
        [queryForInvites findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                [PFAnalytics trackEvent:@"BackgroundFetchFailed"];
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                NSUInteger numberOfNewInvites = objects.count;
                
                if (numberOfNewInvites == 1) {
                    PFObject *newInviteActivity = [objects firstObject];
                    EVNUser *userWhoInvited = newInviteActivity[@"from"];
                    
                    //Scheduling Local Notification
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate date];
                    localNotification.alertBody = [NSString stringWithFormat:@"%@ invited you to an event!", userWhoInvited[@"username"]];
                    localNotification.alertAction = nil;
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    
                    //Updating User Defaults - Sending Out Notification to Update Badge
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                    
                } else if (numberOfNewInvites > 1) {
                    
                    // Schedule a Local Notification
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate date];
                    localNotification.alertBody = @"You've been invited to more than one event. You're popular.";
                    //localNotification.alertAction = @"See the Events!";
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + numberOfNewInvites;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    
                    //Update User Defaults and Send Out Notification for Tab Bar Update
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                    
                } else {
                    //reset badge count
                    
                    //Update User Defaults
                    [standardDefaults setObject:[NSNumber numberWithLong:numberOfNewInvites] forKey:kNumberOfNotifications];
                    lastFetchTime = [NSDate date];
                    [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
                    
                    completionHandler(UIBackgroundFetchResultNoData);
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
    
    NSLog(@"Invalidating Timer for Location Updates");
    [self.locationUpdateTimer invalidate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self.locationManagerGlobal stopUpdatingLocation];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [self startLocationManager];

    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[PFFacebookUtils session] close];

}

@end
