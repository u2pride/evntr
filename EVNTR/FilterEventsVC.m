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
    
    int doubledValue = (int) (self.selectedFilterDistance * 2);
    
    NSLog(@"Int Value - %d", doubledValue);
    
    switch (doubledValue) {
        case 1: {
            self.distance1Button.selected = YES;
            [self.distance1Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 2: {
            self.distance2Button.selected = YES;

            [self.distance2Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 6: {
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
        case 30: {
            self.distance6Button.selected = YES;

            [self.distance6Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 40: {
            self.distance7Button.selected = YES;

            [self.distance7Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        case 2000: {
            self.distance8Button.selected = YES;

            [self.distance8Button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateSelected];
            break;
        }
        default:
            break;
    }
    
    
}


- (IBAction)distance1Press:(id)sender {
    
    self.distance1Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:0.5];
    }
    
}

- (IBAction)distance2Press:(id)sender {
    
    self.distance2Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:1];
    }

}

- (IBAction)distance3Press:(id)sender {
    
    self.distance3Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:3];
    }

}

- (IBAction)distance4Press:(id)sender {
    
    self.distance4Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:5];
    }

}

- (IBAction)distance5Press:(id)sender {
    
    self.distance5Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:10];
    }

}

- (IBAction)distance6Press:(id)sender {
    
    self.distance6Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:15];
    }

}

- (IBAction)distance7Press:(id)sender {
    
    self.distance7Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:20];
    }

}

- (IBAction)distance8Press:(id)sender {
    
    self.distance8Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:1000];
    }
    
}

-(void)dealloc
{
    NSLog(@"filtereventsvc is being deallocated");
}
@end
