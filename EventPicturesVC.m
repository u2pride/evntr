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
#import "IDTransitioningDelegate.h"
#import "UIColor+EVNColors.h"

@interface EventPicturesVC ()

@property (strong, nonatomic) NSMutableArray *eventImages;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;
@property (nonatomic, strong) UIVisualEffectView *blurEffectForModals;

@property (nonatomic, strong) UILabel *noResultsLabel;

//Selected Photo Index
@property (nonatomic, strong) NSIndexPath *selectedPhoto;


@end

@implementation EventPicturesVC

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Navigation Bar Font & Color
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = navFontDictionary;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.title = @"Event Photos";
    
    if (self.allowsAddingPictures) {
        
        UIBarButtonItem *addPicturesIcon = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
        self.navigationItem.rightBarButtonItem = addPicturesIcon;
        
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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


- (void) showNoResultsView {
    
    if (!self.noResultsLabel) {
        self.noResultsLabel = [[UILabel alloc] init];
        self.noResultsLabel.text = @"No Pictures";
        self.noResultsLabel.font = [UIFont fontWithName:EVNFontLight size:21.0];
        self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
        
        self.noResultsLabel.frame = CGRectMake(0, 120, self.view.frame.size.width, 100);
        
        [self.view addSubview:self.noResultsLabel];
        
    }
    
    self.noResultsLabel.hidden = NO;
    
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //self.tabBarController.tabBar.hidden = NO;
}


- (void) addPhoto {
    
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
    
    pictureOptionsMenu.view.tintColor = [UIColor orangeThemeColor];
    
    [self presentViewController:pictureOptionsMenu animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    NSLog(@"Make sure this is only getting called once");
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //If there are more than 50 images, return the first 50.
    if (self.eventImages.count > 50) {
        
        return 50;
        
    } else {
        
        return self.eventImages.count;

    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PersonDefault"]];
    
    PFFile *fileForPhoto = [[self.eventImages objectAtIndex:indexPath.row] objectForKey:@"pictureFile"];
    
    //Load Image in Background
    [fileForPhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        NSLog(@"Making a network call");
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
        
    }];
    
    self.selectedPhoto = indexPath;
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self animateBackgroundDarkBlur];
    
    PFObject *pictureObject = (PFObject *) [self.eventImages objectAtIndex:indexPath.row];
    EVNUser *pictureTakenBy = (EVNUser *)[pictureObject objectForKey:@"takenBy"];
    
    PictureFullScreenVC *displayFullScreenPhoto = (PictureFullScreenVC *)[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"PictureViewController"];
    
    displayFullScreenPhoto.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    displayFullScreenPhoto.transitioningDelegate = self.customTransitionDelegate;
    displayFullScreenPhoto.eventPictureObject = pictureObject;
    displayFullScreenPhoto.delegate = self;
    
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
        
        self.navigationController.navigationBar.alpha = 0;
        self.tabBarController.tabBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.navigationController.navigationBar.hidden = finished;
        self.tabBarController.tabBar.hidden = finished;
        
    }];
    
    
    
    
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark - Delegate Methods for UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *chosenPicture = info[UIImagePickerControllerEditedImage];
    
    NSData *pictureData = UIImageJPEGRepresentation(chosenPicture, 0.5);
    PFFile *profilePictureFile = [PFFile fileWithName:@"eventPhoto.jpg" data:pictureData];
    
    //save picture as pffile to parse
    [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            
            //create new picture pfobject and save
            PFObject *picture = [PFObject objectWithClassName:@"Pictures"];
            picture[@"pictureFile"] = profilePictureFile;
            picture[@"takenBy"] = [EVNUser currentUser];
            picture[@"eventParent"] = self.eventObject;
            
            [picture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    if (!self.eventImages) {
                        self.eventImages = [[NSMutableArray alloc] init];
                    }
                    
                    [self.eventImages addObject:picture];
                    
                    self.noResultsLabel.hidden = YES;
                    
                    //Instead of refreshing all items, just insert a row.
                    NSUInteger numberOfItems = [self.eventImages count] - 1;
                    NSIndexPath *indexPathOfLastRow = [NSIndexPath indexPathForRow:numberOfItems inSection:0];
                    
                    NSLog(@"indexpath: %ld and %ld", (long)indexPathOfLastRow.row, (long)indexPathOfLastRow.section);

                    //[self.collectionView reloadData];
                    [self.collectionView insertItemsAtIndexPaths:@[indexPathOfLastRow]];
                    
                    
                    //Notify Event Details VC of New Picture
                    id<EventPicturesProtocol> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(newPictureAdded)]) {
                        
                        [strongDelegate newPictureAdded];
                    }
                }
            }];
            
            
            /*
            //append pffile to eventImages array on event (PFObject)
            [self.eventObject addObject:profilePictureFile forKey:@"eventImages"];
            [self.eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    if (!self.eventImages) {
                        self.eventImages = [[NSMutableArray alloc] init];
                    }
                    
                    [self.eventImages addObject:profilePictureFile];
                    
                    [self.collectionView reloadData];
                    
                    //Notify Event Details VC of New Picture
                    id<EventPicturesProtocol> strongDelegate = self.delegate;
                    
                    if ([strongDelegate respondsToSelector:@selector(newPictureAdded)]) {
                        
                        [strongDelegate newPictureAdded];
                    }
                    
                    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self.pictureCollectionView selector:@selector(reloadData) userInfo:nil repeats:NO];
                }
                
            }];
            */
            
        }
    }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - Delegate for Full Screen Image Viewer

- (void) returnToEventAndDeletePhoto:(BOOL) shouldDeletePhoto {

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
    [UIView animateWithDuration:0.2 animations:^{
        self.blurEffectForModals.alpha = 0.9;
    } completion:^(BOOL finished) {
        
    }];
    
    
}


-(void)dealloc
{
    NSLog(@"eventpictures is being deallocated");
}




@end
