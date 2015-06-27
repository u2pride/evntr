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
#import "FullMapVC.h"
#import "IDTTransitioningDelegate.h"
#import "MBProgressHUD.h"
#import "MapForEventView.h"
#import "PeopleVC.h"
#import "PictureFullScreenVC.h"
#import "ProfileVC.h"
#import "StandbyCollectionViewCell.h"
#import "EVNButtonExtended.h"
#import "UIColor+EVNColors.h"
#import "UIImageEffects.h"

#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>


@interface EventDetailVC () {
    
    int numNetworkCallsComplete;
}

@property (nonatomic) BOOL isGuestUser;
@property (nonatomic) BOOL isCurrentUserAttending;
@property (nonatomic) BOOL isPublicApproved;
@property (nonatomic) BOOL isCurrentUsersEvent;

//UIViews
@property (strong, nonatomic) IBOutlet UIView *detailsBackgroundView;

//Buttons
@property (strong, nonatomic) IBOutlet EVNButtonExtended *rsvpStatusButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;
@property (strong, nonatomic) IBOutlet UILabel *viewAttending;
@property (strong, nonatomic) IBOutlet UIImageView *flagEvent;
@property (strong, nonatomic) IBOutlet UIImageView *inviteUsers;

//Labels
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet UILabel *dateOfEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeOfEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *standbyListTitle;
@property (strong, nonatomic) IBOutlet UITextView *eventDescriptionTextView;

//Images
@property (weak, nonatomic) IBOutlet PFImageView *creatorPhoto;

//CollectionViews & DataSources
@property (strong, nonatomic) IBOutlet UICollectionView *standbyUsersCollectionView;
@property (nonatomic, strong) NSArray *usersOnStandby;

//UI & Transitions
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

//Loading Helpers
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UIView *fadeOutBlackScreen;
@property (nonatomic, strong) UIActivityIndicatorView *detailsLoadingView;

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

@property (nonatomic) BOOL shouldRestoreNavBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentsTopVerticalConstraint;

@property (nonatomic) BOOL needsInfoUpdate;

- (IBAction)inviteFriends:(id)sender;
- (IBAction)viewEventPictures:(id)sender;
- (IBAction)rsvpToEvent:(id)sender;

@end


@implementation EventDetailVC

#pragma mark - Initialization Methods

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

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.rsvpStatusButton startedTask];
    self.rsvpStatusButton.isRounded = NO;
    
    //Determine if the Event Creator is the Current User
    if ([self.event.parent.objectId isEqualToString:[EVNUser currentUser].objectId]) {
        self.isCurrentUsersEvent = YES;
    }
    //Determine if Guest User
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    //Transition Delegate, Default Images, and ScrollView
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.customTransitionDelegate = [[IDTTransitioningDelegate alloc] init];
    
    [self setupStaticEventDetailComponents];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [PFAnalytics trackEventInBackground:@"ViewEvent" block:nil];
    
    if (!self.shouldRestoreNavBar) {
        self.shouldRestoreNavBar = YES;
    }

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    
    int eventType = [self.event.typeOfEvent intValue];
    if (eventType != PUBLIC_APPROVED_EVENT_TYPE) {
        self.commentsTopVerticalConstraint.constant = 15;
    } else {
        self.commentsTopVerticalConstraint.constant = 155;
    }
    
    [self.view layoutIfNeeded];
    

    if (self.needsInfoUpdate) {
        
        numNetworkCallsComplete = 0;
        
        self.fadeOutBlackScreen = [[UIView alloc] initWithFrame:self.view.frame];
        self.fadeOutBlackScreen.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        
        //Progress Indicator - Start
        self.HUD = [[MBProgressHUD alloc] init];
        self.HUD.removeFromSuperViewOnHide = YES; //otherwise it blocks other views
        self.HUD.center = self.view.center;
        
        self.timeOfEventLabel.alpha = 0.0;
        self.dateOfEventLabel.alpha = 0.0;
        self.viewAttending.alpha = 0.0;
        
    }
    
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.shouldRestoreNavBar) {
    
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        
        self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        self.tabBarController.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
        self.navigationController.navigationBar.translucent = NO;
        
        self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
    }
    
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if (self.needsInfoUpdate) {
        
        [self updateDetailView];
        
    }
    
    //Update Picture Count
    [self.event fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        EventObject *eventFetched = (EventObject *) object;
        
        if (eventFetched.numPictures) {
            self.numberOfPicturesLabel.text = [eventFetched.numPictures stringValue];
        } else {
            self.numberOfPicturesLabel.text = @"0";
        }
        
    }];
    
}


