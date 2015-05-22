//
//  PersonCell.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "PersonCell.h"

@implementation PersonCell

- (PFImageView *) profileImage {
    
    if (!_profileImage) {
        _profileImage = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"PersonDefault"]];
    }
    return _profileImage;
}


@end
