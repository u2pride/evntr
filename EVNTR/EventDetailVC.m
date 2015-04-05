//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AddEventPrimaryVC.h"
#import "AppDelegate.h"
#import "EVNButton.h"
#import "EVNConstants.h"
#import "EVNParseEventHelper.h"
#import "EVNUtility.h"
#import "EventDetailVC.h"
#import "EventPictureCell.h"
#import "IDTransitioningDelegate.h"
#import "ImageViewPFExtended.h"
#import "FullMapVC.h"
#import "MapForEventView.h"
#import "MBProgressHUD.h"
#import "PeopleVC.h"
#import "PictureFullScreenVC.h"
#import "ProfileVC.h"
#import "StandbyCollectionViewCell.h"
#import "UIColor+EVNColors.h"
#import "UIImageEffects.h"

#import "EventPicturesVC.h"

#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>


@interface EventDetailVC () {
    
    float latitudeSF;
    float longitudeSF;
    int numNetworkCallsComplete;
    
}

@property BOOL isGuestUser;
@property BOOL isCurrentUserAttending;
@property BOOL isPublicApproved;
@property BOOL isCurrentUsersEvent;

//Buttons
@property (weak, nonatomic) IBOutlet UIButton *rsvpButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *viewAttendingButton;

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
@property (nonatomic, strong) UIImage *navBarBackground;
@property (nonatomic, strong) UIImage *navbarShadow;
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
@property (strong, nonatomic) IBOutlet PFImageView *backgroundForPictureSection;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPicturesLabel;
@property (strong, nonatomic) IBOutlet EVNButton *viewPicturesButton;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@property (nonatomic, strong) NSTimer *timerForLocation;

//Only YES if data model changes or viewing for first time.
@property (nonatomic) BOOL needsInfoUpdate;

- (IBAction)inviteFriends:(id)sender;
- (IBAction)rsvpForEvent:(id)sender;
- (IBAction)viewEventAttenders:(id)sender;
- (IBAction)viewEventPictures:(id)sender;

@end


