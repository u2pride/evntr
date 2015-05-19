//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AppDelegate.h"
#import "CommentsTableSource.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNUser.h"
#import "EVNUtility.h"
#import "EventDetailVC.h"
#import "EventPictureCell.h"
#import "IDTransitioningDelegate.h"
#import "FullMapVC.h"
#import "MapForEventView.h"
#import "MBProgressHUD.h"
#import "PeopleVC.h"
#import "PictureFullScreenVC.h"
#import "ProfileVC.h"
#import "StandbyCollectionViewCell.h"
#import "UIColor+EVNColors.h"
#import "UIImageEffects.h"
#import "UIButtonPFExtended.h"

#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>


@interface EventDetailVC () {
    
    int numNetworkCallsComplete;
}

@property BOOL isGuestUser;
@property (nonatomic)  BOOL isCurrentUserAttending;
@property BOOL isPublicApproved;
@property (nonatomic) BOOL isCurrentUsersEvent;

//Buttons
@property (strong, nonatomic) IBOutlet UIButtonPFExtended *rsvpStatusButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;
@property (strong, nonatomic) IBOutlet UILabel *viewAttending;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet UILabel *eventDescription;
@property (weak, nonatomic) IBOutlet UILabel *dateOfEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeOfEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *standbyListTitle;

//Images
@property (weak, nonatomic) IBOutlet PFImageView *creatorPhoto;

//CollectionViews & DataSources
@property (strong, nonatomic) IBOutlet UICollectionView *standbyUsersCollectionView;
@property (nonatomic, strong) NSArray *usersOnStandby;

//UI & Transitions
//@property (nonatomic, strong) UIImage *navBarBackground;
//@property (nonatomic, strong) UIImage *navbarShadow;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

//Loading Helpers
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UIView *fadeOutBlackScreen;

//Mapping Location Component
@property (strong, nonatomic) IBOutlet MapForEventView *entireMapView;
@property (strong, nonatomic) IBOutlet UIView *transparentTouchView;
@property (strong, nonatomic) CLLocation *locationOfEvent;
@property (strong, nonatomic) CLPlacemark *locationPlacemark;

//Picture Component
@property (strong, nonatomic) IBOutlet UILabel *numberOfPicturesLabel;
@property (strong, nonatomic) IBOutlet EVNButton *viewPicturesButton;


//Comments Component
@property (strong, nonatomic) IBOutlet UITableView *commentsTable;
@property (strong, nonatomic) CommentsTableSource *commentsController;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentsTopVerticalConstraint;


@property (nonatomic) BOOL shouldRestoreNavBar;

//Only YES if data model changes or viewing for first time.
@property (nonatomic) BOOL needsInfoUpdate;

- (IBAction)inviteFriends:(id)sender;
- (IBAction)viewEventPictures:(id)sender;
- (IBAction)rsvpToEvent:(id)sender;

@end