#pragma mark - Helper Setup Methods

- (void) updateDetailView {
    
    [self.detailsLoadingView startAnimating];
    
    [self setBackgroundOfPictureSectionWithImage:[UIImage imageNamed:@"EventDefault"]];
    
    ///////////////////////////
    //Configuring Basic Details
    ///////////////////////////
    
    self.eventTitle.text = self.event.title;
    self.dateOfEventLabel.text = [self.event eventDateShortStyleAndVisible:YES];
    self.timeOfEventLabel.text = [self.event eventTimeShortStyeAndVisible:YES];
    
    self.eventDescriptionTextView.editable = YES;
    self.eventDescriptionTextView.editable = NO;
    self.eventDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.eventDescriptionTextView.textColor = [UIColor whiteColor];
    self.eventDescriptionTextView.text = nil;
    self.eventDescriptionTextView.text = self.event.descriptionOfEvent;
    self.eventDescriptionTextView.editable = YES;
    self.eventDescriptionTextView.editable = NO;
    
    [self.event.coverPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error) {
            UIImage *coverImage = [UIImage imageWithData:data];
            [self setBackgroundOfPictureSectionWithImage:coverImage];
        }
        
        [self networkCallComplete];
    }];
    
    [self setupCreatorComponent];
    [self setupMapComponent];
    
    ///////////////////////
    //Find Users on Standby
    ///////////////////////
    int eventType = [self.event.typeOfEvent intValue];
    
    if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        [self.event queryForStandbyUsersWithIncludeKey:nil completion:^(NSError *error, NSArray *users) {
            
            if (error || [users count] == 0) {
                self.usersOnStandby = nil;
            } else {
                self.usersOnStandby = users;
            }
            
            [self.standbyUsersCollectionView reloadData];
            
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
        //NSString *userObjectId = [EVNUser currentUser].objectId;
        
        switch (eventType) {
            case PUBLIC_EVENT_TYPE: {
                
                [self.event queryRSVPForUser:[EVNUser currentUser] completion:^(BOOL isAttending, NSString *status, BOOL error) {
                    
                    if (!error) {
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            self.rsvpStatusButton.titleText = status;
                            
                            if (isAttending) {
                                self.rsvpStatusButton.isSelected = YES;
                            }
                        }
                    } else {
                        self.rsvpStatusButton.titleText = @"";
                    }
                    
                    [self networkCallComplete]; //3
                    
                }];
                
                //Hide Collection View for Standby Users
                self.standbyUsersCollectionView.hidden = YES;
                self.standbyListTitle.hidden = YES;
                
                break;
            }
            case PRIVATE_EVENT_TYPE: {
                
                [self.event queryRSVPForUser:[EVNUser currentUser] completion:^(BOOL isAttending, NSString *status, BOOL error) {
                    
                    if (!error) {
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            self.rsvpStatusButton.titleText = status;
                            
                            if (isAttending) {
                                self.rsvpStatusButton.isSelected = YES;
                            }
                        }
                    } else {
                        self.rsvpStatusButton.titleText = @"";
                    }
                    
                    [self networkCallComplete]; //3
                    
                }];
                
                //Hide Collection View for Standby Users
                self.standbyUsersCollectionView.hidden = YES;
                self.standbyListTitle.hidden = YES;
                
                break;
            }
            case PUBLIC_APPROVED_EVENT_TYPE: {
                
                self.isPublicApproved = YES;
                
                //Determine the state of the user with the event
                // Hasn't requested Accesss - Requested Access - Granted Acccess
                
                [self.event queryApprovalStatusOfUser:[EVNUser currentUser] completion:^(BOOL isAttending, NSString *status, BOOL error) {
                    
                    if (!error) {
                        
                        if (!self.isCurrentUsersEvent) {
                            
                            self.isCurrentUserAttending = isAttending;
                            self.rsvpStatusButton.titleText = status;
                            
                            if ([status isEqualToString:kAttendingEvent] || [status isEqualToString:kRSVPedForEvent]) {
                                self.rsvpStatusButton.isSelected = YES;
                                //self.rsvpStatusButton.isStateless = YES;
                            } else {
                                self.rsvpStatusButton.isSelected = NO;
                            }
                            
                        }
                        
                    } else {
                        
                        self.isCurrentUserAttending = NO;
                        self.rsvpStatusButton.titleText = @"";
                    }
                    
                    [self networkCallComplete]; //3
                    
                }];
                
                break;
            }
                
            default: {
                break;
            }
        }
    }
    
    self.needsInfoUpdate = NO;
    
}

