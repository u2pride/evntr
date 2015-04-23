//
//  EVNUtility.h
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface EVNUtility : NSObject

+ (void)maskImage:(UIImage *)image withMask:(UIImage *)maskImage withCompletion:(void (^)(UIImage *))completionBlock;
+ (NSString *)getUTCFormateDate:(NSDate *)localDate;


@end
