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
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


@interface AppDelegate ()

@property (nonatomic, strong) NSTimer *locationUpdateTimer;

@end

@implementation AppDelegate

#pragma mark - App Lifecycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    //Enabling Local Notifications.
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    //Connecting App to Parse and Enabling Analytics
    [ParseCrashReporting enable];
    
    //parse init - DEVELOPMENT
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];

    //parse init - PRODUCTION
    //[Parse setApplicationId:@"pmiyjr1AZuOHvRebg9cKm1NdBvX2ILefZvYIXIEs" clientKey:@"3s0PDgQzp01DLs588gDqPqaEVepbHaoYmfkcAlXJ"];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Initializing the Parse FB Utility
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    //Audio Session - Continue Playing Background Music
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    
    return YES;

}


- (void)applicationWillResignActive:(UIApplication *)application {
    
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
    
    [FBSDKAppEvents activateApp];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        [self startLocationManager];
    
    });
    
}

/*
- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[PFFacebookUtils session] close];
}
*/



#pragma mark -- CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
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
        
        [self.locationManagerGlobal stopUpdatingLocation];
        
        //Add a Timer to Get New Location Every 5 Mins & Invalidate After Close/Background
        self.locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(startLocationManager) userInfo:nil repeats:YES];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    switch ([error code]) {
        case kCLErrorDenied: {
            
            break;
        }
        case kCLErrorNetwork: {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection so Evntr can find events nearby." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            break;
        }
        case kCLErrorLocationUnknown: {
            
            break;
        }
        default: {
            
            break;
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
            
            [PFAnalytics trackEventInBackground:@"LocationManagerDisabled" block:nil];
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updates Disabled" message:@"Evntr can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {

            break;
        }
        case kCLAuthorizationStatusNotDetermined: {

            break;
        }
        case kCLAuthorizationStatusRestricted: {
   
            break;
        }
    }
}


#pragma mark - Helper Methods

- (void) startLocationManager {
    
    if (!self.locationManagerGlobal) {
        self.locationManagerGlobal = [[CLLocationManager alloc] init];
        self.locationManagerGlobal.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManagerGlobal.distanceFilter = 600;
        self.locationManagerGlobal.delegate = self;
        self.locationManagerGlobal.pausesLocationUpdatesAutomatically = NO;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([self.locationManagerGlobal respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManagerGlobal requestWhenInUseAuthorization];
            [self.locationManagerGlobal startUpdatingLocation];
        } else {
            [self.locationManagerGlobal startUpdatingLocation];
        }
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Location Updates" message:@"Looks like we can't find your location.  Go to Settings to allow Evntr to use your current location inside the app." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
        
        [errorAlert show];
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //UIUserNotificationType allowedTypes = [notificationSettings types];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
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
    
    BFURL *parsedURL = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    
    if ([parsedURL appLinkData]) {
        
        NSURL *targetURL = [parsedURL targetURL];
        
        [[[UIAlertView alloc] initWithTitle:@"Link" message:[targetURL absoluteString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        return NO;
        
    } else {
     
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    
}




@end