- (void) setupStaticEventDetailComponents {
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Loading Indicator
    self.detailsLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.detailsLoadingView.center = self.detailsBackgroundView.center;
    self.detailsLoadingView.hidesWhenStopped = YES;
    [self.detailsBackgroundView.superview addSubview:self.detailsLoadingView];
    
    //Setup Flag Button
    self.flagEvent.userInteractionEnabled = YES;
    UITapGestureRecognizer *flagGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagCurrentEvent)];
    [self.flagEvent addGestureRecognizer:flagGR];
    
    //Setup Invite Button
    self.inviteUsers.userInteractionEnabled = YES;
    UITapGestureRecognizer *inviteGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFriends:)];
    [self.inviteUsers addGestureRecognizer:inviteGR];
    self.inviteUsers.hidden = YES;

    //View Users Attending
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEventAttenders)];
    tapgr.numberOfTapsRequired = 1;
    self.viewAttending.text = @"View Attending";
    self.viewAttending.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
    self.viewAttending.textColor = [UIColor orangeThemeColor];
    self.viewAttending.userInteractionEnabled = YES;
    [self.viewAttending addGestureRecognizer:tapgr];
    
    //Creator Component and Invite Button - Default Image
    self.creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    [self.inviteButton setTitle:kInviteUsers forState:UIControlStateNormal];
    self.rsvpStatusButton.titleText = kNOTRSVPedForEvent;
    
    self.rsvpStatusButton.hidden = (self.isCurrentUsersEvent) ? YES : NO;
    self.inviteButton.hidden = (self.isCurrentUsersEvent) ? NO : YES;

    //Standby Component - UICollectionView
    self.standbyUsersCollectionView.delegate = self;
    self.standbyUsersCollectionView.dataSource = self;
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
    self.numberOfPicturesLabel.text = @"0";
    
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
    self.commentsController.allowAddingComments = (self.isCurrentUsersEvent || self.isCurrentUserAttending);
    
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
        
        if (!error) {
            
            UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
            
            self.creatorName.textColor = [UIColor orangeThemeColor];
            self.creatorName.text = user[@"username"];
            self.creatorName.userInteractionEnabled = YES;
            [self.creatorName addGestureRecognizer:tapgr2];
            
            self.creatorPhoto.file = (PFFile *)user[@"profilePicture"];
            [self.creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
                
                [self networkCallComplete]; //6
            }];
            
            [self networkCallComplete]; //7
            
        } else {
            
            //TODO : Temp Solution - this fails and creator component is empty.
            [self networkCallComplete]; //6
            [self networkCallComplete]; //7

        }
        
    }];
    
}


- (void) setBackgroundOfPictureSectionWithImage:(UIImage *)image {
    
    UIImage *blurredBackgroundImage = [UIImageEffects imageByApplyingBlurToImage:image withRadius:35.0 tintColor:[UIColor colorWithWhite:0.08 alpha:0.8] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.view.layer.contents = (id)blurredBackgroundImage.CGImage;
}



#pragma mark - Custom Setters

- (void)setIsCurrentUserAttending:(BOOL)isCurrentUserAttending {
    
    self.commentsController.allowAddingComments = isCurrentUserAttending;

    _isCurrentUserAttending = isCurrentUserAttending;
    
    [self inviteUsersIconVisibilityCheck];
    
}

- (void) setIsCurrentUsersEvent:(BOOL)isCurrentUsersEvent {
    
    if (isCurrentUsersEvent) {
        self.commentsController.allowAddingComments = YES;
    }
    
    _isCurrentUsersEvent = isCurrentUsersEvent;
}



#pragma mark - Helpers for Determing Whether to Show or Hide Event Details for PA Events

- (void) networkCallComplete {
    
    numNetworkCallsComplete += 1;
    
    if (numNetworkCallsComplete == 5) {
        
        //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recheckPublicApprovedAccessDueToNewRSVP:) userInfo:nil repeats:NO];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self recheckPublicApprovedAccessDueToNewRSVP:NO];
            
        });
        
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.fadeOutBlackScreen.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.HUD hide:YES];
            
        }];
        
    }
    
}

