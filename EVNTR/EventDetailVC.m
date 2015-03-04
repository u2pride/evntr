//
//  EventDetailVC.m
//  EVNTR
//
//  Created by Alex Ryan on 1/28/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventDetailVC.h"
#import <Parse/Parse.h>
#import "EVNConstants.h"
#import "PeopleVC.h"
#import "EVNUtility.h"
#import "UIImageEffects.h"
#import "UIColor+EVNColors.h"
#import "EventPictureCell.h"
#import "PictureFullScreenVC.h"
#import "IDTransitioningDelegate.h"

@interface EventDetailVC () {
    NSMutableArray *picturesFromEvent;
}

@property (nonatomic, strong) PFUser *eventUser;
@property (weak, nonatomic) IBOutlet UIButton *rsvpButton;
@property (weak, nonatomic) IBOutlet UIButton *viewAttendingButton;
@property (weak, nonatomic) IBOutlet UICollectionView *pictureCollectionView;

@property (nonatomic, strong) UIImage *navBarBackground;
@property (nonatomic, strong) UIImage *navbarShadow;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoFromEvent;
@property (nonatomic, strong) UIVisualEffectView *blurEffectForModals;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

@property BOOL isGuestUser;

- (IBAction)rsvpForEvent:(id)sender;
- (IBAction)viewEventAttenders:(id)sender;
- (IBAction)uploadPhotoFromEvent:(id)sender;

@end

@implementation EventDetailVC