@implementation EventDetailVC


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _isPublicApproved = NO;
        _isCurrentUsersEvent = NO;
        _isCurrentUserAttending = NO;
        _isGuestUser = NO;
        numNetworkCallsComplete = 0;
        _needsInfoUpdate = YES;
        _shouldRestoreNavBar = YES;

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    
    [self.rsvpStatusButton startedTask];
    self.rsvpStatusButton.isRounded = NO;
    
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEventAttenders)];
    tapgr.numberOfTapsRequired = 1;
    self.viewAttending.text = @"View Attending";
    self.viewAttending.textColor = [UIColor orangeThemeColor];
    self.viewAttending.userInteractionEnabled = YES;
    [self.viewAttending addGestureRecognizer:tapgr];
    
    //Determine if Guest User
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    //Transition Delegate, Default Images, and ScrollView
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];

    //Determine if the Event Creator is the Current User
    if ([self.event.parent.objectId isEqualToString:[EVNUser currentUser].objectId]) {
        self.isCurrentUsersEvent = YES;
        NSLog(@"Current User's Event ");
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupStaticEventDetailComponents];
    
    self.commentsTable.estimatedRowHeight = 100.0;
    self.commentsTable.rowHeight = UITableViewAutomaticDimension;
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [PFAnalytics trackEventInBackground:@"ViewEvent" block:nil];

    NSLog(@"Event invitedUsers: %@", self.event.invitedUsers);
    
    if (self.shouldRestoreNavBar) {
        //Transparent Navigation Bar - Store Current State to Restore
        //self.navbarShadow = self.navigationController.navigationBar.shadowImage;
        //self.navBarBackground = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];

    } else {
        self.shouldRestoreNavBar = YES;
    }

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    //self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    int eventType = [self.event.typeOfEvent intValue];
    if (eventType != PUBLIC_APPROVED_EVENT_TYPE) {
        self.commentsTopVerticalConstraint.constant = 15;
        [self.view layoutIfNeeded];
    } else {
        self.commentsTopVerticalConstraint.constant = 155;
    }
    
    
    
    if (self.needsInfoUpdate) {

        //Reset Number of Network Call
        numNetworkCallsComplete = 0;
        
        //Create Black Loading Screen
        self.fadeOutBlackScreen = [[UIView alloc] initWithFrame:self.view.frame];
        self.fadeOutBlackScreen.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        //[self.view addSubview:self.fadeOutBlackScreen];
        
        //Progress Indicator - Start
        self.HUD = [[MBProgressHUD alloc] init];
        self.HUD.removeFromSuperViewOnHide = YES; //otherwise it blocks other views
        self.HUD.center = self.view.center;
        //[self.view addSubview:self.HUD];
        //[self.view bringSubviewToFront:self.HUD];
        //self.HUD.labelText = @"Event Loading";
        //[self.HUD show:YES];
        
        
        self.timeOfEventLabel.alpha = 0.0;
        self.dateOfEventLabel.alpha = 0.0;
        
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"Should restore: %@", [NSNumber numberWithBool:self.shouldRestoreNavBar]);
    
    if (self.shouldRestoreNavBar) {
    
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];

        //[self.navigationController.navigationBar setBackgroundImage:self.navBarBackground
         //                                             forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.shadowImage = self.navbarShadow;
        
        NSLog(@"Setting to Orange");
        self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        self.navigationController.navigationBar.translucent = NO;
        
        //Navigation Bar Font & Color
        NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    }
    
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if (self.needsInfoUpdate) {
        
        [self setBackgroundOfPictureSectionWithImage:[UIImage imageNamed:@"EventDefault"]];
        
        ///////////////////////////
        //Configuring Basic Details
        ///////////////////////////
        
        CGRect originalFrame = self.eventDescription.frame;
        
        self.eventTitle.text = self.event.title;
        self.dateOfEventLabel.text = [self.event eventDateShortStyle];
        self.timeOfEventLabel.text = [self.event eventTimeShortStye];
        self.eventDescription.text = self.event.descriptionOfEvent;
        self.eventDescription.textAlignment = NSTextAlignmentCenter;
        self.eventDescription.numberOfLines = 0;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.hyphenationFactor = 0.5f;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.event.descriptionOfEvent attributes:@{ NSParagraphStyleAttributeName : paragraphStyle }];
        self.eventDescription.attributedText = attributedString;
        
        CGRect resizedFrame = self.eventDescription.frame;
        self.eventDescription.frame = CGRectMake(resizedFrame.origin.x, resizedFrame.origin.y, originalFrame.size.width, resizedFrame.size.height);
        
        [self.event.coverPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *coverImage = [UIImage imageWithData:data];
            
            [self setBackgroundOfPictureSectionWithImage:coverImage];
            [self networkCallComplete];
        }];
        
        //self.backgroundForPictureSection.file = self.event.coverPhoto;
        //self.backgroundForPictureSection.image = [UIImage imageNamed:@"EventDefault"];
        //[self.backgroundForPictureSection loadInBackground:^(UIImage *image, NSError *error) {
            
            //NSLog(@"Image: %@ and then the property: %@", image, self.backgroundForPictureSection.image);
            
            //[self setBackgroundOfPictureSectionWithImage:image];
            //NSLog(@"Num 1");
            //[self networkCallComplete]; //1
            
        //}];
        
        
        [self setupCreatorComponent];
        [self setupMapComponent];
        
        ///////////////////////
        //Find Users on Standby
        ///////////////////////
        int eventType = [self.event.typeOfEvent intValue];

        if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
            
            [self.event queryForStandbyUsersWithIncludeKey:nil completion:^(NSError *error, NSArray *users) {
                
                if (error || users == nil) {
                    self.usersOnStandby = nil;
                } else {
                    self.usersOnStandby = users;
                }
                
                [self.standbyUsersCollectionView reloadData];
                
                NSLog(@"Num2");
                [self networkCallComplete]; //2
                
            }];
            
        } else {
            //collection view will see 0 when self.usersOnStandby.count is run
            self.usersOnStandby = nil;
        }
        
        ////////////////////////////
        //Configuring Action Buttons
        ////////////////////////////
        
        if (self.isGuestUser) {
            
            self.isCurrentUserAttending = NO;
            self.isCurrentUsersEvent = NO;
            self.standbyUsersCollectionView.allowsSelection = NO;
            
            self.rsvpStatusButton.titleText = @"Sign Up Required";
            self.viewAttending.text = @"Sign Up to View Attending Users";
            [self.inviteButton setTitle:@"Sign Up to Attend" forState:UIControlStateNormal];
            
            int eventType = [self.event.typeOfEvent intValue];
            if (eventType != PUBLIC_APPROVED_EVENT_TYPE) {
                self.standbyUsersCollectionView.hidden = YES;
                self.standbyListTitle.hidden = YES;
            }
            
            [self networkCallComplete]; //3
            
        } else {
            
            int eventType = [self.event.typeOfEvent intValue];
            NSString *userObjectId = [EVNUser currentUser].objectId;
            
            switch (eventType) {
                case PUBLIC_EVENT_TYPE: {
                    
                    [self.event queryRSVPForUserId:userObjectId completion:^(BOOL isAttending, NSString *status) {
                        
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            self.rsvpStatusButton.titleText = status;
                            
                            if (isAttending) {
                                self.rsvpStatusButton.isSelected = YES;
                            }
                        }
                        
                        NSLog(@"Num3");
                        [self networkCallComplete]; //3
                        
                    }];
                    
                    //Hide Collection View for Standby Users
                    self.standbyUsersCollectionView.hidden = YES;
                    self.standbyListTitle.hidden = YES;
                    
                    break;
                }
                case PRIVATE_EVENT_TYPE: {
                    
                    [self.event queryRSVPForUserId:userObjectId completion:^(BOOL isAttending, NSString *status) {
                        
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            self.rsvpStatusButton.titleText = status;
                            
                            if (isAttending) {
                                self.rsvpStatusButton.isSelected = YES;
                            }
                        }
                        
                        NSLog(@"Num3");
                        [self networkCallComplete]; //3
                        
                    }];
                    
                    //Hide Collection View for Standby Users
                    self.standbyUsersCollectionView.hidden = YES;
                    self.standbyListTitle.hidden = YES;
                    
                    break;
                }
                case PUBLIC_APPROVED_EVENT_TYPE: {
                    
                    self.isPublicApproved = YES;
                    
                    NSLog(@"CHECKPOINT 0");
                    
                    //Determine the state of the user with the event
                    // Hasn't requested Accesss - Requested Access - Granted Acccess
                    
                    [self.event queryApprovalStatusOfUser:[EVNUser currentUser] completion:^(BOOL isAttending, NSString *status) {
                        
                        if ([status isEqualToString:@"Error"]) {
                            //TODO: Error Handling
                            self.isCurrentUserAttending = NO;
                            self.rsvpStatusButton.titleText = @"Unknown";
                        } else {
                            
                            if (!self.isCurrentUsersEvent) {
                                self.isCurrentUserAttending = isAttending;
                                self.rsvpStatusButton.titleText = status;
                                
                                if ([status isEqualToString:kGrantedAccessToEvent] || [status isEqualToString:kRSVPedForEvent]) {
                                    self.rsvpStatusButton.isSelected = YES;
                                    self.rsvpStatusButton.isStateless = YES;
                                } else {
                                    self.rsvpStatusButton.isSelected = NO;
                                }
                                
                            }
                            
                            NSLog(@"Num3");
                            [self networkCallComplete]; //3
                        }
                        
                    }];
                
                    break;
                }
                    
                default: {
                    break;
                }
            }
        }
       
        self.needsInfoUpdate = NO;
    } else {
        //empty.
    }
    
}


