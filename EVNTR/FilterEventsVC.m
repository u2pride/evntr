//
//  FilterEventsVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/13/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "FilterEventsVC.h"
#import "QuartzCore/QuartzCore.h"
#import "UIColor+EVNColors.h"

#import <Parse/Parse.h>

@interface FilterEventsVC ()

@property (strong, nonatomic) IBOutlet UILabel *distanceFilterHeaderLabel;

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

@end

@implementation FilterEventsVC

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEasterEggMessage)];
    tapGesture.numberOfTapsRequired = 3;
    self.distanceFilterHeaderLabel.userInteractionEnabled = YES;
    [self.distanceFilterHeaderLabel addGestureRecognizer:tapGesture];
    
    self.distance1Button.tintColor = [UIColor orangeThemeColor];
    self.distance2Button.tintColor = [UIColor orangeThemeColor];
    self.distance3Button.tintColor = [UIColor orangeThemeColor];
    self.distance4Button.tintColor = [UIColor orangeThemeColor];
    self.distance5Button.tintColor = [UIColor orangeThemeColor];
    self.distance6Button.tintColor = [UIColor orangeThemeColor];
    self.distance7Button.tintColor = [UIColor orangeThemeColor];
    self.distance8Button.tintColor = [UIColor orangeThemeColor];
    
    self.distance1Button.layer.cornerRadius = self.distance1Button.bounds.size.width / 2.0f;
    self.distance2Button.layer.cornerRadius = self.distance2Button.bounds.size.width / 2.0f;
    self.distance3Button.layer.cornerRadius = self.distance3Button.bounds.size.width / 2.0f;
    self.distance4Button.layer.cornerRadius = self.distance4Button.bounds.size.width / 2.0f;
    self.distance5Button.layer.cornerRadius = self.distance5Button.bounds.size.width / 2.0f;
    self.distance6Button.layer.cornerRadius = self.distance6Button.bounds.size.width / 2.0f;
    self.distance7Button.layer.cornerRadius = self.distance7Button.bounds.size.width / 2.0f;
    self.distance8Button.layer.cornerRadius = self.distance8Button.bounds.size.width / 2.0f;

    int doubledValue = (int) (self.selectedFilterDistance * 2);
    
    switch (doubledValue) {
        case 1: {
            
            self.distance1Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance1Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        case 2: {
            self.distance2Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            break;
        }
        case 6: {
            self.distance3Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance3Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            break;
        }
        case 10: {
            self.distance4Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance4Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        case 20: {
            self.distance5Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance5Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        case 30: {
            self.distance6Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance6Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        case 40: {
            self.distance7Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance7Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        case 60: {
            self.distance8Button.backgroundColor = [UIColor orangeThemeColor];
            [self.distance8Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        }
        default:
            break;
    }
    
    
}


#pragma mark - User Actions

- (IBAction)distance1Press:(id)sender {
    
    self.distance1Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance1Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:0.5];
    }
    
}

- (IBAction)distance2Press:(id)sender {
    
    self.distance2Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance2Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:1];
    }

}

- (IBAction)distance3Press:(id)sender {
    
    self.distance3Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance3Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:3];
    }

}

- (IBAction)distance4Press:(id)sender {
    
    self.distance4Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance4Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:5];
    }

}

- (IBAction)distance5Press:(id)sender {
    
    self.distance5Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance5Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:10];
    }

}

- (IBAction)distance6Press:(id)sender {
    
    self.distance6Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance6Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:15];
    }

}

- (IBAction)distance7Press:(id)sender {
    
    self.distance7Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance7Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:20];
    }

}

- (IBAction)distance8Press:(id)sender {
    
    self.distance8Button.backgroundColor = [UIColor orangeThemeColor];
    
    self.distance8Button.enabled = NO;
    
    id<EVNFilterProtocol> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(completedFiltering:)]) {
        
        [strongDelegate completedFiltering:30];
    }
    
}

- (void) showEasterEggMessage {
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
       
        NSString *message = config[@"easterEggMessage"];
        NSString *title = config[@"easterEggTitle"];
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"dismiss" otherButtonTitles: nil];
        
        [errorAlert show];
        
    }];
    
    
}


@end
