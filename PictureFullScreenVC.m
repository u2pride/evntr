//
//  PictureFullScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "PictureFullScreenVC.h"

@interface PictureFullScreenVC ()

- (IBAction)backToEvent:(id)sender;

@end

@implementation PictureFullScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.eventPhotoView.image = [UIImage imageNamed:@"EventsTabIcon"];
    self.eventPhotoView.file = self.fileOfEventPhoto;
    [self.eventPhotoView loadInBackground];
    
    //Tap to dismiss.
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToEvent:)];
    [self.eventPhotoView.superview addGestureRecognizer:tapgr];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backToEvent:(id)sender {
    
    id<PictureViewerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(returnToEvent)]) {
        
        [strongDelegate returnToEvent];
    }
}

-(void)dealloc
{
    NSLog(@"picturefullscreenvc is being deallocated");
}
@end
