//
//  GuestWelcomeVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "GuestWelcomeVC.h"
#import "TabNavigationVC.h"
#import "UIColor+EVNColors.h"

@interface GuestWelcomeVC ()

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation GuestWelcomeVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.continueButton.backgroundColor = [UIColor orangeThemeColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //TabNavigationVC *tabVC = (TabNavigationVC *) [segue destinationViewController];
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
