//
//  EventPicturesVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventObject.h"
#import "PictureFullScreenVC.h"

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol EventPicturesProtocol;

@interface EventPicturesVC : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, PictureViewerDelegate>

@property (nonatomic) BOOL allowsAddingPictures;
@property (nonatomic) BOOL allowsChoosingPictures;

@property (strong, nonatomic) EventObject *eventObject;
@property (nonatomic, weak) id <EventPicturesProtocol> delegate;

@end


@protocol EventPicturesProtocol <NSObject>

- (void) newPictureAdded;
- (void) pictureRemoved;

@end
