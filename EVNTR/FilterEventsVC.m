//
//  FilterEventsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/13/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "FilterEventsVC.h"

@interface FilterEventsVC ()


- (IBAction)distance1Press:(id)sender;
- (IBAction)distance2Press:(id)sender;
- (IBAction)distance3Press:(id)sender;
- (IBAction)distance4Press:(id)sender;
- (IBAction)distance5Press:(id)sender;
- (IBAction)distance6Press:(id)sender;
- (IBAction)distance7Press:(id)sender;
- (IBAction)distance8Press:(id)sender;

@property (nonatomic, strong) NSNotificationCenter *notifcationCenter;

@end

@implementation FilterEventsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.notifcationCenter = [NSNotificationCenter defaultCenter];
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

- (IBAction)distance1Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance2Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance3Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance4Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance5Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance6Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance7Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
}

- (IBAction)distance8Press:(id)sender {
    
    [self.notifcationCenter postNotificationName:@"FilterApplied" object:sender userInfo:nil];
    
}
@end
