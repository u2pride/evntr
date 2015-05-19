//
//  FullMapVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FullMapVC : UIViewController

@property (nonatomic, strong) CLLocation *locationOfEvent;
@property (nonatomic, strong) CLPlacemark *locationPlacemark;
@property (nonatomic, strong) NSString *eventLocationName;

@end
