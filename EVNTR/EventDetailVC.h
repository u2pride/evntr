//
//  EventDetailVC.h
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AddEventSecondVC.h"
#import "CommentsTableSource.h"
#import "EVNAddCommentVC.h"
#import "EventObject.h"
#import "EventPicturesVC.h"
#import "PeopleVC.h"
#import "PictureFullScreenVC.h"

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@protocol EventDetailProtocol;

@interface EventDetailVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, PeopleVCDelegate, UIScrollViewDelegate, MKMapViewDelegate, EventModalProtocol, EventCreationCompleted, EventPicturesProtocol, EVNAddCommentProtocol, EVNCommentsTableProtocol>

@property (nonatomic, strong) EventObject *event;
@property (nonatomic, weak) id <EventDetailProtocol> delegate;

@property (nonatomic) BOOL shouldScrollToComments;

@end


//For UI Updates to Home Screen Cells
@protocol EventDetailProtocol <NSObject>

@optional
- (void) updateEventCellAfterEdit;
- (void) rsvpStatusUpdatedToGoing:(BOOL)rsvp;

@end
