//
//  SignUpTabVC.m
//  EVNTR
//
//  Created by Alex Ryan on 3/20/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "SignUpTabVC.h"

@interface SignUpTabVC ()

@end

@implementation SignUpTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign Up";
    
    self.navigationController.navigationBar.titleTextAttributes = [EVNUtility navigationFontAttributes];

}


@end
