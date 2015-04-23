//
//  EVNUtility.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation EVNUtility


CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
    CGImageRef retVal = NULL;
    
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height,
                                                          8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef sourceImage = [image CGImage];
    CGImageRef imageWithAlpha = sourceImage;
    //add alpha channel for images that don't have one (ie GIF, JPEG, etc...)
    //this however has a computational cost
    if (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone) {
        imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
    }
    
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    CGImageRelease(mask);
    
    //release imageWithAlpha if it was created by CopyImageAndAddAlphaChannel
    if (sourceImage != imageWithAlpha) {
        CGImageRelease(imageWithAlpha);
    }
    
    UIImage* retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    
    return retImage;
}





//---



+ (void)maskImage:(UIImage *)image withMask:(UIImage *)maskImage withCompletion:(void (^)(UIImage *))completionBlock {
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        CGImageRef maskRef = maskImage.CGImage;
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), NULL, false);
        
        CGImageRef sourceImage = [image CGImage];
        CGImageRef imageWithAlpha = sourceImage;
        //add alpha channel for images that don't have one (ie GIF, JPEG, etc...)
        //this however has a computational cost
        if (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone) {
            imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
        }
        
        CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
        CGImageRelease(mask);
        
        //release imageWithAlpha if it was created by CopyImageAndAddAlphaChannel
        if (sourceImage != imageWithAlpha) {
            CGImageRelease(imageWithAlpha);
        }
        
        UIImage* retImage = [UIImage imageWithCGImage:masked];
        CGImageRelease(masked);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(retImage);
        });
        
        
        /*
        CGImageRef maskRef = maskImage.CGImage;
        
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), NULL, false);
        
        CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
        CGImageRelease(mask);
        UIImage *finalImage = [UIImage imageWithCGImage:masked];
        CGImageRelease(masked);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(finalImage);
        });
        
        */
        
    });
     
    
    
}

+ (void)maskImage:(UIImage *)image withMask:(UIImage *)maskImage withCompletionBlock:(void (^)(CGImageRef *))completionBlock {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    //UIImage *finalImage = [UIImage imageWithCGImage:masked];
    
    completionBlock(&masked);
    
}


+ (NSString *)getUTCFormateDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

/*
+ (NSDate *)getUTCDateFromString:(NSString *)utcDateString {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"LLL d, yyyy - HH:mm:ss zzz";
    NSDate *utc = [fmt dateFromString:@"June 14, 2012 - 01:00:00 UTC"];
    fmt.timeZone = [NSTimeZone systemTimeZone];
    NSString *local = [fmt stringFromDate:utc];
    NSLog(@"%@", local);
    
    
}
 */



@end
