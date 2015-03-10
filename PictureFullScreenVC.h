//
//  PictureFullScreenVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

@protocol PictureViewerDelegate;

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface PictureFullScreenVC : UIViewController

@property (weak, nonatomic) IBOutlet PFImageView *eventPhotoView;

@property (nonatomic, strong) PFFile *fileOfEventPhoto;
@property (nonatomic, weak) id<PictureViewerDelegate> delegate;

@end

@protocol PictureViewerDelegate <NSObject>

-(void)returnToEvent;

@end