#pragma mark - Setup Methods for Event Detail View

- (void) setupStaticEventDetailComponents {
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Creator Component and Invite Button - Default Image
    self.creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    [self.inviteButton setTitle:kInviteUsers forState:UIControlStateNormal];
    self.rsvpStatusButton.titleText = kNOTRSVPedForEvent;
    
    NSLog(@"self.isCurrentUsersEvent:%@", [NSNumber numberWithBool:self.isCurrentUsersEvent]);
    
    self.rsvpStatusButton.hidden = (self.isCurrentUsersEvent) ? YES : NO;
    self.inviteButton.hidden = (self.isCurrentUsersEvent) ? NO : YES;

    //Standby Component - UICollectionView
    self.standbyUsersCollectionView.delegate = self;
    self.standbyUsersCollectionView.dataSource = self;
    //self.standbyUsersCollectionView.backgroundColor = [UIColor orangeThemeColor];
    self.standbyUsersCollectionView.tag = 2;
    UICollectionViewFlowLayout *collectionViewLayout2 = (UICollectionViewFlowLayout*)self.standbyUsersCollectionView.collectionViewLayout;
    collectionViewLayout2.minimumInteritemSpacing = 20;
    collectionViewLayout2.minimumLineSpacing = 20;
    
    //Map Component - (moved) Disable Interaction with Map View and Wire Up Transparent Touch View on Top of Map View
    self.entireMapView.mapView.userInteractionEnabled = NO;
    self.transparentTouchView.backgroundColor = [UIColor clearColor];

    
    //Picture Component
    self.viewPicturesButton.titleText = @"View";
    self.viewPicturesButton.isStateless = YES;
    self.viewPicturesButton.isSelected = NO;
    self.viewPicturesButton.buttonColorOpposing = [UIColor clearColor];

    [self.event estimateNumberOfPhotosWithCompletion:^(int count) {
        self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d", count];
    }];

    if (!self.isGuestUser) {
        
        //Add Edit Button if Creator is Current User
        if (self.isCurrentUsersEvent) {
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"editEvent"] style:UIBarButtonItemStylePlain target:self action:@selector(editEvent)];
            self.navigationItem.rightBarButtonItem = editButton;
        }
        
    }
    
    //Setup Comments Component
    self.commentsController = [[CommentsTableSource alloc] initWithEvent:self.event withTable:self.commentsTable];
    self.commentsController.delegate = self;
    
}


