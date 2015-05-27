//
//  SplashScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SplashScreenVC.h"
#import "IDTTransitioningDelegate.h"
#import "InitialScreenVC.h"

@interface SplashScreenVC ()

@property (strong, nonatomic) IBOutlet UIImageView *splashScreenEmptyMiddle;
@property (strong, nonatomic) IBOutlet UIImageView *evntrSingleImage;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> customTransitionDelegate;

@end

@implementation SplashScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customTransitionDelegate = [[IDTTransitioningDelegate alloc] init];
    self.taglineLabel.alpha = 0;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.splashScreenEmptyMiddle.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            
            self.evntrSingleImage.transform = CGAffineTransformMakeRotation(M_PI * -12 / 180);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                self.taglineLabel.alpha = 1;
                
            } completion:^(BOOL finished) {
               
                [self performSegueWithIdentifier:@"ShowInitialScreen" sender:nil];
                
            }];

        }];
        
    }];
    
}



@end
