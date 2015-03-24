//
//  FilterEventsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/13/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "FilterEventsVC.h"

@interface FilterEventsVC ()

@property (strong, nonatomic) IBOutlet UIButton *distance1Button;
@property (strong, nonatomic) IBOutlet UIButton *distance2Button;
@property (strong, nonatomic) IBOutlet UIButton *distance3Button;
@property (strong, nonatomic) IBOutlet UIButton *distance4Button;
@property (strong, nonatomic) IBOutlet UIButton *distance5Button;
@property (strong, nonatomic) IBOutlet UIButton *distance6Button;
@property (strong, nonatomic) IBOutlet UIButton *distance7Button;
@property (strong, nonatomic) IBOutlet UIButton *distance8Button;

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
    
    NSLog(@"selected: %d", self.selectedFilterDistance);
    
    
    
    switch (self.selectedFilterDistance) {
        case 1: {
            self.distance1Button.selected = YES;
            [self.distance1Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 3: {
            self.distance2Button.selected = YES;

            [self.distance2Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 5: {
            self.distance3Button.selected = YES;

            [self.distance3Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 10: {
            self.distance4Button.selected = YES;

            [self.distance4Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 20: {
            self.distance5Button.selected = YES;

            [self.distance5Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 50: {
            self.distance6Button.selected = YES;

            [self.distance6Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 100: {
            self.distance7Button.selected = YES;

            [self.distance7Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 800: {
            self.distance8Button.selected = YES;

            [self.distance8Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        default:
            break;
    }
    
    
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
