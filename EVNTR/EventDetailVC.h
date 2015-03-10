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

@interface EventDetailVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PictureViewerDelegate, PeopleVCDelegate>

@property (nonatomic, strong) PFObject *eventObject;

@end
