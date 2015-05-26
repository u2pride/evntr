//
//  PictureFullScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol PictureViewerDelegate;

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@interface PictureFullScreenVC : UIViewController

@property (weak, nonatomic) IBOutlet PFImageView *eventPhotoView;

@property (nonatomic, strong) PFObject *eventPictureObject;
@property (nonatomic, weak) id<PictureViewerDelegate> delegate;

@property (nonatomic) BOOL showRemovePhotoAction;

@end

@protocol PictureViewerDelegate <NSObject>

- (void) returnToPicturesViewAndDeletePhoto:(BOOL) shouldDeletePhoto;

@end