- (void) setupMapComponent {
    
    [self.entireMapView startedLoading];
    
    self.locationOfEvent = [[CLLocation alloc] initWithLatitude:self.event.locationOfEvent.latitude longitude:self.event.locationOfEvent.longitude];
    
    //Getting Current Location and Comparing to Event Location
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = [appDelegate.locationManagerGlobal location];
    
    if (!currentLocation) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userLocationDictionary = [userDefaults objectForKey:kLocationCurrent];
        
        NSNumber *latitude = [userLocationDictionary objectForKey:@"latitude"];
        NSNumber *longitude = [userLocationDictionary objectForKey:@"longitude"];
        
        currentLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        
        [PFAnalytics trackEvent:@"CurrentLocationNil"];
    }

    CLLocationDirection distance = [self.locationOfEvent distanceFromLocation:currentLocation];

    self.entireMapView.distanceAway = (float) distance * 0.000621371;
    self.entireMapView.eventLocation = self.locationOfEvent;
    
    //Determining Event Address
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationOfEvent completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (!error && placemarks.count > 0) {
            self.locationPlacemark = [placemarks firstObject];
            self.entireMapView.address = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(self.locationPlacemark.addressDictionary, NO)];
        } else {
            self.entireMapView.address = [NSString stringWithFormat:@"%.2f - %.2f", self.event.locationOfEvent.latitude, self.event.locationOfEvent.longitude];
        }
        
        self.entireMapView.address = self.event.nameOfLocation;
        
        NSLog(@"Num5");
        [self networkCallComplete]; //5
        
        
    }];
    
    //Location Name
    NSString *locationName = self.event.nameOfLocation;
    
    if (!locationName) {
        locationName = @"Custom Location";
    } else if ([locationName isEqualToString:@"Current Location"]) {
        locationName = [NSString stringWithFormat:@"%.2f - %.2f", self.event.locationOfEvent.latitude, self.event.locationOfEvent.longitude];
        
    }
    
}

