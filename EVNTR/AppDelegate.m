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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //Connecting App to Parse and Enabling Analytics
    [Parse setApplicationId:@"d8C8syeVtJ05eEm6cbYNduAxxpx0KOPhPhGyRSHv" clientKey:@"NP77GbK9h4Rk88FXGMmTEEjtXVADmMqMVeu3zXTE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Background Fetching for Server Updates
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    
    //User Notifications - Local (currently just for invites)
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    UIUserNotificationType allowedTypes = [notificationSettings types];
    //use to determine your current privileges granted by user.  gracefully degrade if not allowed anymore.
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //NOTE: Add a last fetch date to the user property?  How does the nsuserdefaults work for multiple users?  Will objects/keys be overwritten if a new user signs in???  Maybe I should add all these properties to the user and saveInBackgroundEventually?
    //Append username to kLastBackgroundFetchDate?
    //wonder what this does when no user is logged in? what does [pfuser currentuser] return?
    
    //Background Fetch for New Invites - Storing Fetch Timestamp
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

    __block NSDate *lastFetchTime = [standardDefaults objectForKey:kLastBackgroundFetchTimeStamp];
    if (!lastFetchTime) {
        lastFetchTime = [NSDate date];
    }
    
    NSLog(@"User: %@", [PFUser currentUser]);
    
    PFQuery *queryForInvites = [PFQuery queryWithClassName:@"Activities"];
    [queryForInvites whereKey:@"type" equalTo:[NSNumber numberWithInt:INVITE_ACTIVITY]];
    [queryForInvites whereKey:@"to" equalTo:[PFUser currentUser]];
    [queryForInvites whereKey:@"createdAt" greaterThanOrEqualTo:lastFetchTime];
    [queryForInvites findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
        } else {
            NSLog(@"Invites: %@", objects);
            NSNumber *numberOfNewInvites = [NSNumber numberWithInt:objects.count];
            NSLog(@"num of invites: %@", numberOfNewInvites);
            
            if (numberOfNewInvites.integerValue == 1) {
                PFObject *newInviteActivity = [objects firstObject];
                PFUser *userWhoInvited = newInviteActivity[@"from"];
                [userWhoInvited fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    // Schedule the notification
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate date];
                    localNotification.alertBody = [NSString stringWithFormat:@"%@ invited you to an event!",userWhoInvited[@"username"]];
                    localNotification.alertAction = @"Ready for some fun?";
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                    
                }];
                

            } else if (numberOfNewInvites.integerValue > 1) {
                // Schedule the notification
                UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
                localNotification.alertBody = @"You've been invited to more than one event. You're popular.";
                localNotification.alertAction = @"See Events!";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + numberOfNewInvites.integerValue;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                
            } else if (numberOfNewInvites.integerValue == 0) {
                //reset badge count
                [UIApplication sharedApplication].applicationIconBadgeNumber = numberOfNewInvites.integerValue;
                
            }
            
            [standardDefaults setObject:numberOfNewInvites forKey:kNumberOfNotifications];
            
            //set new fetchtime
            lastFetchTime = [NSDate date];
            [standardDefaults setObject:lastFetchTime forKey:kLastBackgroundFetchTimeStamp];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
