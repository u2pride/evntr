//
//  AppDelegate.h
//  EVNTR
//
//  Created by Alex Ryan on 1/26/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "Amplitude/Amplitude.h"
#import <UIKit/UIKit.h>
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManagerGlobal;
@property (nonatomic, strong) Amplitude *amplitudeInstance;

@end

