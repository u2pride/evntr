//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EVNButton.h"
#import "EVNConstants.h"
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
    
}

@property BOOL isGuestUser;
@property BOOL isCurrentUserAttending;
@property BOOL isPublicApproved;
@property (nonatomic, strong) PFUser *eventUser;

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

//Images
@property (weak, nonatomic) PFImageView *eventCoverPhoto;
@property (weak, nonatomic) IBOutlet PFImageView *creatorPhoto;

//CollectionViews & DataSources
@property (strong, nonatomic) IBOutlet UICollectionView *standbyUsersCollectionView;
@property (nonatomic, strong) NSMutableArray *usersOnStandby;

//UI & Transitions
@property (nonatomic, strong) UIImage *navBarBackground;
@property (nonatomic, strong) UIImage *navbarShadow;
@property (nonatomic, strong) UIVisualEffectView *blurEffectForModals;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

//Loading Helpers
@property (nonatomic) int numNetworkCallsComplete;
@property (nonatomic, strong) MBProgressHUD *HUD;

//Mapping Location Component
@property (strong, nonatomic) IBOutlet MapForEventView *entireMapView;
@property (strong, nonatomic) IBOutlet UIView *transparentTouchView;
@property (strong, nonatomic) CLLocation *locationOfEvent;
@property (strong, nonatomic) CLPlacemark *locationPlacemark;


//Picture Component
@property (strong, nonatomic) IBOutlet UIImageView *backgroundForPictureSection;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPicturesLabel;
@property (strong, nonatomic) IBOutlet EVNButton *viewPicturesButton;




@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

- (IBAction)inviteFriends:(id)sender;
- (IBAction)rsvpForEvent:(id)sender;
- (IBAction)viewEventAttenders:(id)sender;
- (IBAction)viewEventPictures:(id)sender;

@end