- (void) recheckPublicApprovedAccessDueToNewRSVP:(BOOL) newRSVP {
    
    if ((self.isPublicApproved && !self.isCurrentUserAttending && !self.isCurrentUsersEvent) || self.isGuestUser) {
            
        self.transparentTouchView.hidden = YES;
        self.locationOfEvent = [[CLLocation alloc] initWithLatitude:37.749 longitude:-122.4167];
        
        self.entireMapView.address = [NSString stringWithFormat:@"Unknown"];
        self.entireMapView.distanceAway = 0.0f;
        
        [self.rsvpStatusButton endedTask];
        [self.entireMapView finishedLoadingWithLocationAvailable:NO];
        
    } else {
        
        if (newRSVP) {
            self.transparentTouchView.hidden = NO;
            [self setupMapComponent];
        }
        
        [self.rsvpStatusButton endedTask];
        [self.entireMapView finishedLoadingWithLocationAvailable:YES];
        
    }
    
    UITapGestureRecognizer *tapMapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedMap)];
    [self.transparentTouchView addGestureRecognizer:tapMapView];
    
    [self.detailsLoadingView stopAnimating];
    
    [self inviteUsersIconVisibilityCheck];
    
    self.dateOfEventLabel.alpha = 1.0;
    self.timeOfEventLabel.alpha = 1.0;
    self.viewAttending.alpha = 1.0;
    
}


#pragma mark - Helper Methods Other

- (void) inviteUsersIconVisibilityCheck {
    
    if ([self.event.typeOfEvent intValue] == PUBLIC_EVENT_TYPE && self.isCurrentUserAttending && !self.isCurrentUsersEvent) {
        self.inviteUsers.hidden = NO;
    } else {
        self.inviteUsers.hidden = YES;
    }
    
    
}



#pragma mark - Standby Collection View Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.usersOnStandby count];
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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



#pragma mark - User Actions

- (void) flagCurrentEvent {
    
    [self.event flagEventFromVC:self];
    
}

- (void) touchedMap {
    
    FullMapVC *mapViewController = [[FullMapVC alloc] init];
    
    mapViewController.locationPlacemark = self.locationPlacemark;
    mapViewController.locationOfEvent = self.locationOfEvent;
    mapViewController.eventLocationName = self.event.nameOfLocation;
    mapViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
    
}

- (void) viewCreatorProfile {
    
    if (!self.isGuestUser) {
        ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        viewUserProfileVC.userObjectID = self.event.parent.objectId;
        viewUserProfileVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    }
    
}

