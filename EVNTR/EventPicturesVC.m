//
//  EventPicturesVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/18/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "EventPicturesVC.h"
#import "EVNConstants.h"
#import "EVNUtility.h"
#import "IDTTransitioningDelegate.h"
#import "UIColor+EVNColors.h"

static NSString * const reuseIdentifier = @"pictureCell";

@interface EventPicturesVC ()

@property (strong, nonatomic) NSMutableArray *eventImages;
@property (nonatomic, strong) NSIndexPath *selectedPhoto;

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;
@property (nonatomic, strong) UIVisualEffectView *blurEffectForModals;
@property (nonatomic, strong) UILabel *noResultsLabel;

@end

@implementation EventPicturesVC

#pragma mark - Lifecycle Methods

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _allowsAddingPictures = NO;
        _allowsChoosingPictures = NO;
        _eventImages = [[NSMutableArray alloc] init];
        _customTransitionDelegate = [[IDTTransitioningDelegate alloc] init];
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Event Photos";
    self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.allowsAddingPictures) {
        UIBarButtonItem *addPicturesIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
        self.navigationItem.rightBarButtonItem = addPicturesIcon;
    }
    
    [self.eventObject queryForImagesWithCompletion:^(NSArray *images) {
        
        self.eventImages = [NSMutableArray arrayWithArray:images];
        
        if (self.eventImages.count == 0) {
            [self showNoResultsView];
        } else {
            self.noResultsLabel.hidden = YES;
            [self.collectionView reloadData];
        }
    
    }];

}


#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.eventImages.count > MAX_PHOTOS_COLLECTION_VIEW) {
        return MAX_PHOTOS_COLLECTION_VIEW;
    } else {
        return self.eventImages.count;
    }
    
}

//TODO: Sublcass UICollectionViewCell to Use PFImageView
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PictureDefault"]];
    
    PFFile *fileForPhoto = [[self.eventImages objectAtIndex:indexPath.row] objectForKey:@"pictureFile"];
    
    [fileForPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (data) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
        }
        
    }];
    
    
    return cell;
}


#pragma mark - UICollection View Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self animateBackgroundDarkBlur];
    
    self.selectedPhoto = indexPath;
    
    PFObject *pictureObject = (PFObject *) [self.eventImages objectAtIndex:indexPath.row];
    EVNUser *pictureTakenBy = (EVNUser *)[pictureObject objectForKey:@"takenBy"];
    
    PictureFullScreenVC *displayFullScreenPhoto = (PictureFullScreenVC *) [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"PictureViewController"];
    
    displayFullScreenPhoto.modalPresentationStyle = UIModalPresentationOverFullScreen;
    displayFullScreenPhoto.transitioningDelegate = self.customTransitionDelegate;
    displayFullScreenPhoto.eventPictureObject = pictureObject;
    displayFullScreenPhoto.delegate = self;
    displayFullScreenPhoto.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Allow Photos to Be Removed Event Creators and Photo Takers
    if ([self.eventObject.parent.objectId isEqualToString:[EVNUser currentUser].objectId]) {
        displayFullScreenPhoto.showRemovePhotoAction = YES;
    } else {
        if ([pictureTakenBy.objectId isEqualToString:[EVNUser currentUser].objectId]) {
            displayFullScreenPhoto.showRemovePhotoAction = YES;
        } else {
            displayFullScreenPhoto.showRemovePhotoAction = NO;
        }
    }
    
    [self presentViewController:displayFullScreenPhoto animated:YES completion:nil];
    
    
    [UIView animateWithDuration:0.2 animations:^{

        self.tabBarController.tabBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.tabBarController.tabBar.hidden = finished;
        
    }];
    
}


- (void) collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        
        cell.alpha = 1;
        cell.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UICollectionFlowLayout Delegate Methods

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
    
}