@implementation EventDetailVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    latitudeSF = 37.749;
    longitudeSF = -122.4167;
    self.isPublicApproved = NO;
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    //Configuring UIScrollView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //UICollectionView
    self.standbyUsersCollectionView.delegate = self;
    self.standbyUsersCollectionView.dataSource = self;
    self.standbyUsersCollectionView.backgroundColor = [UIColor orangeThemeColor];
    self.standbyUsersCollectionView.tag = 2;
    UICollectionViewFlowLayout *collectionViewLayout2 = (UICollectionViewFlowLayout*)self.standbyUsersCollectionView.collectionViewLayout;
    collectionViewLayout2.minimumInteritemSpacing = 20;
    collectionViewLayout2.minimumLineSpacing = 20;
    
    
    //Disable Interaction with Map View
    UITapGestureRecognizer *tapMapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedMap)];
    [self.transparentTouchView addGestureRecognizer:tapMapView];
    self.transparentTouchView.backgroundColor = [UIColor clearColor];
    
    //Get isGuest Object
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    self.isCurrentUserAttending = NO;
    
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];
    self.creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    self.title = @""; //self.eventObject[@"title"];
    
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
    self.creatorPhoto.userInteractionEnabled = YES;
    [self.creatorPhoto addGestureRecognizer:tapgr];
    
    
    //Map Component
    self.entireMapView.mapView.userInteractionEnabled = NO;
    
    //Picture Component
    self.viewPicturesButton.titleText = @"View";
    self.viewPicturesButton.isStateless = YES;
    self.viewPicturesButton.isSelected = NO;
    self.viewPicturesButton.buttonColorOpposing = [UIColor clearColor];
    
    self.numberOfPicturesLabel.textColor = [UIColor whiteColor];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.numNetworkCallsComplete = 0;

    
    //Transparent Navigation Bar
    self.navbarShadow = self.navigationController.navigationBar.shadowImage;
    self.navBarBackground = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    
    //Animate Navigation Bar
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
    
    self.HUD = [[MBProgressHUD alloc] init];
    self.HUD.center = self.view.center;
    [self.view addSubview:self.HUD];
    [self.view bringSubviewToFront:self.HUD];
    self.HUD.labelText = @"Event Details Loading";
    [self.HUD show:YES];
    
    
    NSMutableArray *pictureCount = [NSMutableArray arrayWithArray:self.eventObject[@"eventImages"]];
    self.numberOfPicturesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)pictureCount.count];
    
    
    
    
    [self setBackgroundOfPictureSectionWithImage:[UIImage imageNamed:@"EventDefault"]];
    
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    
    ///////////////////////
    //Find Users on Standby
    ///////////////////////
    
    PFQuery *queryForStandbyUsers = [PFQuery queryWithClassName:@"Activities"];
    [queryForStandbyUsers whereKey:@"activityContent" equalTo:self.eventObject];
    [queryForStandbyUsers whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
    [queryForStandbyUsers includeKey:@"from"];
    [queryForStandbyUsers findObjectsInBackgroundWithBlock:^(NSArray *standbyActivities, NSError *error) {
        
        if (!self.usersOnStandby) {
            self.usersOnStandby = [[NSMutableArray alloc] init];
        }
        
        for (PFObject *activity in standbyActivities) {
            
            PFUser *userOnStandby = activity[@"from"];
            [self.usersOnStandby addObject:userOnStandby];
            
        }
        
        [self.standbyUsersCollectionView reloadData];
        
        [self networkCallComplete]; //1
        
    }];
    
    
    
    ////////////////////////////
    //Configuring Action Buttons
    ////////////////////////////
    
    [self.inviteButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    
    if (self.isGuestUser) {
        
        [self.rsvpButton setTitle:@"Sign Up To Attend" forState:UIControlStateNormal];
        [self.viewAttendingButton setTitle:@"Sign Up to View People Going" forState:UIControlStateNormal];
        
    } else {
        
        //Update Event Detail view based on Event Type
        int eventType = [[self.eventObject objectForKey:@"typeOfEvent"] intValue];
        switch (eventType) {
            case PUBLIC_EVENT_TYPE: {
                NSString *username = [[PFUser currentUser] objectForKey:@"username"];
                
                PFRelation *eventAttendersRelation = [self.eventObject relationForKey:@"attenders"];
                PFQuery *attendingQuery = [eventAttendersRelation query];
                [attendingQuery whereKey:@"username" equalTo:username];
                [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (object) {
                        [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                        self.isCurrentUserAttending = YES;
                    } else {
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                    }
                    
                    [self networkCallComplete]; //2

                }];
                
                //Hide Collection View for Standby Users
                self.standbyUsersCollectionView.hidden = YES;
                
                break;
            }
            case PRIVATE_EVENT_TYPE: {
                
                NSString *username = [[PFUser currentUser] objectForKey:@"username"];
                
                PFRelation *eventAttendersRelation = [self.eventObject relationForKey:@"attenders"];
                PFQuery *attendingQuery = [eventAttendersRelation query];
                [attendingQuery whereKey:@"username" equalTo:username];
                [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"Result of Query: %@", object);
                    if (object) {
                        [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                        self.isCurrentUserAttending = YES;
                    } else {
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                    }
                    
                    [self networkCallComplete]; //2

                }];
                
                //Hide Collection View for Standby Users
                self.standbyUsersCollectionView.hidden = YES;

                
                break;
            }
            case PUBLIC_APPROVED_EVENT_TYPE: {
                
                self.isPublicApproved = YES;
                
                //Determine the state of the user with the event
                // Hasn't requested Accesss - Requested Access - Granted Acccess
                
                //User has not requested Access to Event
                [self.rsvpButton setTitle:kNOTRSVPedForEvent forState:UIControlStateNormal];
                
                PFQuery *requestedAccessQuery = [PFQuery queryWithClassName:@"Activities"];
                [requestedAccessQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
                [requestedAccessQuery whereKey:@"from" equalTo:[PFUser currentUser]];
                [requestedAccessQuery whereKey:@"activityContent" equalTo:self.eventObject];
                [requestedAccessQuery findObjectsInBackgroundWithBlock:^(NSArray *requestedActivityObjects, NSError *error) {
                    
                    if (requestedActivityObjects.count > 0) {
                        
                        //User has requested Access to Event
                        [self.rsvpButton setTitle:kRSVPedForEvent forState:UIControlStateNormal];
                        
                        //Now Query For Access Granted
                        PFQuery *accessGrantedQuery = [PFQuery queryWithClassName:@"Activities"];
                        [accessGrantedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
                        [accessGrantedQuery whereKey:@"to" equalTo:[PFUser currentUser]];
                        [accessGrantedQuery whereKey:@"activityContent" equalTo:self.eventObject];
                        [accessGrantedQuery findObjectsInBackgroundWithBlock:^(NSArray *accessActivityObjects, NSError *error) {
                            
                            if (accessActivityObjects.count > 0) {
                                
                                //User has Access to Event
                                [self.rsvpButton setTitle:kGrantedAccessToEvent forState:UIControlStateNormal];
                                self.isCurrentUserAttending = YES;
                                
                            }
                            

                            
                        }];
                    }
                    
                    [self networkCallComplete];

                    
                }];
                
                break;
            }
            default: {
                break;
            }
        }
    }
    
    
    //////////////////
    //Configuring Date
    //////////////////
    
    NSDate *dateFromParse = (NSDate *)self.eventObject[@"dateOfEvent"];
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.doesRelativeDateFormatting = YES;
    dateForm.locale = [NSLocale currentLocale];
    dateForm.dateStyle = NSDateFormatterMediumStyle;
    dateForm.timeStyle = NSDateFormatterNoStyle;
    NSString *localDateString = [dateForm stringFromDate:dateFromParse];
    
    dateForm.dateStyle = NSDateFormatterNoStyle;
    dateForm.timeStyle = NSDateFormatterShortStyle;
    NSString *localTimeString = [dateForm stringFromDate:dateFromParse];
    
    
    //////////////////////
    //Configuring Location
    //////////////////////


    
    //Location Address
    PFGeoPoint *locationOfEventPF = self.eventObject[@"locationOfEvent"];
    
    

    self.locationOfEvent = [[CLLocation alloc] initWithLatitude:locationOfEventPF.latitude longitude:locationOfEventPF.longitude];
    self.entireMapView.eventLocation = self.locationOfEvent;
    
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationOfEvent completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (!error && placemarks.count > 0) {
            
            self.locationPlacemark = [placemarks firstObject];
            
            self.entireMapView.address = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(self.locationPlacemark.addressDictionary, NO)];
            
            
        } else {
            
            self.entireMapView.address = [NSString stringWithFormat:@"%.2f - %.2f", locationOfEventPF.latitude, locationOfEventPF.longitude];
            
        }
        
        [self networkCallComplete]; //3
    
    }];
    
    //Location Name
    NSString *locationName = self.eventObject[@"nameOfLocation"];
        
    if (!locationName) {
        locationName = @"Custom Location";
    } else if ([locationName isEqualToString:@"Current Location"]) {
        locationName = [NSString stringWithFormat:@"%.2f - %.2f", locationOfEventPF.latitude, locationOfEventPF.longitude];
        
    }
    
    
    //MKMapView
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CLLocation *currentLocation = [[appDelegate locationManager] location];
    CLLocationDirection distance = [self.locationOfEvent distanceFromLocation:currentLocation];
    

    self.entireMapView.distanceAway = (float) distance * 0.000621371;
    
    
    
    ////////////////////////////
    //Configuring User Interface
    ////////////////////////////
    
    self.eventTitle.text = self.eventObject[@"title"];
    

    self.dateOfEventLabel.text = localDateString;
    self.timeOfEventLabel.text = localTimeString;
    
    self.eventDescription.text = self.eventObject[@"description"];
    self.eventCoverPhoto.file = (PFFile *)self.eventObject[@"coverPhoto"];
    self.eventCoverPhoto.image = [UIImage imageNamed:@"EventDefault"];
    [self.eventCoverPhoto loadInBackground:^(UIImage *image, NSError *error) {
        
        [self setBackgroundOfPictureSectionWithImage:image];
        [self networkCallComplete]; //4
        
    }];
    
    self.eventUser = (PFUser *)self.eventObject[@"parent"];
    [self.eventUser fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.rsvpButton.hidden = YES;
            self.inviteButton.hidden = NO;
        } else  {
            self.rsvpButton.hidden = NO;
            self.inviteButton.hidden = YES;
            
        }
        
        UITapGestureRecognizer *tapgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCreatorProfile)];
        
        self.creatorName.textColor = [UIColor orangeThemeColor];
        self.creatorName.text = user[@"username"];
        self.creatorName.userInteractionEnabled = YES;
        [self.creatorName addGestureRecognizer:tapgr2];
        
        self.creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [self.creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
            
            self.creatorPhoto.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
            [self networkCallComplete]; //5

        }];
        
        [self networkCallComplete]; //6
        
    }];
    
    
    ////////////////////////////
    //Additional UI Enhancements
    ////////////////////////////
    
    //self.eventDescription.layer.borderWidth = 1.0f;
    //self.eventDescription.layer.borderColor = [UIColor orangeThemeColor].CGColor;
    
    
    
}


