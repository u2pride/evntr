//
//  FilterEventsVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/13/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EVNFilterProtocol;

@interface FilterEventsVC : UIViewController

@property (nonatomic) float selectedFilterDistance;
@property (nonatomic, strong) id <EVNFilterProtocol> delegate;

@end

@protocol EVNFilterProtocol <NSObject>

- (void) completedFiltering:(float)radius;

@end
