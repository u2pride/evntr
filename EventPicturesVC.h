//
//  EventPicturesVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "PictureFullScreenVC.h"

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EventPicturesVC : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PictureViewerDelegate>

@property (nonatomic) BOOL allowsAddingPictures;

@property (strong, nonatomic) PFObject *eventObject;

@end
