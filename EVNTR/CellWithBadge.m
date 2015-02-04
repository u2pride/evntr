//
//  CellWithBadge.m
//  EVNTR
//
//  Created by Alex Ryan on 2/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CellWithBadge.h"

@implementation CellWithBadge

@synthesize badgeLabel;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        badgeLabel.text = @"LD";
    }
    return self;
}

@end