@synthesize eventTitle, eventCoverPhoto, creatorName, creatorPhoto, eventDescription, eventObject, eventUser, dateOfEventLabel, loadingSpinner, eventLocationLabel, rsvpButton, isGuestUser, viewAttendingButton, navBarBackground, navbarShadow, pictureCollectionView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];
    
    //UICollectionView
    self.pictureCollectionView.delegate = self;
    self.pictureCollectionView.dataSource = self;
    self.pictureCollectionView.backgroundColor = [UIColor whiteColor];
    picturesFromEvent = [[NSMutableArray alloc] init];
    
    [self startSearchForEventPhotos];
    
    //self.navigationBarOriginal = [[UINavigationBar alloc] init];
    
    //Get isGuest Object
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    self.isGuestUser = [standardDefaults boolForKey:kIsGuest];
    
    NSLog(@"VIEWDIDLOAD OF EVENTDETAIL: %@", [NSNumber numberWithBool:self.isGuestUser]);
    
    //Remove text for back button used in navigation
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    self.loadingSpinner.center = self.view.center;
    [self.view addSubview:self.loadingSpinner];
    [self.loadingSpinner startAnimating];
    
    //[self startLoadingAnimationAndBlur];
    

    
    // Do any additional setup after loading the view.
    creatorPhoto.image = [UIImage imageNamed:@"PersonDefault"];
    eventCoverPhoto.image = [UIImage imageNamed:@"EventDefault"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
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
    
 


    //TODO: move network tasks to viewDidAppear and add activity indicator
    self.title = eventObject[@"title"];
    
    if (isGuestUser) {
        
        [self.rsvpButton setTitle:@"Sign Up To Attend" forState:UIControlStateNormal];
        [self.viewAttendingButton setTitle:@"Sign Up to View People Going" forState:UIControlStateNormal];
        
    } else {
        
        //Update Event Detail view based on Event Type
        int eventType = [[self.eventObject objectForKey:@"typeOfEvent"] intValue];
        switch (eventType) {
            case PUBLIC_EVENT_TYPE: {
                NSString *username = [[PFUser currentUser] objectForKey:@"username"];
                
                PFRelation *eventAttendersRelation = [eventObject relationForKey:@"attenders"];
                PFQuery *attendingQuery = [eventAttendersRelation query];
                [attendingQuery whereKey:@"username" equalTo:username];
                [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"Result of Query: %@", object);
                    if (object) {
                        NSLog(@"Currently Attending Event");
                        [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                    } else {
                        NSLog(@"Not Currently Attending Event");
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                    }
                }];
                
                break;
            }
            case PRIVATE_EVENT_TYPE: {
                
                NSString *username = [[PFUser currentUser] objectForKey:@"username"];
                
                PFRelation *eventAttendersRelation = [eventObject relationForKey:@"attenders"];
                PFQuery *attendingQuery = [eventAttendersRelation query];
                [attendingQuery whereKey:@"username" equalTo:username];
                [attendingQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    NSLog(@"Result of Query: %@", object);
                    if (object) {
                        NSLog(@"Currently Attending Event");
                        [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                    } else {
                        NSLog(@"Not Currently Attending Event");
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                    }
                }];
                
                break;
            }
            case PUBLIC_APPROVED_EVENT_TYPE: {
                
                //Determine the state of the user with the event
                // Hasn't requested Accesss - Requested Access - Granted Acccess
                
                //User has not requested Access to Event
                [self.rsvpButton setTitle:kNOTRSVPedForEvent forState:UIControlStateNormal];

                PFQuery *requestedAccessQuery = [PFQuery queryWithClassName:@"Activities"];
                [requestedAccessQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:REQUEST_ACCESS_ACTIVITY]];
                [requestedAccessQuery whereKey:@"from" equalTo:[PFUser currentUser]];
                [requestedAccessQuery whereKey:@"activityContent" equalTo:self.eventObject];
                [requestedAccessQuery findObjectsInBackgroundWithBlock:^(NSArray *requestedActivityObjects, NSError *error) {
                   
                    NSLog(@"FoundObjects for RequestedAccessQuery: %@", requestedActivityObjects);
                    
                    if (requestedActivityObjects.count > 0) {
                        
                        //User has requested Access to Event
                        [self.rsvpButton setTitle:kRSVPedForEvent forState:UIControlStateNormal];

                        //Now Query For Access Granted
                        PFQuery *accessGrantedQuery = [PFQuery queryWithClassName:@"Activities"];
                        [accessGrantedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:ACCESS_GRANTED_ACTIVITY]];
                        [accessGrantedQuery whereKey:@"to" equalTo:[PFUser currentUser]];
                        [accessGrantedQuery whereKey:@"activityContent" equalTo:self.eventObject];
                        [accessGrantedQuery findObjectsInBackgroundWithBlock:^(NSArray *accessActivityObjects, NSError *error) {
                            
                            NSLog(@"FoundObjects for ACCESSGRANTED: %@", accessActivityObjects);
                            
                            if (accessActivityObjects.count > 0) {
                                
                                //User has Access to Event
                                [self.rsvpButton setTitle:kGrantedAccessToEvent forState:UIControlStateNormal];
                            }
                            
                        }];
                        
                        
                    }
                    
                }];
                
                break;
            }
            default: {
                break;
            }
        }
        
  
    }
    
    
    

    
    
    /*
    //Determine if the user is Attending Event Already
    PFQuery *queryForCurrentAttendingStatus = [PFQuery queryWithClassName:@"Events"];
    [queryForCurrentAttendingStatus whereKey:@"attenders" containsAllObjectsInArray:@[[PFUser currentUser]]];
    
    [queryForCurrentAttendingStatus getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        

        
    }];
    
    */
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if (isGuestUser) {
        
    } else {
        
    }
    
    self.eventUser = (PFUser *)eventObject[@"parent"];
    [self.eventUser fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        
        NSLog(@"User ObjectID: %@ and current user id: %@", user.objectId, [PFUser currentUser].objectId);
        
        if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.rsvpButton.hidden = YES;
        }
        
        creatorName.text = user[@"username"];
        creatorPhoto.file = (PFFile *)user[@"profilePicture"];
        [creatorPhoto loadInBackground:^(UIImage *image, NSError *error) {
            creatorPhoto.image = [EVNUtility maskImage:image withMask:[UIImage imageNamed:@"MaskImage"]];
        }];
    }];
    
    NSLog(@"Event: %@ and User: %@", eventObject, eventUser);
    
    NSDate *dateFromParse = (NSDate *)eventObject[@"dateOfEvent"];
    
    NSDateFormatter *df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:@"MM/dd 'at' hh:mm a"];
    
    NSString *localDateString = [df_local stringFromDate:dateFromParse];
    
    //PFGeoPoint *locationOfEvent = eventObject[@"locationOfEvent"];
    //NSString *locationText = [NSString stringWithFormat:@"Lat: %.02f Long: %.02f", locationOfEvent.latitude, locationOfEvent.longitude];
    //eventLocationLabel.text = locationText;
    
    eventTitle.text = eventObject[@"title"];
    dateOfEventLabel.text = localDateString;
    eventDescription.text = eventObject[@"description"];
    eventCoverPhoto.file = (PFFile *)eventObject[@"coverPhoto"];
    [eventCoverPhoto loadInBackground:^(UIImage *image, NSError *error) {
        
        [self setBackgroundOfEventViewWithImage:image];
        
    }];
    
    [self.loadingSpinner stopAnimating];
    
    
    
    
    
    

    
    
}


