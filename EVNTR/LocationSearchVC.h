//
//  LocationSearchVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol EventLocationSearch;


@interface LocationSearchVC : UIViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) id<EventLocationSearch> delegate;

@end


@protocol EventLocationSearch <NSObject>

- (void) locationSearchDidCancel;
- (void) locationSelectedWithCoordinates:(CLLocation *)location andName:(NSString *)name;

@end


