//
//  SplashScreenVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SplashScreenVC.h"
#import "IDTransitioningDelegate.h"
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
    // Do any additional setup after loading the view.
    
    self.customTransitionDelegate = [[IDTransitioningDelegate alloc] init];

    self.taglineLabel.alpha = 0;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
    [UIView animateWithDuration:1.5 animations:^{
        
        self.splashScreenEmptyMiddle.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2.2 animations:^{
            
            self.evntrSingleImage.transform = CGAffineTransformMakeRotation(M_PI * -12 / 180);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                //self.evntrSingleImage.transform = CGAffineTransformMakeScale(10, 10);
                //self.evntrSingleImage.alpha = 0;
                
                self.taglineLabel.alpha = 1;
                
            } completion:^(BOOL finished) {
               
                NSLog(@"Finished");
                [self performSegueWithIdentifier:@"ShowInitialScreen" sender:nil];

                
            }];

        }];
        
    }];
    
    
    /*
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
    });
    */
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

@end