- (void) startSearchForEventPhotos {
    
    NSLog(@"What eventImages contains: %@", eventObject[@"eventImages"]);
    
    picturesFromEvent = eventObject[@"eventImages"];
    
    
    
    //see what eventObject[@"eventImages"] returns.
    
    //Grab the array 'eventImages' from the event table. // set it to picturesFromEvent;
    //it's a list of pffiles.
    //this array of pffiles can be used for datasource methods of the uicollection view.  count should be good.
    //Next assign a default image for each cell created (number of pffiles stored on parse)
    //Use a PFImageView and assign the pffile to the imageview.
    //need to create a custom cell.
    
    
}

#pragma mark -
#pragma mark CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [picturesFromEvent count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"EventPhotoCell";
    
    EventPictureCell *cell = (EventPictureCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.eventPictureView.image = [UIImage imageNamed:@"EventsTabIcon"];
    
    PFFile *currentPictureFile = [picturesFromEvent objectAtIndex:indexPath.row];
    
    cell.eventPictureView.file = currentPictureFile;
    [cell.eventPictureView loadInBackground];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //TODO: For all blur effects, move initialization to top and in these methods just change alpha values.  no need to recreate each time.
    UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectForModals = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    self.blurEffectForModals.alpha = 0;
    self.blurEffectForModals.frame = self.view.bounds;
    [self.view addSubview:self.blurEffectForModals];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    [[self.blurEffectForModals contentView] addSubview:vibrancyEffectView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.blurEffectForModals.alpha = 0.9;
    } completion:^(BOOL finished) {
        
        NSLog(@"Finished");
        
    }];
    
    /* animate screenshot of view
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.4, 1.4);
    }];
    */
    
    PictureFullScreenVC *displayFullScreenPhoto = (PictureFullScreenVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PictureViewController"];
    
    displayFullScreenPhoto.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    displayFullScreenPhoto.transitioningDelegate = self.customTransitionDelegate;
    displayFullScreenPhoto.fileOfEventPhoto = (PFFile *)[picturesFromEvent objectAtIndex:indexPath.row];
    displayFullScreenPhoto.delegate = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.navigationController.navigationBar.alpha = 0;
        self.tabBarController.tabBar.alpha = 0;
        
    } completion:^(BOOL finished) {
       
        self.navigationController.navigationBar.hidden = finished;
        self.tabBarController.tabBar.hidden = finished;
        
    }];
    
    [self presentViewController:displayFullScreenPhoto animated:YES completion:nil];
    /*
    ResetPasswordModalVC *resetPasswordModal = (ResetPasswordModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordModalView"];
    resetPasswordModal.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    resetPasswordModal.transitioningDelegate = self.transitioningDelegateForModal;
    resetPasswordModal.delegate = self;
     */
    
}


- (void)returnToEvent {
    
    NSLog(@"IS THIS BEING CALLED");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.navigationController.navigationBar.alpha = 1;
        self.tabBarController.tabBar.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.blurEffectForModals.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blurEffectForModals removeFromSuperview];
        self.blurEffectForModals = nil;
        NSLog(@"Finished");
        
    }];
}

#pragma mark -
#pragma mark - Upload Picture From Event

- (IBAction)uploadPhotoFromEvent:(id)sender {
    
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    //Check to see if device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    [pictureOptionsMenu addAction:cancelAction];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
    
    
}


#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    PFFile *profilePictureFile = [PFFile fileWithName:@"eventPhoto.jpg" data:pictureData];
    
    //save picture as pffile to parse
    [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            
            //append pffile to eventImages array on event (PFObject)
            [self.eventObject addObject:profilePictureFile forKey:@"eventImages"];
            [self.eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    [self.pictureCollectionView reloadData];
                }
                
            }];
            
        }
    }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}



- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    NSLog(@"AHHHAHHHAHAHHAHHHAHAHAH");
    
    [self.navigationController.navigationBar setBackgroundImage:self.navBarBackground
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = self.navbarShadow;
    self.navigationController.navigationBar.translucent = YES;
    
    //self.navigationController.navigationBar.barTintColor = [UIColor orangeThemeColor];
    //self.navigationController.navigationBar.translucent = YES;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) setBackgroundOfEventViewWithImage:(UIImage *)image {
    //Set Background to Blurred Cover Photo Image
    UIImage *blurredCoverPhotoForBackground = [UIImageEffects imageByApplyingDarkEffectToImage:image];
    self.view.backgroundColor = [UIColor colorWithPatternImage:blurredCoverPhotoForBackground];
}


