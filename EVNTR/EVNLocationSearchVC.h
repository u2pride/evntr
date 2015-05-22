//
//  EVNLocationSearchVC.h
//  EVNTR
//
//  Created by Alex Ryan on 5/7/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@protocol EventLocationSearch;

@interface EVNLocationSearchVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<EventLocationSearch> delegate;

@end


@protocol EventLocationSearch <NSObject>

- (void) locationSearchDidCancel;
- (void) locationSelectedWithCoordinates:(CLLocation *)location andName:(NSString *)name;

@end
