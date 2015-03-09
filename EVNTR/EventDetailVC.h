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

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet PFImageView *eventCoverPhoto;
@property (weak, nonatomic) IBOutlet PFImageView *creatorPhoto;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet UILabel *eventDescription;
@property (weak, nonatomic) IBOutlet UILabel *dateOfEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventLocationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, strong) PFObject *eventObject;



@end