#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    PFFile *eventPhotoFile = [PFFile fileWithName:@"eventPhoto.jpg" data:pictureData];
    
    [eventPhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){
            
            PFObject *picture = [PFObject objectWithClassName:@"Pictures"];
            picture[@"pictureFile"] = eventPhotoFile;
            picture[@"takenBy"] = [EVNUser currentUser];
            picture[@"eventParent"] = self.eventObject;
            
            [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    if (!self.eventImages) {
                        self.eventImages = [[NSMutableArray alloc] init];
                    }
                    
                    [self.eventImages addObject:picture];
                    self.noResultsLabel.hidden = YES;
                    
                    NSUInteger numberOfItems = [self.eventImages count] - 1;
                    NSIndexPath *indexPathOfLastRow = [NSIndexPath indexPathForRow:numberOfItems inSection:0];
                    
                    [self.collectionView insertItemsAtIndexPaths:@[indexPathOfLastRow]];
                    
                    //Notify Event Details VC of New Picture
                    id<EventPicturesProtocol> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(newPictureAdded)]) {
                        
                        [strongDelegate newPictureAdded];
                    }
                
                } else {
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Looks like we had trouble saving your picture.  Try again and if you still have issues, send us an email or tweet from the settings page." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
                    
                    [errorAlert show];
                }
            }];
        
        } else {
            
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Looks like we had trouble saving your picture.  Try again and if you still have issues, send us an email or tweet at us from the settings page." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [errorAlert show];
        }
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}



#pragma mark - Delegate for Full Screen Image Viewer

- (void) returnToPicturesViewAndDeletePhoto:(BOOL) shouldDeletePhoto {

    if (shouldDeletePhoto) {
        [self.eventImages removeObjectAtIndex:self.selectedPhoto.row];
        [self.collectionView deleteItemsAtIndexPaths:@[self.selectedPhoto]];
        
        if (self.eventImages.count == 0) {
            [self showNoResultsView];
        }
        
        //Notify Event Details VC of Removal
        id<EventPicturesProtocol> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(pictureRemoved)]) {
            [strongDelegate pictureRemoved];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.blurEffectForModals.alpha = 0;
        self.navigationController.navigationBar.alpha = 1;
        self.tabBarController.tabBar.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        self.blurEffectForModals.hidden = YES;
        
    }];
    
    
}


#pragma mark - User Actions

- (void) addPhoto {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.amplitudeInstance logEvent:@"Added Photo"];
    
    UIAlertController *pictureOptionsMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [pictureOptionsMenu addAction:takePhoto];
    }
    
    
    if (self.allowsChoosingPictures) {
        
        UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIImagePickerController *chooseImagePicker = [[UIImagePickerController alloc] init];
            chooseImagePicker.delegate = self;
            chooseImagePicker.allowsEditing = YES;
            chooseImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            chooseImagePicker.view.tintColor = [UIColor orangeThemeColor];
            chooseImagePicker.navigationBar.tintColor = [UIColor orangeThemeColor];
            chooseImagePicker.navigationController.navigationBar.tintColor = [UIColor orangeThemeColor];
            
            [self presentViewController:chooseImagePicker animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                
            }];
            
        }];
        
        [pictureOptionsMenu addAction:choosePhoto];
        
    }
    
    [pictureOptionsMenu addAction:cancelAction];
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
}



#pragma mark - Helper Methods

- (void) showNoResultsView {
    
    if (!self.noResultsLabel) {
        self.noResultsLabel = [[UILabel alloc] init];
        self.noResultsLabel.frame = CGRectMake(0, 120, self.view.frame.size.width, 100);
        self.noResultsLabel.text = @"No Pictures";
        self.noResultsLabel.font = [UIFont fontWithName:EVNFontLight size:21.0];
        self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:self.noResultsLabel];
    }
    
    self.noResultsLabel.hidden = NO;
}

- (void) animateBackgroundDarkBlur {
    
    if (!self.blurEffectForModals) {
        
        UIBlurEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectForModals = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
        self.blurEffectForModals.alpha = 0;
        self.blurEffectForModals.frame = [UIScreen mainScreen].bounds;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.blurEffectForModals];

        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:darkBlur];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:self.view.bounds];
        
        [[self.blurEffectForModals contentView] addSubview:vibrancyEffectView];
        
    }
    
    self.blurEffectForModals.alpha = 0;
    self.blurEffectForModals.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.blurEffectForModals.alpha = 0.9;
    
    } completion:nil];
    
    
}




@end
