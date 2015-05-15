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

- (IBAction)backToEvent:(id)sender;

@end

@implementation PictureFullScreenVC

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _removePhoto = [[UIButton alloc] init];
        _removePhoto.titleLabel.textColor = [UIColor redColor];
        [_removePhoto setTitle:@"Remove Photo" forState:UIControlStateNormal];
        _removePhoto.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:21];
        [_removePhoto addTarget:self action:@selector(removePhotoFromEvent) forControlEvents:UIControlEventTouchUpInside];
        _removePhoto.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return self;
}


- (void) setShowRemovePhotoAction:(BOOL)showRemovePhotoAction {
    
    _showRemovePhotoAction = showRemovePhotoAction;
    
    self.removePhoto.hidden = (showRemovePhotoAction) ? NO : YES;
    
}


- (void) removePhotoFromEvent {
    
    NSLog(@"remove photo");
    self.removePhoto.enabled = NO;
    
    [self.eventPictureObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        id<PictureViewerDelegate> strongDelegate = self.delegate;
        
        if ([strongDelegate respondsToSelector:@selector(returnToEventAndDeletePhoto:)]) {
            
            [strongDelegate returnToEventAndDeletePhoto:YES];
        }
        
        if (!succeeded) {
            self.removePhoto.enabled = YES;
        }
        
    }];
    
}

- (void) updateViewConstraints {
    
    [super updateViewConstraints];
    
    
    NSString *removePhotosString = @"Remove Photos";
    
    CGSize size = [removePhotosString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:21]}];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    NSLog(@"size: %@", NSStringFromCGSize(adjustedSize));
    
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
                         constant:32]];
    
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

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    

    
    //self.edgesForExtendedLayout = UIRectEdgeTop;
    //self.extendedLayoutIncludesOpaqueBars = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backToEvent:(id)sender {
    
    id<PictureViewerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(returnToEventAndDeletePhoto:)]) {
        
        [strongDelegate returnToEventAndDeletePhoto:NO];
    }
}


-(void)dealloc {
    
    NSLog(@"picturefullscreenvc is being deallocated");
}
@end
