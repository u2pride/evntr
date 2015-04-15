//
//  EventDetailVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventObject.h"
#import "EventPicturesVC.h"
#import "PeopleVC.h"
#import "PictureFullScreenVC.h"
#import "AddEventPrimaryVC.h"
#import "AddEventSecondVC.h"
#import "EVNAddCommentVC.h"
#import "CommentsTableSource.h"

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@protocol EventDetailProtocol;

//TODO - ensure all protocols are necessary
@interface EventDetailVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, PeopleVCDelegate, UIScrollViewDelegate, MKMapViewDelegate, EventModalProtocol, EventCreationCompleted, EventPicturesProtocol, EVNAddCommentProtocol, EVNCommentsTableProtocol>

@property (nonatomic, strong) EventObject *event;
@property (nonatomic, strong) id <EventDetailProtocol> delegate;

@end


@protocol EventDetailProtocol <NSObject>

- (void) userCompletedEventEditing;
- (void) rsvpStatusUpdatedToGoing:(BOOL)rsvp;
@end
