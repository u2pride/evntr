//
//  SearchHeaderView.m
//  EVNTR
//
//  Created by Alex Ryan on 3/13/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "SearchHeaderView.h"
#import "UIColor+EVNColors.h"

@interface SearchHeaderView ()



@end


@implementation SearchHeaderView

- (id)init {
    
    return [self initWithFrame:CGRectZero];
    
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setupLabels];
        [self setupConstraints];
        
    }
    return self;
}

- (void)updateConstraints {
    
    [super updateConstraints];
    
}

- (void) setupLabels {
    
    self.eventLabel = [[UILabel alloc] init];
    self.eventLabel.text = @"EVENTS";
    self.eventLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    self.eventLabel.textColor = [UIColor orangeColor];
    self.eventLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.eventLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.eventLabel sizeToFit];
    
    self.peopleLabel = [[UILabel alloc] init];
    self.peopleLabel.text = @"PEOPLE";
    self.peopleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    self.peopleLabel.textColor = [UIColor blackColor];
    self.peopleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.peopleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.peopleLabel sizeToFit];
    
    /*
    self.separator = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 1.0, 20.0)];
    self.separator.font = [UIFont fontWithName:@"Lato-Regular" size:20];
    self.separator.text = @"";
    self.separator.backgroundColor = [UIColor blackColor];
    
    [self.separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[self.separator sizeToFit];
    */
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(self.center.x - 2, 10.0f, 0.5f, self.frame.size.height - 20);
    separator.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    CALayer *bottomLayer = [CALayer layer];
    bottomLayer.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 1.0f);
    bottomLayer.backgroundColor = [UIColor grayColor].CGColor;
    
    
    
    [self.layer addSublayer:separator];
    [self.layer addSublayer:bottomLayer];
    
    [self addSubview:self.eventLabel];
    [self addSubview:self.peopleLabel];
    
}

- (void)setupConstraints {
    
    
    //Distribute Labels Horizontally
    NSDictionary *viewsDictionary = @{@"EVENTS":self.eventLabel, @"PEOPLE":self.peopleLabel};
    
    NSArray *centeringConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[EVENTS(PEOPLE)]-10-[PEOPLE]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];
    
    [self addConstraints:centeringConstraint];
    

    //Center the Views Vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.eventLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.peopleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    /*
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.separator
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.separator
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
     */
    

    /*
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.eventLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:80]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.peopleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:-70]];
    // Height constraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.5
                                                      constant:0]];
    
    // Center horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centerView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
     
     */
}


@end