- (void) recheckPublicApprovedAccess {
    
    NSLog(@"%@ and %@", [NSNumber numberWithBool:self.isPublicApproved], [NSNumber numberWithBool:self.isCurrentUserAttending]);
    
    if (self.isPublicApproved && !self.isCurrentUserAttending) {
        self.transparentTouchView.hidden = YES;
        self.locationOfEvent = [[CLLocation alloc] initWithLatitude:latitudeSF longitude:longitudeSF];
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(randomLocation) userInfo:nil repeats:YES];
        
        self.entireMapView.address = [NSString stringWithFormat:@"Unknown"];
        self.entireMapView.distanceAway = 0.0f;
        self.dateOfEventLabel.text = @"Unknown";
        self.timeOfEventLabel.text = @"Unknown";

    }
    
    
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //self.scrollViewTopConstraint.constant -= 1.0f;
    //NSLog(@"ScrollView frame: %@ and bounds: %@", NSStringFromCGRect(scrollView.frame), NSStringFromCGRect(scrollView.bounds));
    
}

- (void) networkCallComplete {
    
    NSLog(@"NumNetworkCallsComplete: %d", self.numNetworkCallsComplete);
    self.numNetworkCallsComplete = self.numNetworkCallsComplete + 1;
    
    if (self.numNetworkCallsComplete == 5) {
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recheckPublicApprovedAccess) userInfo:nil repeats:NO];
                
        [self.HUD hide:YES afterDelay:0.5];
    }
    
}


