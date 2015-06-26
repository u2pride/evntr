//
//  EVNInviteContainerHeaderView.m
//  EVNTR
//
//  Created by Alex Ryan on 6/25/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNInviteContainerHeaderView.h"
#import "UIColor+EVNColors.h"

@implementation EVNInviteContainerHeaderView

#pragma mark - Initialization

- (id) init {
    return [self initWithFrame:CGRectZero];
}

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupButtons];
        [self setupConstraints];
    }
    
    return self;
    
}

#pragma mark - Layout

- (void) updateConstraints {
    
    [super updateConstraints];
    
}


#pragma mark - Custom Getters

- (CAShapeLayer *) lineUnderContacts {
    
    if (!_lineUnderContacts) {
        
        _lineUnderContacts = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        
        float yvalue = self.frame.size.height;
        //_contactsButton.frame.origin.y + _contactsButton.frame.size.height + 10;
        float startx = _contactsButton.frame.origin.x;
        float finalx = startx + _contactsButton.frame.size.width;
        
        [linePath moveToPoint:CGPointMake(startx, yvalue)];
        [linePath addLineToPoint:CGPointMake(finalx, yvalue)];
        _lineUnderContacts.lineWidth = 5.0;
        _lineUnderContacts.path = linePath.CGPath;
        _lineUnderContacts.lineCap = kCALineCapRound;
        _lineUnderContacts.fillColor = [UIColor orangeThemeColor].CGColor;
        _lineUnderContacts.strokeColor = [UIColor orangeThemeColor].CGColor;
        
        [[self layer] addSublayer:_lineUnderContacts];
        
    }
    
    return _lineUnderContacts;
    
}

- (CAShapeLayer *) lineUnderFacebook {
    
    if (!_lineUnderFacebook) {
        
        _lineUnderFacebook = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        
        float yvalue = self.frame.origin.y + self.frame.size.height;
        //_facebookButton.frame.origin.y + _facebookButton.frame.size.height + 10;
        float startx = _facebookButton.frame.origin.x;
        float finalx = startx + _facebookButton.frame.size.width;
        
        [linePath moveToPoint:CGPointMake(startx, yvalue)];
        [linePath addLineToPoint:CGPointMake(finalx, yvalue)];
        _lineUnderFacebook.lineWidth = 5.0;
        _lineUnderFacebook.path = linePath.CGPath;
        _lineUnderFacebook.lineCap = kCALineCapRound;
        _lineUnderFacebook.fillColor = [UIColor orangeThemeColor].CGColor;
        _lineUnderFacebook.strokeColor = [UIColor orangeThemeColor].CGColor;
        
        [[self layer] addSublayer:_lineUnderFacebook];
        
    }
    
    return _lineUnderFacebook;
    
}



- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    [self lineUnderIndex:0];
    
    CAShapeLayer *bottomShadow = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    float yvalue = self.bounds.origin.y + self.bounds.size.height;
    float startx = self.frame.origin.x;
    float finalx = startx + self.frame.size.width;
        
    [linePath moveToPoint:CGPointMake(startx, yvalue)];
    [linePath addLineToPoint:CGPointMake(finalx, yvalue)];
    bottomShadow.lineWidth = 0.5;
    bottomShadow.path = linePath.CGPath;
    bottomShadow.lineCap = kCALineCapRound;
    bottomShadow.fillColor = [UIColor blackColor].CGColor;
    bottomShadow.strokeColor = [UIColor blackColor].CGColor;
    
    [[self layer] addSublayer:bottomShadow];
    
}


#pragma mark - Helper Methods

- (void) setupButtons {
    
    UIImage *facebookImage = [[UIImage imageNamed:@"inviteFacebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _facebookButton = [[UIImageView alloc] initWithImage:facebookImage];
    _facebookButton.userInteractionEnabled = YES;
    
    UIImage *contactsImage = [[UIImage imageNamed:@"inviteContacts"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _contactsButton = [[UIImageView alloc] initWithImage:contactsImage];
    _contactsButton.userInteractionEnabled = YES;
    
    _facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    _contactsButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_facebookButton];
    [self addSubview:_contactsButton];
    
}


- (void) setupConstraints {
    
    //Center the X at 1/3 and 2/3 Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.facebookButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:0.55
                                                      constant:0.0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.45
                                                      constant:0.0]];
    
    
    //Aspect Ratio
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.facebookButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.facebookButton
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contactsButton
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];

    
    
    
    //Center the Views Vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.facebookButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    //Update the Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.facebookButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.7
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contactsButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.7
                                                      constant:0]];
    
}


- (void) lineUnderIndex:(int)index {
    
    if (index == 0) {
        
        self.facebookButton.tintColor = [UIColor orangeThemeColor];
        self.contactsButton.tintColor = [UIColor grayColor];
        
        self.lineUnderFacebook.hidden = NO;
        self.lineUnderContacts.hidden = YES;
        
    } else {
        
        self.facebookButton.tintColor = [UIColor grayColor];
        self.contactsButton.tintColor = [UIColor orangeThemeColor];
        
        self.lineUnderFacebook.hidden = YES;
        self.lineUnderContacts.hidden = NO;
        
    }
    
}


@end