- (void) setupCreatorComponent {
        
    //Tap Gesture for Event Creator Photo
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
    self.creatorPhoto.userInteractionEnabled = YES;
    [self.creatorPhoto addGestureRecognizer:tapgr];
    
    
    [self.event.parent fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
        
        self.creatorName.textColor = [UIColor orangeThemeColor];
        self.creatorName.text = user[@"username"];
        self.creatorName.userInteractionEnabled = YES;
        [self.creatorName addGestureRecognizer:tapgr2];
        
        self.creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [self.creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
            
            NSLog(@"Num6");
            [self networkCallComplete]; //6
        }];
        
        NSLog(@"Num7");
        [self networkCallComplete]; //7
        
    }];
    
}


- (void) setBackgroundOfPictureSectionWithImage:(UIImage *)image {
    
    UIImage *blurredBackgroundImage = [UIImageEffects imageByApplyingBlurToImage:image withRadius:30.0 tintColor:[UIColor colorWithWhite:0.08 alpha:0.8] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.view.layer.contents = (id)blurredBackgroundImage.CGImage;
}



- (void)setIsCurrentUserAttending:(BOOL)isCurrentUserAttending {
    
    self.commentsController.allowAddingComments = isCurrentUserAttending;
    
    _isCurrentUserAttending = isCurrentUserAttending;
}

- (void) setIsCurrentUsersEvent:(BOOL)isCurrentUsersEvent {
    
    NSLog(@"Setting is CurrentUsersEvent");
    if (isCurrentUsersEvent) {
        NSLog(@"now actually setting it");
        self.commentsController.allowAddingComments = YES;
    }
    
    _isCurrentUsersEvent = isCurrentUsersEvent;
}



#pragma mark - Helpers for Determing Whether to Show or Hide Event Details for PA Events

- (void) networkCallComplete {
    
    numNetworkCallsComplete += 1;
    NSLog(@"NumNetworkCallsComplete: %d", numNetworkCallsComplete);
    
    if (numNetworkCallsComplete == 5) {
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recheckPublicApprovedAccess) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.fadeOutBlackScreen.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.HUD hide:YES];
            
        }];
        
    }
    
}

- (void) recheckPublicApprovedAccess {
    
    //unhide all important details
    // map location - address and distance - use function [map finishedWithDetails] - loading before this finishes.
    // event details - blank with loading indicator. [details finishedWithTime: andDateString: ]
    // RSVP Button - loading indicator.  set text throughout loading but keep hidden until finished checking public approved
    
    //keep these all disabled until loading is finished.
    //currently:  the following things are what contribute to the event details load:
    

    NSLog(@"Rechecking Pa Access - %@ and %@ and %@ and %@", [NSNumber numberWithBool:self.isPublicApproved], [NSNumber numberWithBool:self.isCurrentUserAttending], [NSNumber numberWithBool:self.isCurrentUsersEvent], [NSNumber numberWithBool:self.isGuestUser]);
    
    if ((self.isPublicApproved && !self.isCurrentUserAttending && !self.isCurrentUsersEvent) || self.isGuestUser) {
        
        NSLog(@"In the wrong place");
    
        self.transparentTouchView.hidden = YES;
        self.locationOfEvent = [[CLLocation alloc] initWithLatitude:37.749 longitude:-122.4167];
        
        self.entireMapView.address = [NSString stringWithFormat:@"Unknown"];
        self.entireMapView.distanceAway = 0.0f;
        self.dateOfEventLabel.text = @"Unknown";
        self.timeOfEventLabel.text = @"Unknown";
        
        [self.rsvpStatusButton endedTask];
        [self.entireMapView finishedLoadingWithLocationAvailable:NO];
        
    } else {
        
        NSLog(@"In the right place");
        
        [self.rsvpStatusButton endedTask];
        [self.entireMapView finishedLoadingWithLocationAvailable:YES];
        
    }
    
    UITapGestureRecognizer *tapMapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedMap)];
    [self.transparentTouchView addGestureRecognizer:tapMapView];
    
    self.dateOfEventLabel.alpha = 1.0;
    self.timeOfEventLabel.alpha = 1.0;

}




