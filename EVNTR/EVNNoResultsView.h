//
//  EVNNoResultsView.h
//  EVNTR
//
//  Created by Alex Ryan on 3/19/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVNButton.h"

@interface EVNNoResultsView : UIView

@property (nonatomic, strong) NSString *headerText;
@property (nonatomic, strong) NSString *subHeaderText;
@property (nonatomic, strong) EVNButton *actionButton;

@end