//TODO:  Must present this similarly to the way an add event modal is presented.
- (void) editEvent {
    
    [PFAnalytics trackEventInBackground:@"EventEditAccessed" block:nil];
    
    AddEventPrimaryVC *editEventVC = (AddEventPrimaryVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventFirstStep"];
    editEventVC.delegate = self;
    editEventVC.eventToEdit = self.event;
    
    [self.navigationController pushViewController:editEventVC animated:YES];
    
}


- (IBAction)inviteFriends:(id)sender {
        
    if (!self.isGuestUser) {
        
        self.shouldRestoreNavBar = NO;
        
        [PFAnalytics trackEventInBackground:@"InviteUsersFromEventPage" block:nil];
        
        PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
        invitePeopleVC.userProfile = [EVNUser currentUser];
        invitePeopleVC.eventForInvites = self.event;
        invitePeopleVC.delegate = self;
        
        UINavigationController *embedInThisVC = [[UINavigationController alloc] initWithRootViewController:invitePeopleVC];
        
        [self presentViewController:embedInThisVC animated:YES completion:nil];
        
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
    
    [PFAnalytics trackEventInBackground:@"ViewEventPhotos" block:nil];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    
    EventPicturesVC *allEventPictures = [[EventPicturesVC alloc] initWithCollectionViewLayout:flowLayout];
    
    allEventPictures.eventObject = self.event;
    allEventPictures.delegate = self;
    allEventPictures.hidesBottomBarWhenPushed = YES;
    
    if (self.isCurrentUsersEvent) {
        
        allEventPictures.allowsAddingPictures = YES;
        allEventPictures.allowsChoosingPictures = YES;
        
    } else {
        
        if (self.isCurrentUserAttending) {
            allEventPictures.allowsAddingPictures = [self.event allowUserToAddPhotosAtThisTime];
        } else {
            allEventPictures.allowsAddingPictures = NO;
        }
        
        allEventPictures.allowsChoosingPictures = NO;
        
    }

    [self.navigationController pushViewController:allEventPictures animated:YES];
    
}

- (void) addNewComment {
    
    if (self.isCurrentUserAttending || self.isCurrentUsersEvent) {
        
        self.shouldRestoreNavBar = NO;
        
        EVNAddCommentVC *newCommentVC = [[EVNAddCommentVC alloc] init];
        newCommentVC.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newCommentVC];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

//Current: User is added to the event as a Relation.  No information about the activity is stored (ie timestamp)
//Update:  User is added to the event as a Relation and an entry in the activity table is created - will be used for Activity/Notifications View.
//Long-Term:  Is this the best solution?

- (IBAction)rsvpToEvent:(id)sender {
    
    int eventType = [self.event.typeOfEvent intValue];
    
    //Cases:  Guest User - PA Event Request Access - Attending Already - Not Attending
    
    if (self.isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
        
    } else if ([self.rsvpStatusButton.titleText isEqualToString:@""]) {
        
        UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"Looks like we're having trouble figuring out if you have already joined this event.  You should send us an angry tweet from the Settings page (top right on your profile page)." delegate:self cancelButtonTitle:@"C'mon" otherButtonTitles:nil];
    
        [issueView show];
        
    } else if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        /*
        
         if it says show interest, then add a requestaccess activity
         if it says interested, then remove a requestaccess activity
         if it says join, then add an attending activity
         if it says attending, then remove an attending activity
         
         if creator lets in, then add a granted activity and an attending activity immmediately after.
        
         NSString *const kAttendingEvent = @"Attending";
         NSString *const kNotAttendingEvent = @"Join";
         NSString *const kRSVPedForEvent = @"Interested";
         NSString *const kNOTRSVPedForEvent = @"Show Interest";
         NSString *const kGrantedAccessToEvent = @"Attending";
         
        */
        
        //Join - RSVP User
        if ([self.rsvpStatusButton.titleText isEqualToString:kNotAttendingEvent]) {
            
            [self.rsvpStatusButton startedTask];

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
                    
                    UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Unable to RSVP" message:@"We're having trouble RSVPing you to this event.  Are you sure you want to go?  Jk... send us an email or a tweet from settings so we can help figure out your issue." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                    
                    [issueView show];
                }
                
                [self.rsvpStatusButton endedTask];
                [self recheckPublicApprovedAccessDueToNewRSVP:YES];

                
            }];

            
        
        //Attending - UNRSVP User
        } else if ([self.rsvpStatusButton.titleText isEqualToString:kAttendingEvent]) {
            
            [self.rsvpStatusButton startedTask];

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
                    
                    UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Unable to UnRSVP" message:@"We're having trouble un-rsvping you from this event.  Are you sure you don't want to go?  Jk... send us an email or a tweet from settings so we can help figure out your issue." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                    
                    [issueView show];
                    
                }
                
                [self.rsvpStatusButton endedTask];
                [self recheckPublicApprovedAccessDueToNewRSVP:YES];

                
            }];
            
          
        //Show Interest - Request Access for User and Add to Standby
        } else if ([self.rsvpStatusButton.titleText isEqualToString:kNOTRSVPedForEvent]) {
            
            [self.rsvpStatusButton startedTask];
            
            [self.event requestAccessForUser:[EVNUser currentUser] completion:^(BOOL success) {
                
                if (success) {
                    
                    self.rsvpStatusButton.titleText = kRSVPedForEvent;
                    self.rsvpStatusButton.isSelected = YES;
                    
                    NSMutableArray *updatedStandbyListWithCurrentUser = [NSMutableArray arrayWithArray:self.usersOnStandby];
                    [updatedStandbyListWithCurrentUser addObject:[EVNUser currentUser]];
                    self.usersOnStandby = [NSArray arrayWithArray:updatedStandbyListWithCurrentUser];
                    [self.standbyUsersCollectionView reloadData];
                
                } else {
                    
                    UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"Looks like we're having trouble requesting access for you.  Send us an angry tweet from the Settings page... that normally fixes things." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                    
                    [issueView show];
                    
                }
                
                [self.rsvpStatusButton endedTask];
                
            }];

        //Interested - Remove Request for Access
        }  else if ([self.rsvpStatusButton.titleText isEqualToString:kRSVPedForEvent]) {
            
        
        
        }
        
    } else if (eventType == PUBLIC_EVENT_TYPE || eventType == PRIVATE_EVENT_TYPE) {
        
        [self.rsvpStatusButton startedTask];
        
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
                   
                    UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Unable to UnRSVP" message:@"We're having trouble un-rsvping you from this event.  Are you sure you don't want to go?  Jk... send us an email or a tweet from settings so we can help figure out your issue." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                    
                    [issueView show];
                    
                }
            
                [self.rsvpStatusButton endedTask];
                
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

                    UIAlertView *issueView = [[UIAlertView alloc] initWithTitle:@"Unable to RSVP" message:@"We're having trouble RSVPing you to this event.  Are you sure you want to go?  Jk... send us an email or a tweet from settings so we can help figure out your issue." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                    
                    [issueView show];
                }
                
                [self.rsvpStatusButton endedTask];
                
            }];
            
        }
        
    }

}