#pragma mark - Touched Map Event

- (void) touchedMap {
    
    FullMapVC *mapViewController = [[FullMapVC alloc] init];

    mapViewController.locationPlacemark = self.locationPlacemark;
    mapViewController.locationOfEvent = self.locationOfEvent;
    mapViewController.eventLocationName = self.event.nameOfLocation;
    mapViewController.hidesBottomBarWhenPushed = YES;
    //self.shouldRestoreNavBar = YES;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
    
}


#pragma mark CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.usersOnStandby count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *standbyCellID = @"StandbyUserCell";
        
        StandbyCollectionViewCell *cell = (StandbyCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:standbyCellID forIndexPath:indexPath];
        
        EVNUser *currentUser = [self.usersOnStandby objectAtIndex:indexPath.row];
        
        cell.profilePictureOfStandbyUser.image = [UIImage imageNamed:@"PersonDefault"];
        cell.profilePictureOfStandbyUser.file = currentUser[@"profilePicture"];
        [cell.profilePictureOfStandbyUser loadInBackground];
    
        cell.profilePictureOfStandbyUser.objectForImageView = currentUser;
        
        return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isGuestUser) {
        
        EVNUser *selectedUser = [self.usersOnStandby objectAtIndex:indexPath.row];
        
        ProfileVC *profileView = (ProfileVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileView.userObjectID = selectedUser.objectId;
        
        [self.navigationController pushViewController:profileView animated:YES];
        
    }
    
}





#pragma mark - Actions Performed By User

- (void) viewCreatorProfile {
    
    NSLog(@"View Creator Profile - guest %@", [NSNumber numberWithBool:self.isGuestUser]);
    
    if (!self.isGuestUser) {
        ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        viewUserProfileVC.userObjectID = self.event.parent.objectId;
        viewUserProfileVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    }
    
}