- (void) viewCreatorProfile {
    
    ProfileVC *viewUserProfileVC = (ProfileVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    //TODO: change this from not using uilabel
    viewUserProfileVC.userNameForProfileView = self.creatorName.text;
    viewUserProfileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewUserProfileVC animated:YES];
    
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar setBackgroundImage:self.navBarBackground
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = self.navbarShadow;
    self.navigationController.navigationBar.translucent = YES;
    
}


- (void) setBackgroundOfPictureSectionWithImage:(UIImage *)image {
    //Set Background to Blurred Cover Photo Image
    UIImage *blurredCoverPhotoForBackground = [UIImageEffects imageByApplyingDarkEffectToImage:image];
    
    self.backgroundForPictureSection.image = blurredCoverPhotoForBackground;
    self.view.backgroundColor = [UIColor colorWithPatternImage:blurredCoverPhotoForBackground];
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
    
    //Picture Collection View
    if (collectionView.tag == 1 && self.isCurrentUserAttending) {
        
        NSLog(@"CHECK ONE");

        return 2;
        
    //Standby List TableView or Not Attending
    } else {
        
        return 1;
        
    }
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    

    return [self.usersOnStandby count];

    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
        
    //Standby List Collection View
        
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
    

        
    //Standby List Collection View
        
        PFUser *selectedUser = [self.usersOnStandby objectAtIndex:indexPath.row];
        
        ProfileVC *profileView = (ProfileVC *) [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        profileView.userNameForProfileView = selectedUser[@"username"];
        
        [self.navigationController pushViewController:profileView animated:YES];
    
    
}


- (void) animateBackgroundDarkBlur {
    
    if (!self.blurEffectForModals) {
        
        UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectForModals = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
        self.blurEffectForModals.alpha = 0;
        self.blurEffectForModals.frame = self.view.bounds;
        [self.view addSubview:self.blurEffectForModals];
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:self.view.bounds];
        
        [[self.blurEffectForModals contentView] addSubview:vibrancyEffectView];
        
    }
    
    self.blurEffectForModals.alpha = 0;
    self.blurEffectForModals.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.blurEffectForModals.alpha = 0.9;
    } completion:^(BOOL finished) {
        
    }];
    
    
}


- (void)returnToEvent {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.blurEffectForModals.alpha = 0;
        self.navigationController.navigationBar.alpha = 1;
        self.tabBarController.tabBar.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        self.blurEffectForModals.hidden = YES;
        
    }];

}




#pragma mark - Profile Actions

- (IBAction)inviteFriends:(id)sender {
    
    PeopleVC *invitePeopleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
    invitePeopleVC.typeOfUsers = VIEW_FOLLOWING_TO_INVITE;
    invitePeopleVC.profileUsername = [PFUser currentUser];
    invitePeopleVC.delegate = self;
    
    [self.navigationController pushViewController:invitePeopleVC animated:YES];
    
}

//Current: User is added to the event as a Relation.  No information about the activity is stored (ie timestamp)
//Update:  User is added to the event as a Relation and an entry in the activity table is created - will be used for Activity/Notifications View.
//Long-Term:  Is this the best solution?