#pragma mark - Delegate Methods for Editing An Event

//update the view with the new event details - not pulling from parse.. they have already been saved up.
- (void) completedEventEditing:(EventObject *)updatedEvent {
    
    self.eventTitle.text = updatedEvent.title;
    self.eventDescriptionTextView.text = updatedEvent.descriptionOfEvent;

    //Update the Event Based on the Event Type - Currently just showing/hiding standby view and requerying for users
    if ([updatedEvent.typeOfEvent intValue] == PUBLIC_APPROVED_EVENT_TYPE) {
        self.standbyUsersCollectionView.hidden = NO;
        self.standbyListTitle.hidden = NO;
        
        [updatedEvent queryForStandbyUsersWithIncludeKey:nil completion:^(NSError *error, NSArray *users) {
            
            if (error || [users count] == 0) {
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

    
    [updatedEvent coverImage:^(UIImage *image) {
        [self setBackgroundOfPictureSectionWithImage:image];
    }];
    
    //Update Map with New Event Location
    [self setupMapComponent];
    
    //Update Date and Time
    self.dateOfEventLabel.text = [self.event eventDateShortStyleAndVisible:YES];
    self.timeOfEventLabel.text = [self.event eventTimeShortStyeAndVisible:YES];
    
    id<EventDetailProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(updateEventCellAfterEdit)]) {
        [strongDelegate updateEventCellAfterEdit];
    }
    
    [self recheckPublicApprovedAccessDueToNewRSVP:NO];
    
    [self.navigationController popViewControllerAnimated:YES];

    
}


- (void) canceledEventEditing {
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Delegate Method for Inviting Users to Event

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.event inviteUsers:selectedPeople completion:^(BOOL success) {

    }];

}


#pragma mark - Event Pictures Protocol

- (void) newPictureAdded {
    
    //NSString *currentPictureCountString = self.numberOfPicturesLabel.text;
    //int newCount = [currentPictureCountString intValue] + 1;
    //self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d", newCount];
    
}

- (void) pictureRemoved {
    
    //NSString *currentPictureCountString = self.numberOfPicturesLabel.text;
    //int newCount = [currentPictureCountString intValue] - 1;
    //self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%d", newCount];
    
}



#pragma mark - Event Comment Protocol

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
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                NSArray *firstIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]];

                [self.commentsController.commentsData insertObject:newComment atIndex:0];
                [self.commentsController.commentsTable insertRowsAtIndexPaths:firstIndexPath withRowAnimation:UITableViewRowAnimationFade];

            }];
            
        } else {
            
            UIAlertView *issueSaving = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"We couldn't save your comment. Try submitting it again." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
            
            [issueSaving show];
        }
        
    }];
    
}


@end
