//
//  EventDetailVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureFullScreenVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PeopleVC.h"
#import <MapKit/MapKit.h>

//TODO - ensure all protocols are necessary
@interface EventDetailVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, PeopleVCDelegate, UIScrollViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) PFObject *eventObject;

@end