- (void) editEvent {
    
    NSLog(@"Edit Event");
    
    //TODO:  Must present this similarly to the way an add event modal is presented.
    
    AddEventPrimaryVC *editEventVC = (AddEventPrimaryVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventFirstStep"];
    editEventVC.delegate = self;
    editEventVC.eventToEdit = self.event;
    
    [self.navigationController pushViewController:editEventVC animated:YES];
    
    
}


- (IBAction)inviteFriends:(id)sender {
    
    if (!self.isGuestUser) {
        
        self.shouldRestoreNavBar = NO;
        
        PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
        invitePeopleVC.userProfile = [EVNUser currentUser];
        invitePeopleVC.usersAlreadyInvited = self.event.invitedUsers;
        invitePeopleVC.delegate = self;
        
        UINavigationController *embedInThisVC = [[UINavigationController alloc] initWithRootViewController:invitePeopleVC];
        
        [self presentViewController:embedInThisVC animated:YES completion:nil];
        
        //[self.navigationController pushViewController:invitePeopleVC animated:YES];
    }
}




- (void) viewEventAttenders {
    
    if (self.isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
    } else {
        
        PeopleVC *viewAttendees = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        
        viewAttendees.typeOfUsers = VIEW_EVENT_ATTENDERS;
        viewAttendees.eventToViewAttenders = self.event;
        
        [self.navigationController pushViewController:viewAttendees animated:YES];
    }
    
}


- (IBAction)viewEventPictures:(id)sender {
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    
    EventPicturesVC *allEventPictures = [[EventPicturesVC alloc] initWithCollectionViewLayout:flowLayout];
    
    //Pass the Event
    allEventPictures.eventObject = self.event;
    allEventPictures.delegate = self;
    allEventPictures.hidesBottomBarWhenPushed = YES;
    //allEventPictures.allowsAddingPictures = self.isCurrentUserAttending;
    
    if (self.isCurrentUsersEvent) {
        
        allEventPictures.allowsAddingPictures = YES;
        
    } else {
        
        if (self.isCurrentUserAttending) {
            allEventPictures.allowsAddingPictures = [self.event allowUserToAddPhotosAtThisTime];
        } else {
            allEventPictures.allowsAddingPictures = NO;
        }
        
    }

    [self.navigationController pushViewController:allEventPictures animated:YES];
    
}

//Current: User is added to the event as a Relation.  No information about the activity is stored (ie timestamp)
//Update:  User is added to the event as a Relation and an entry in the activity table is created - will be used for Activity/Notifications View.
//Long-Term:  Is this the best solution?

- (IBAction)rsvpToEvent:(id)sender {
    
    int eventType = [self.event.typeOfEvent intValue];
    
    //Cases:  Guest User - PA Event Request Access - Attending Already - Not Attending
    
    if (self.isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
        
    } else if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        //Currently only allowing A Request for access not to revoke
        if ([self.rsvpStatusButton.titleText isEqualToString:kNOTRSVPedForEvent]) {
            
            self.rsvpStatusButton.enabled = NO;
            
            [self.event requestAccessForUser:[EVNUser currentUser] completion:^(BOOL success) {
                
                if (success) {
                    self.rsvpStatusButton.titleText = kRSVPedForEvent;
                    self.rsvpStatusButton.isSelected = YES;
                    
                    NSMutableArray *updatedStandbyListWithCurrentUser = [NSMutableArray arrayWithArray:self.usersOnStandby];
                    [updatedStandbyListWithCurrentUser addObject:[EVNUser currentUser]];
                    self.usersOnStandby = [NSArray arrayWithArray:updatedStandbyListWithCurrentUser];
                    [self.standbyUsersCollectionView reloadData];
                }
                self.rsvpStatusButton.enabled = YES;
                
            }];

        }
        
    } else if (eventType == PUBLIC_EVENT_TYPE || eventType == PRIVATE_EVENT_TYPE) {
        
        PFRelation *attendersRelation = self.event.attenders;
        self.rsvpStatusButton.enabled = NO;
        
        //Updating Relation
        if ([self.rsvpStatusButton.titleText isEqualToString:kAttendingEvent]) {
            
            [attendersRelation removeObject:[EVNUser currentUser]];
            [self.event saveInBackground];
            
            //[self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
            
        } else {
            
            //Create New Relation and Add User to List of Attenders for Event
            [attendersRelation addObject:[EVNUser currentUser]];
            [self.event saveInBackground];
            
            //[self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
        }
        
        
        //Updating the Activity Table (choose one?)
        if ([self.rsvpStatusButton.titleText isEqualToString:kAttendingEvent]) {
            
            [self.event unRSVPUser:[EVNUser currentUser] completion:^(BOOL success) {
                
                if (success) {
                    self.isCurrentUserAttending = NO;
                    self.rsvpStatusButton.titleText = kNotAttendingEvent;
                    self.rsvpStatusButton.isSelected = NO;
                    
                    //Notify Table Cell of Update in RSVP Count
                    id<EventDetailProtocol> strongDelegate = self.delegate;
                    if ([strongDelegate respondsToSelector:@selector(rsvpStatusUpdatedToGoing:)]) {
                        [strongDelegate rsvpStatusUpdatedToGoing:NO];
                    }
                } else {
                    //TODO: PFAnalytics
                }
                
                //Re-Enable RSVP Button
                self.rsvpStatusButton.enabled = YES;
                
            }];
            
        } else {
            
            [self.event rsvpUser:[EVNUser currentUser] completion:^(BOOL success) {
                
                if (success) {
                    self.isCurrentUserAttending = YES;
                    self.rsvpStatusButton.titleText = kAttendingEvent;
                    self.rsvpStatusButton.isSelected = YES;
                    
                    //Notify Table Cell of Update in RSVP Count
                    id<EventDetailProtocol> strongDelegate = self.delegate;
                    if ([strongDelegate respondsToSelector:@selector(rsvpStatusUpdatedToGoing:)]) {
                        [strongDelegate rsvpStatusUpdatedToGoing:YES];
                    }
                } else {
                    //TODO: Log Error with PFAnalytics
                }
                
                //Re-Enable Button
                self.rsvpStatusButton.enabled = YES;
                
            }];
            
        }
        
    }

}


#pragma mark - Delegate Methods for Editing An Event

