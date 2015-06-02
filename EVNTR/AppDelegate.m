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

#pragma mark - App Lifecycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"NUMBER 1 - applicationDidFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    //Enabling Local Notifications.
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    //Connecting App to Parse and Enabling Analytics
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Initializing the Parse FB Utility
    [PFFacebookUtils initializeFacebook];
    
    //TODO NO, this Doesn't work for Auto SignIn - ONly do this for cold launches - duplicate when app becomes active from background
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
    //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //[self startLocationManager];

    //});
    
    //Audio Session - Continue Playing Background Music
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    
    return YES;

}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"Invalidating Timer for Location Updates");
    [self.locationUpdateTimer invalidate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self.locationManagerGlobal stopUpdatingLocation];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [self startLocationManager];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[PFFacebookUtils session] close];
    
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
            
            NSLog(@"LME 1");
            
            [PFAnalytics trackEventInBackground:@"LocationManagerDisabled" block:nil];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updates Disabled" message:@"Evntr can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorNetwork: {
            
            NSLog(@"LME 2");

            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection so Evntr can find events nearby." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorLocationUnknown: {
            
            NSLog(@"LME 3");

            NSLog(@"Location Unknown - Rechecking location.");
            
            break;
        }
        default: {
            
            NSLog(@"LME 4");

            NSLog(@"Location Manager failed with unknown error");
            break;
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            
            NSLog(@"LME 5");

            NSLog(@"kCLAuthorizationStatusDenied");
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            
            //Here is where we start updating location
            /*
             
             locationManager.desiredAccuracy = kCLLocationAccuracyBest;
             locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
             [locationManager startUpdatingLocation];
             
             CLLocation *currentLocation = locationManager.location;
             if (currentLocation) {
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate setCurrentLocation:currentLocation];
             }
             */
        
            NSLog(@"LME 6");

            NSLog(@"App Has Been Authorized to Use Location While in Use");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            NSLog(@"LME 7");

            break;
        }
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"LME 8");

            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        }
        case kCLAuthorizationStatusRestricted: {
            NSLog(@"LME 9");
   
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
        }
    }
}


#pragma mark - Helper Methods

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



#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

    __block NSDate *lastFetchTime = [standardDefaults objectForKey:kLastBackgroundFetchTimeStamp];
    if (!lastFetchTime) {
        lastFetchTime = [NSDate date];
    }
    
    UIUserNotificationSettings *grantedSettings;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){ // Check it's iOS 8 and above
         grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    }
    
    //Perform Fetch Only if User is Logged In && Notifications Enabled
    if ([EVNUser currentUser] && grantedSettings.types != UIUserNotificationTypeNone) {
    
        //Querying for Invite Activities that Are New
        PFQuery *queryForInvites = [PFQuery queryWithClassName:@"Activities"];
        [queryForInvites whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
        [queryForInvites whereKey:@"userTo" equalTo:[EVNUser currentUser]];
        [queryForInvites whereKey:@"createdAt" greaterThanOrEqualTo:lastFetchTime];
        [queryForInvites includeKey:@"userFrom"];
        [queryForInvites findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                [PFAnalytics trackEvent:@"BackgroundFetchFailed"];
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                NSUInteger numberOfNewInvites = objects.count;
                
                if (numberOfNewInvites == 1) {
                    PFObject *newInviteActivity = [objects firstObject];
                    EVNUser *userWhoInvited = newInviteActivity[@"userFrom"];
                    
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


#pragma mark - Facebook Integration - Callback for Login

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}





@end