- (IBAction)rsvpForEvent:(id)sender {
    
    int eventType = [[self.eventObject objectForKey:@"typeOfEvent"] intValue];
    
    if (self.isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
    
    } else if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        //Currently only allowing an RSVP - not to cancel an RSVP
        if ([self.rsvpButton.titleLabel.text isEqualToString:kNOTRSVPedForEvent]) {
            
            self.rsvpButton.enabled = NO;
            
            //RSVP User for Event
            PFObject *rsvpActivity = [PFObject objectWithClassName:@"Activities"];
            rsvpActivity[@"from"] = [PFUser currentUser];
            rsvpActivity[@"to"] = self.eventUser;
            rsvpActivity[@"type"] = [NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY];
            rsvpActivity[@"activityContent"] = self.eventObject;
            
            [rsvpActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    [self.rsvpButton setTitle:kRSVPedForEvent forState:UIControlStateNormal];
                }
                self.rsvpButton.enabled = YES;
                
            }];
        }
        
        
    } else if (eventType == PUBLIC_EVENT_TYPE || eventType == PRIVATE_EVENT_TYPE) {
        
        //ADDING USER VIA A RELATION
        PFRelation *attendersRelation = [self.eventObject relationForKey:@"attenders"];
        NSLog(@"PFRelation: %@", attendersRelation);
        
        if ([self.rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            NSLog(@"Removing PFRelation");
            
            [attendersRelation removeObject:[PFUser currentUser]];
            [self.eventObject saveInBackground];
            
            //[self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
            
        } else {
            
            NSLog(@"Adding PFRelation");
            
            //Create New Relation and Add User to List of Attenders for Event
            [attendersRelation addObject:[PFUser currentUser]];
            [self.eventObject saveInBackground];
            
            //[self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
        }
        
        
        
        
        //CREATING AN ENTRY IN THE ACTIVITY TABLE - Similar to Above
        if ([self.rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            NSLog(@"Deleting an Entry in the Activity Table");
            
            //Disable the rsvp button
            self.rsvpButton.enabled = NO;
            
            //Query for the Previous Entry
            PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
            [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForRSVP whereKey:@"to" equalTo:[PFUser currentUser]];
            [queryForRSVP whereKey:@"activityContent" equalTo:self.eventObject];
            [queryForRSVP findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFObject *previousActivity = [objects firstObject];
                [previousActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                        self.isCurrentUserAttending = NO;
                        
                    } else {
                        NSLog(@"Failed to Delete Previous Activity");
                    }
                    
                    //re-enable the RSVP button
                    self.rsvpButton.enabled = YES;
                    
                    
                }];
                
            }];
            
            
        } else {
            
            //Disable Button
            self.rsvpButton.enabled = NO;
            
            PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
            newAttendingActivity[@"to"] = [PFUser currentUser];
            newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
            newAttendingActivity[@"activityContent"] = self.eventObject;
            [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    //if succeeded, change the title to reflect the RSVP event
                    [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                    self.isCurrentUserAttending = YES;
                    
                } else {
                    
                    //if failed, alert the user.
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"RSVP" message:@"Unable to RSVP at this time. Try later." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                    
                    [errorAlert show];
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
        viewAttendees.eventToViewAttenders = self.eventObject;
        
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
    allEventPictures.eventObject = self.eventObject;
    
    //TODO: Add Logic Here about Who Is Allowed to Add Photos
    allEventPictures.allowsAddingPictures = self.isCurrentUserAttending;
    
    [self.navigationController pushViewController:allEventPictures animated:YES];
    
    
}



#pragma mark - Delegate Method for Inviting Users to Event

- (void)finishedSelectingInvitations:(NSArray *)selectedPeople {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    for (PFUser *user in selectedPeople) {
        
        //If Private Event - Also Add Invited People to invitedUsers column as a PFRelation - actually maybe not
        //if (publicPrivateSwitch.on) {
        //[invitedRelation addObject:user];
        //}
        
        PFObject *newInvitationActivity = [PFObject objectWithClassName:@"Activities"];
        
        newInvitationActivity[@"type"] = [NSNumber numberWithInt:INVITE_ACTIVITY];
        newInvitationActivity[@"from"] = [PFUser currentUser];
        newInvitationActivity[@"to"] = user;
        newInvitationActivity[@"activityContent"] = self.eventObject;
        
        //save the invitation activities
        [newInvitationActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                NSLog(@"Saved");
            } else {
                NSLog(@"Error in Saved");
            }
        }];
    }
    
    
}


- (void) randomLocation {
    
    //float bigNumber = 85;
    //float smallNumber = -85;

    //float diff = bigNumber - smallNumber;
    //float latitude = (((float) rand() / RAND_MAX) * diff) + smallNumber;
    
    //float longitude = (((float) rand() / RAND_MAX) * diff) + smallNumber;
    
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





@end
