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

@synthesize eventPhotoView, fileOfEventPhoto;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventPhotoView.image = [UIImage imageNamed:@"EventsTabIcon"];
    self.eventPhotoView.file = fileOfEventPhoto;
    [self.eventPhotoView loadInBackground];
    
    //Tap to dismiss.
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToEvent:)];
    [self.eventPhotoView.superview addGestureRecognizer:tapgr];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToEvent:(id)sender {
    
    id<PictureViewerDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(returnToEvent)]) {
        
        [strongDelegate returnToEvent];
    }
}
@end