@implementation EventDetailVC


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        latitudeSF = 37.749;
        longitudeSF = -122.4167;
        _isPublicApproved = NO;
        _isCurrentUsersEvent = NO;
        _isCurrentUserAttending = NO;
        _isGuestUser = NO;
        numNetworkCallsComplete = 0;
        _needsInfoUpdate = YES;

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    
    NSLog(@"Event TO SEEEEEE: %@", self.event);
    
    //Determine if Guest User
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    //Transition Delegate, Default Images, and ScrollView
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];

    
    NSLog(@"PARENT OBJECT ID: %@ and CURRENT USER ID: %@", self.event.parent.objectId, [PFUser currentUser].objectId);
    
    //Determine if the Event Creator is the Current User
    if ([self.event.parent.objectId isEqualToString:[PFUser currentUser].objectId]) {
        self.isCurrentUsersEvent = YES;
        NSLog(@"Current User's Event ");
        
        

    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupStaticEventDetailComponents];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Transparent Navigation Bar - Store Current State to Restore
    self.navbarShadow = self.navigationController.navigationBar.shadowImage;
    self.navBarBackground = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    
    if (self.needsInfoUpdate) {

        //Reset Number of Network Call
        numNetworkCallsComplete = 0;
        
        //Create Black Loading Screen
        self.fadeOutBlackScreen = [[UIView alloc] initWithFrame:self.view.frame];
        self.fadeOutBlackScreen.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        [self.view addSubview:self.fadeOutBlackScreen];
        
        //Progress Indicator - Start
        self.HUD = [[MBProgressHUD alloc] init];
        self.HUD.center = self.view.center;
        [self.view addSubview:self.HUD];
        [self.view bringSubviewToFront:self.HUD];
        self.HUD.labelText = @"Event Loading";
        [self.HUD show:YES];
        
    }
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:self.navBarBackground
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = self.navbarShadow;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.timerForLocation invalidate];
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if (self.needsInfoUpdate) {
        
        [self setBackgroundOfPictureSectionWithImage:[UIImage imageNamed:@"EventDefault"]];
        
        ///////////////////////////
        //Configuring Basic Details
        ///////////////////////////
        
        self.eventTitle.text = self.event.title;
        self.dateOfEventLabel.text = [self.event eventDateShortStyle];
        self.timeOfEventLabel.text = [self.event eventTimeShortStye];
        self.eventDescription.text = self.event.descriptionOfEvent;
        
        self.backgroundForPictureSection.file = self.event.coverPhoto;
        self.backgroundForPictureSection.image = [UIImage imageNamed:@"EventDefault"];
        [self.backgroundForPictureSection loadInBackground:^(UIImage *image, NSError *error) {
            
            NSLog(@"Image: %@ and then the property: %@", image, self.backgroundForPictureSection.image);
            
            [self setBackgroundOfPictureSectionWithImage:image];
            NSLog(@"Num 1");
            [self networkCallComplete]; //1
            
        }];
        
        
        [self setupCreatorComponent];
        [self setupMapComponent];
        
        ///////////////////////
        //Find Users on Standby
        ///////////////////////
        
        [EVNParseEventHelper queryForStandbyUsersWithContent:self.event ofType:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY] withIncludeKey:nil completion:^(NSError *error, NSArray *users) {
            
            if (error || users == nil) {
                self.usersOnStandby = nil;
            } else {
                self.usersOnStandby = users;
            }
            
            [self.standbyUsersCollectionView reloadData];
            
            NSLog(@"Num2");
            [self networkCallComplete]; //2
            
        }];
        
        
        ////////////////////////////
        //Configuring Action Buttons
        ////////////////////////////
        
        if (self.isGuestUser) {
            
            [self.rsvpButton setTitle:@"Sign Up To Attend" forState:UIControlStateNormal];
            [self.viewAttendingButton setTitle:@"Sign Up to View Attending Users" forState:UIControlStateNormal];
            [self.inviteButton setTitle:@"Sign Up to Attend" forState:UIControlStateNormal];
            
            int eventType = [self.event.typeOfEvent intValue];
            if (eventType != PUBLIC_APPROVED_EVENT_TYPE) {
                self.standbyUsersCollectionView.hidden = YES;
                self.standbyListTitle.hidden = YES;
            }
            
        } else {
            
            int eventType = [self.event.typeOfEvent intValue];
            NSString *username = [[PFUser currentUser] objectForKey:@"username"];
            
            switch (eventType) {
                case PUBLIC_EVENT_TYPE: {
                    
                    [EVNParseEventHelper queryRSVPForUsername:username atEvent:self.event completion:^(BOOL isAttending, NSString *status) {
                        
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            [self.rsvpButton setTitle:status forState:UIControlStateNormal];
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
                    
                    [EVNParseEventHelper queryRSVPForUsername:username atEvent:self.event completion:^(BOOL isAttending, NSString *status) {
                        
                        if (!self.isCurrentUsersEvent) {
                            self.isCurrentUserAttending = isAttending;
                            [self.rsvpButton setTitle:status forState:UIControlStateNormal];
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
                    
                    //Determine the state of the user with the event
                    // Hasn't requested Accesss - Requested Access - Granted Acccess
                    
                    [EVNParseEventHelper queryApprovalStatusOfUser:[PFUser currentUser] forEvent:self.event completion:^(BOOL isAttending, NSString *status) {
                        
                        if ([status isEqualToString:@"Error"]) {
                            //TODO: Error Handling
                        } else {
                            
                            if (!self.isCurrentUsersEvent) {
                                self.isCurrentUserAttending = isAttending;
                                [self.rsvpButton setTitle:status forState:UIControlStateNormal];
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
    [self.rsvpButton setTitle:kNOTRSVPedForEvent forState:UIControlStateNormal];
    
    NSLog(@"self.isCurrentUsersEvent:%@", [NSNumber numberWithBool:self.isCurrentUsersEvent]);
    
    self.rsvpButton.hidden = (self.isCurrentUsersEvent) ? YES : NO;
    self.inviteButton.hidden = (self.isCurrentUsersEvent) ? NO : YES;

    //Standby Component - UICollectionView
    self.standbyUsersCollectionView.delegate = self;
    self.standbyUsersCollectionView.dataSource = self;
    self.standbyUsersCollectionView.backgroundColor = [UIColor orangeThemeColor];
    self.standbyUsersCollectionView.tag = 2;
    UICollectionViewFlowLayout *collectionViewLayout2 = (UICollectionViewFlowLayout*)self.standbyUsersCollectionView.collectionViewLayout;
    collectionViewLayout2.minimumInteritemSpacing = 20;
    collectionViewLayout2.minimumLineSpacing = 20;
    
    //Map Component - Disable Interaction with Map View and Wire Up Transparent Touch View on Top of Map View
    self.entireMapView.mapView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapMapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedMap)];
    [self.transparentTouchView addGestureRecognizer:tapMapView];
    self.transparentTouchView.backgroundColor = [UIColor clearColor];
    
    //Picture Component
    self.viewPicturesButton.titleText = @"View";
    self.viewPicturesButton.isStateless = YES;
    self.viewPicturesButton.isSelected = NO;
    self.viewPicturesButton.buttonColorOpposing = [UIColor clearColor];
    self.numberOfPicturesLabel.text = [self.event numberOfPhotos];

    //Tap Gesture for Event Creator Photo
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
    self.creatorPhoto.userInteractionEnabled = YES;
    [self.creatorPhoto addGestureRecognizer:tapgr];
    
    if (!self.isGuestUser) {
        
        //Add Edit Button if Creator is Current User
        if (self.isCurrentUsersEvent) {
            UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"editEvent"] style:UIBarButtonItemStylePlain target:self action:@selector(editEvent)];
            self.navigationItem.rightBarButtonItem = editButton;
        }
        
    }
    

    
}


- (void) setupMapComponent {
    
    self.locationOfEvent = [[CLLocation alloc] initWithLatitude:self.event.locationOfEvent.latitude longitude:self.event.locationOfEvent.longitude];
    
    //Getting Current Location and Comparing to Event Location
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = [[appDelegate locationManager] location];
    
    NSLog(@"self.LocationOFevent: %@ and CurrentLocation: %@", self.locationOfEvent, currentLocation);
    
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
    
    NSLog(@"%@", [self.event.parent class]);
    
    [self.event.parent fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
        
        self.creatorName.textColor = [UIColor orangeThemeColor];
        self.creatorName.text = user[@"username"];
        self.creatorName.userInteractionEnabled = YES;
        [self.creatorName addGestureRecognizer:tapgr2];
        
        self.creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [self.creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
            
            NSLog(@"Determine if Masking Should Be Done in Background: Before Masking:");
            self.creatorPhoto.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
            NSLog(@"AndAftermasking:");
            
            NSLog(@"Num6");
            [self networkCallComplete]; //6
            
        }];
        
        NSLog(@"Num7");
        [self networkCallComplete]; //7
        
    }];
    
}


- (void) setBackgroundOfPictureSectionWithImage:(UIImage *)image {
    //Set Background to Blurred Cover Photo Image
    UIImage *darkBlurredImageForPicturesBackground = [UIImageEffects imageByApplyingBlurToImage:image withRadius:10.0 tintColor:[UIColor colorWithWhite:0.11 alpha:0.8] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.backgroundForPictureSection.image = darkBlurredImageForPicturesBackground;
    
    
    UIImage *blurredBackgroundImage = [UIImageEffects imageByApplyingBlurToImage:image withRadius:30.0 tintColor:[UIColor colorWithWhite:0.08 alpha:0.8] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:blurredBackgroundImage];
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
    
    NSLog(@"%@ and %@", [NSNumber numberWithBool:self.isPublicApproved], [NSNumber numberWithBool:self.isCurrentUserAttending]);
    
    if (self.isPublicApproved && !self.isCurrentUserAttending && !self.isCurrentUsersEvent) {
        self.transparentTouchView.hidden = YES;
        self.locationOfEvent = [[CLLocation alloc] initWithLatitude:latitudeSF longitude:longitudeSF];
        
        //Randomize the Map View and Have It Constantly Scroll
        [self randomLocation];
        self.timerForLocation = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(randomLocation) userInfo:nil repeats:YES];
        
        self.entireMapView.address = [NSString stringWithFormat:@"Unknown"];
        self.entireMapView.distanceAway = 0.0f;
        self.dateOfEventLabel.text = @"Unknown";
        self.timeOfEventLabel.text = @"Unknown";

    }

}




#pragma mark - Touched Map Event

- (void) touchedMap {
    
    FullMapVC *mapViewController = [[FullMapVC alloc] init];

    mapViewController.locationPlacemark = self.locationPlacemark;
    mapViewController.locationOfEvent = self.locationOfEvent;
    mapViewController.hidesBottomBarWhenPushed = YES;
    
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
        
        PFUser *currentUser = [self.usersOnStandby objectAtIndex:indexPath.row];
        
        cell.profilePictureOfStandbyUser.image = [UIImage imageNamed:@"PersonDefault"];
        cell.profilePictureOfStandbyUser.file = currentUser[@"profilePicture"];
        [cell.profilePictureOfStandbyUser loadInBackground];
        
        
        cell.profilePictureOfStandbyUser.objectForImageView = currentUser;
        
        return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isGuestUser) {
        
        PFUser *selectedUser = [self.usersOnStandby objectAtIndex:indexPath.row];
        
        ProfileVC *profileView = (ProfileVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileView.userNameForProfileView = selectedUser[@"username"];
        
        [self.navigationController pushViewController:profileView animated:YES];
        
    }
    
}





#pragma mark - Actions Performed By User

- (void) viewCreatorProfile {
    
    if (!self.isGuestUser) {
        ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        //TODO: change this from not using uilabel
        viewUserProfileVC.userNameForProfileView = self.creatorName.text;
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
        PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
        invitePeopleVC.profileUsername = [PFUser currentUser];
        invitePeopleVC.delegate = self;
        
        [self.navigationController pushViewController:invitePeopleVC animated:YES];
    }
}

//Current: User is added to the event as a Relation.  No information about the activity is stored (ie timestamp)
//Update:  User is added to the event as a Relation and an entry in the activity table is created - will be used for Activity/Notifications View.
//Long-Term:  Is this the best solution?

- (IBAction)rsvpForEvent:(id)sender {
    
    int eventType = [self.event.typeOfEvent intValue];
    
    //Cases:  Guest User - PA Event Request Access - Attending Already - Not Attending
    
    if (self.isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
    
    } else if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        //Currently only allowing A Request for access not to revoke
        if ([self.rsvpButton.titleLabel.text isEqualToString:kNOTRSVPedForEvent]) {
            
            self.rsvpButton.enabled = NO;
            
            [EVNParseEventHelper requestAccessForUser:[PFUser currentUser] forEvent:self.event completion:^(BOOL success) {
               
                if (success) {
                    [self.rsvpButton setTitle:kRSVPedForEvent forState:UIControlStateNormal];
                }
                self.rsvpButton.enabled = YES;
            }];
        }
        
        
    } else if (eventType == PUBLIC_EVENT_TYPE || eventType == PRIVATE_EVENT_TYPE) {
        
        PFRelation *attendersRelation = self.event.attenders;
        self.rsvpButton.enabled = NO;
        
        if ([self.rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            [attendersRelation removeObject:[PFUser currentUser]];
            [self.event saveInBackground];
            
            //[self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
            
        } else {
            
            //Create New Relation and Add User to List of Attenders for Event
            [attendersRelation addObject:[PFUser currentUser]];
            [self.event saveInBackground];
            
            //[self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
        }
        
        
        //First Part is Adding Relation - This is Attending to Activity Table (choose one?)
        if ([self.rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            [EVNParseEventHelper unRSVPUser:[PFUser currentUser] forEvent:self.event completion:^(BOOL success) {
               
                if (success) {
                    self.isCurrentUserAttending = NO;
                    [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                } else {
                    //TODO: PFAnalytics
                }
                
                //Re-Enable RSVP Button
                self.rsvpButton.enabled = YES;
            }];
            
        } else {

            [EVNParseEventHelper rsvpUser:[PFUser currentUser] forEvent:self.event completion:^(BOOL success) {
               
                if (success) {
                    self.isCurrentUserAttending = YES;
                    [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                } else {
                    //TODO: Log Error with PFAnalytics
                }
                
                //Re-Enable Button
                self.rsvpButton.enabled = YES;
                
            }];
            
        }
        
    }
    
}


- (IBAction)viewEventAttenders:(id)sender {
    
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


#pragma mark - Delegate Methods for Editing An Event

/*
- (NSDictionary *) eventDetailsToEdit {
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.event.typeOfEvent, @"type", self.event.title, @"title", self.backgroundForPictureSection.image, @"image", self.backgroundForPictureSection.file, @"file", self.event.description, @"description", self.event.locationOfEvent, @"coordinates", self.event.nameOfLocation, @"locationName", self.event.dateOfEvent, @"date", self.event, @"object", nil];
    
    return dictionary;
}
*/


- (void) completedEventEditing:(EventObject *)updatedEvent {
    NSLog(@"Back to Event Details - completed event editing");
    
    //create an event PFObject subclass.
    //pass that when you edit an event.
    //use a notification when the editing is complete - actually maybe just use protocols and pass the event.
    
    
    //update the view with the new event details - not pulling from parse
    self.eventTitle.text = updatedEvent.title;
    //include event type updating
    
    [updatedEvent coverImage:^(UIImage *image) {
        
        [self setBackgroundOfPictureSectionWithImage:image];
    }];
    
    
    self.eventDescription.text = updatedEvent.descriptionOfEvent;
    //self.entireMapView.eventLocation = updatedEvent.eventLocationName;
    self.entireMapView.address = @"";
    //self.eventDate = updatedEvent.date;
    
    
    //[self configureWithEvent:event];
    

    [self.navigationController popViewControllerAnimated:NO];

    
}


- (void) canceledEventEditing {
    NSLog(@"Back to Event Details - canceled event editing");
    
    [self.navigationController popViewControllerAnimated:NO];

}

#pragma mark - Delegate Method for Inviting Users to Event

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [EVNParseEventHelper inviteUsers:selectedPeople toEvent:self.event completion:^(BOOL success) {
        //empty
    }];

}


- (void) randomLocation {
    
    latitudeSF = latitudeSF + 0;
    longitudeSF = longitudeSF + 1;
    
    if (longitudeSF > -84) {
        longitudeSF = -122;
    }
    
    NSLog(@"Lat: %f and Long: %f", latitudeSF, longitudeSF);
    
    CLLocation *randomLocation = [[CLLocation alloc] initWithLatitude:latitudeSF longitude:longitudeSF];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(randomLocation.coordinate, MKCoordinateSpanMake(10, 10));
    
    [self.entireMapView.mapView setRegion:region animated:YES];
    
}


/*
 NSDate *dateFromParse = self.event.eventDate;
 
 NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
 dateForm.doesRelativeDateFormatting = YES;
 dateForm.locale = [NSLocale currentLocale];
 dateForm.dateStyle = NSDateFormatterMediumStyle;
 dateForm.timeStyle = NSDateFormatterNoStyle;
 NSString *localDateString = [dateForm stringFromDate:dateFromParse];
 
 dateForm.dateStyle = NSDateFormatterNoStyle;
 dateForm.timeStyle = NSDateFormatterShortStyle;
 NSString *localTimeString = [dateForm stringFromDate:dateFromParse];
 */

/*
 [UIView animateWithDuration:0.2 animations:^{
 self.navigationController.navigationBar.alpha = 0;
 } completion:^(BOOL finished) {
 [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
 forBarMetrics:UIBarMetricsDefault];
 self.navigationController.navigationBar.shadowImage = [UIImage new];
 self.navigationController.navigationBar.translucent = YES;
 
 [UIView animateWithDuration:0.5 animations:^{
 
 self.navigationController.navigationBar.alpha = 1;
 
 } completion:^(BOOL finished) {
 
 }];
 }];
 */

//float bigNumber = 85;
//float smallNumber = -85;

//float diff = bigNumber - smallNumber;
//float latitude = (((float) rand() / RAND_MAX) * diff) + smallNumber;

//float longitude = (((float) rand() / RAND_MAX) * diff) + smallNumber;


-(void)dealloc
{
    NSLog(@"eventdetailsvc is being deallocated");
}

@end