#pragma mark -
#pragma mark - Loading View
- (void)startLoadingAnimationAndBlur {
    NSLog(@"Blur");
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    NSLog(@"Frame W: %f", visualEffectView.frame.size.width);
    NSLog(@"Frame H: %f", visualEffectView.frame.size.height);
    NSLog(@"Frame X: %f", visualEffectView.frame.origin.x);
    NSLog(@"Frame Y: %f", visualEffectView.frame.origin.y);

    [visualEffectView setFrame:self.view.bounds];
    
    NSLog(@"Frame W: %f", visualEffectView.frame.size.width);
    NSLog(@"Frame H: %f", visualEffectView.frame.size.height);
    NSLog(@"Frame X: %f", visualEffectView.frame.origin.x);
    NSLog(@"Frame Y: %f", visualEffectView.frame.origin.y);
    
    
    [self.view addSubview:visualEffectView];
    
}

- (void)stopLoadingAnimationAndBlur {
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


//Current: User is added to the event as a Relation.  No information about the activity is stored (ie timestamp)
//Update:  User is added to the event as a Relation and an entry in the activity table is created - will be used for Activity/Notifications View.
//Long-Term:  Is this the best solution?
- (IBAction)rsvpForEvent:(id)sender {
    
    int eventType = [[self.eventObject objectForKey:@"typeOfEvent"] intValue];
    
    if (isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
    
    } else if (eventType == PUBLIC_APPROVED_EVENT_TYPE) {
        
        //Currently only allowing an RSVP - not to cancel an RSVP
        if ([rsvpButton.titleLabel.text isEqualToString:kNOTRSVPedForEvent]) {
            
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
        
        if ([rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            NSLog(@"Removing PFRelation");
            
            [attendersRelation removeObject:[PFUser currentUser]];
            [eventObject saveInBackground];
            
            //[self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
            
        } else {
            
            NSLog(@"Adding PFRelation");
            
            //Create New Relation and Add User to List of Attenders for Event
            [attendersRelation addObject:[PFUser currentUser]];
            [eventObject saveInBackground];
            
            //[self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
        }
        
        
        //CREATING AN ENTRY IN THE ACTIVITY TABLE
        if ([rsvpButton.titleLabel.text isEqualToString:kAttendingEvent]) {
            
            NSLog(@"Deleting an Entry in the Activity Table");
            
            //Disable the rsvp button
            self.rsvpButton.enabled = NO;
            
            //Query for the Previous Entry
            PFQuery *queryForRSVP = [PFQuery queryWithClassName:@"Activities"];
            [queryForRSVP whereKey:@"type" equalTo:[NSNumber numberWithInt:ATTENDING_ACTIVITY]];
            [queryForRSVP whereKey:@"to" equalTo:[PFUser currentUser]];
            [queryForRSVP whereKey:@"activityContent" equalTo:eventObject];
            [queryForRSVP findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                PFObject *previousActivity = [objects firstObject];
                [previousActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        [self.rsvpButton setTitle:kNotAttendingEvent forState:UIControlStateNormal];
                        
                    } else {
                        NSLog(@"Failed to Delete Previous Activity");
                    }
                    
                    //re-enable the RSVP button
                    self.rsvpButton.enabled = YES;
                    
                    
                }];
                
            }];
            
            
        } else {
            
            NSLog(@"Creating a New Entry in the Activity Table");
            
            //Disable Button
            self.rsvpButton.enabled = NO;
            
            PFObject *newAttendingActivity = [PFObject objectWithClassName:@"Activities"];
            newAttendingActivity[@"to"] = [PFUser currentUser];
            newAttendingActivity[@"type"] = [NSNumber numberWithInt:ATTENDING_ACTIVITY];
            newAttendingActivity[@"activityContent"] = eventObject;
            [newAttendingActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    //if succeeded, change the title to reflect the RSVP event
                    [self.rsvpButton setTitle:kAttendingEvent forState:UIControlStateNormal];
                    
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
    
    if (isGuestUser) {
        
        [self performSegueWithIdentifier:@"EventDetailToInitial" sender:self];
        
    } else {
        
        PeopleVC *viewAttendees = [self.storyboard instantiateViewControllerWithIdentifier:@"viewUsersCollection"];
        
        viewAttendees.typeOfUsers = VIEW_EVENT_ATTENDERS;
        viewAttendees.eventToViewAttenders = eventObject;
        
        [self.navigationController pushViewController:viewAttendees animated:YES];
    }
    

    
}





@end
