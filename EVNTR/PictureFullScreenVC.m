//
//  PictureFullScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "PictureFullScreenVC.h"

@interface PictureFullScreenVC ()

@property (nonatomic, strong) UIButton *removePhoto;

@end

@implementation PictureFullScreenVC

#pragma mark - Initialization Methods

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _removePhoto = [[UIButton alloc] init];
        _removePhoto.titleLabel.textColor = [UIColor redColor];
        [_removePhoto setTitle:@"X" forState:UIControlStateNormal];
        _removePhoto.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:24];
        [_removePhoto addTarget:self action:@selector(removePhotoFromEvent) forControlEvents:UIControlEventTouchUpInside];
        _removePhoto.translatesAutoresizingMaskIntoConstraints = NO;
        _showRemovePhotoAction = NO;
    }
    
    return self;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.removePhoto];
    
    self.eventPhotoView.image = [UIImage imageNamed:@"PersonDefault"];
    self.eventPhotoView.file = [self.eventPictureObject objectForKey:@"pictureFile"];
    [self.eventPhotoView loadInBackground];
    
    //Tap to dismiss.
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToEvent:)];
    [self.eventPhotoView.superview addGestureRecognizer:tapgr];
    
}


#pragma mark - Layout Views

- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSString *removePhotosString = @"Remove Photos";
    
    CGSize size = [removePhotosString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:24]}];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    //Center X
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.removePhoto
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    
    //Below Image View
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.removePhoto
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.eventPhotoView
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:12]];
    
    //80% Width
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.removePhoto
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:0.8
                              constant:0.0]];
    
    //Height Related to Text String
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.removePhoto
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.0
                              constant:adjustedSize.height + 10]];
}


#pragma mark - Custom Setters

- (void) setShowRemovePhotoAction:(BOOL)showRemovePhotoAction {
    
    _showRemovePhotoAction = showRemovePhotoAction;
    
    self.removePhoto.hidden = (showRemovePhotoAction) ? NO : YES;
    
}


#pragma mark - User Actions

- (void) removePhotoFromEvent {
    
    
    UIAlertController *removePhotoVerifySheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Remove Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        self.removePhoto.enabled = NO;
        
        [self.eventPictureObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                id<PictureViewerDelegate> strongDelegate = self.delegate;
                
                if ([strongDelegate respondsToSelector:@selector(returnToPicturesViewAndDeletePhoto:)]) {
                    
                    [strongDelegate returnToPicturesViewAndDeletePhoto:YES];
                }
                
            } else {
                
                UIAlertView *issueRemoving = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"We couldn't delete the photo, try again. Send us an email or tweet from the Settings page if it still doesn't work." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
                
                [issueRemoving show];
                
                self.removePhoto.enabled = YES;
            }
            
        }];
        
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    
    [removePhotoVerifySheet addAction:deleteAction];
    [removePhotoVerifySheet addAction:cancelAction];
    
    [self presentViewController:removePhotoVerifySheet animated:YES completion:nil];

    
}


- (void) backToEvent:(id)sender {
    
    id<PictureViewerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(returnToPicturesViewAndDeletePhoto:)]) {
        
        [strongDelegate returnToPicturesViewAndDeletePhoto:NO];
    }
}



@end