/*
- (NSDictionary *) eventDetailsToEdit {
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.event.typeOfEvent, @"type", self.event.title, @"title", self.backgroundForPictureSection.image, @"image", self.backgroundForPictureSection.file, @"file", self.event.description, @"description", self.event.locationOfEvent, @"coordinates", self.event.nameOfLocation, @"locationName", self.event.dateOfEvent, @"date", self.event, @"object", nil];
    
    return dictionary;
}
*/

//update the view with the new event details - not pulling from parse
- (void) completedEventEditing:(EventObject *)updatedEvent {
    
    
    self.eventTitle.text = updatedEvent.title;
    self.eventDescription.text = updatedEvent.descriptionOfEvent;

    //Update the Event Based on the Event Type - Currently just showing/hiding standby view and requerying for users
    if ([updatedEvent.typeOfEvent intValue] == PUBLIC_APPROVED_EVENT_TYPE) {
        self.standbyUsersCollectionView.hidden = NO;
        self.standbyListTitle.hidden = NO;
        
        [updatedEvent queryForStandbyUsersWithIncludeKey:nil completion:^(NSError *error, NSArray *users) {
            
            if (error || users == nil) {
                self.usersOnStandby = nil;
            } else {
                self.usersOnStandby = users;
            }
            
            [self.standbyUsersCollectionView reloadData];
            
        }];
        
    } else {
        
        self.standbyUsersCollectionView.hidden = YES;
        self.standbyListTitle.hidden = YES;

    }

    
    //TODO: Not Working
    [updatedEvent coverImage:^(UIImage *image) {
        
        [self setBackgroundOfPictureSectionWithImage:image];
    }];
    
    //Update Map with New Event Location
    [self setupMapComponent];
    
    //Update Date and Time
    self.dateOfEventLabel.text = [self.event eventDateShortStyle];
    self.timeOfEventLabel.text = [self.event eventTimeShortStye];
    
    id<EventDetailProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(userCompletedEventEditing)]) {
        [strongDelegate userCompletedEventEditing];
    }
    
    [self recheckPublicApprovedAccess];
    
    [self.navigationController popViewControllerAnimated:YES];

    
}


- (void) canceledEventEditing {
    NSLog(@"Back to Event Details - canceled event editing");
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Delegate Method for Inviting Users to Event

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.event inviteUsers:selectedPeople completion:^(BOOL success) {
        NSLog(@"finished inviting users with : %@", [NSNumber numberWithBool:success]);
    }];
    
    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved invite pfrelations");
    }];

}


#pragma mark - Event Pictures Protocol
- (void) newPictureAdded {
    
    NSString *currentPictureCountString = self.numberOfPicturesLabel.text;
    int newCount = [currentPictureCountString intValue] + 1;
    self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d", newCount];
    
}

- (void) pictureRemoved {
    
    NSString *currentPictureCountString = self.numberOfPicturesLabel.text;
    int newCount = [currentPictureCountString intValue] - 1;
    self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d", newCount];
    
}



#pragma mark - EVNComment Protocol

- (void) addNewComment {
    
    if (self.isCurrentUserAttending || self.isCurrentUsersEvent) {
        
        self.shouldRestoreNavBar = NO;
        
        EVNAddCommentVC *newCommentVC = [[EVNAddCommentVC alloc] init];
        newCommentVC.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newCommentVC];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}


- (void) cancelComment {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) submitCommentWithText:(NSString *)commentString {
    
    //Add Event To Comment and Save to Backend
    PFObject *newComment = [PFObject objectWithClassName:@"Comments"];
    newComment[@"commentText"] = commentString;
    newComment[@"commentParent"] = [EVNUser currentUser];
    newComment[@"commentEvent"] = self.event;
    
    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            NSLog(@"saved comment");
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                NSArray *firstIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]];

                [self.commentsController.commentsData insertObject:newComment atIndex:0];
                [self.commentsController.commentsTable insertRowsAtIndexPaths:firstIndexPath withRowAnimation:UITableViewRowAnimationFade];

            }];

            
        } else {
            //error
        }
        
    }];
    
}


-(void)dealloc
{
    [self.entireMapView.timerForRandomize invalidate];
    
    NSLog(@"eventdetailsvc is being deallocated");
}

@end
