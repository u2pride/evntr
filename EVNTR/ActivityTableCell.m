//
//  ActivityTableCell.m
//  EVNTR
//
//  Created by Alex Ryan on 2/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "ActivityTableCell.h"

@implementation ActivityTableCell

- (void)setActivityContentTextLabel:(UILabel *)activityContentTextLabel {
    
    //custom tasks here..
    _activityContentTextLabel = activityContentTextLabel;
    
}

- (void)setTimestampActivity:(UILabel *)timestampActivity {
    
        //JUST add customaization as a EVN Utility function to get a readable date.
    _timestampActivity = timestampActivity;
}

@end
