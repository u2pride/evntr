//
//  EVNUtility.m
//  EVNTR
//
//  Created by Alex Ryan on 1/29/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNUtility.h"
#import "EVNConstants.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation EVNUtility


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
        
    });
    
}


CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
    CGImageRef retVal = NULL;
    
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}


#pragma mark - Global Method

+ (void) setupNavigationBarWithController:(UINavigationController *)navController andItem:(UINavigationItem *)navItem {
    
    NSDictionary *navFontDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    navController.navigationBar.titleTextAttributes = navFontDictionary;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [navItem setBackBarButtonItem:backButtonItem];
    navController.view.backgroundColor = [UIColor whiteColor];
    
}

+ (NSDictionary *) navigationFontAttributes {

    return [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:EVNFontRegular size:kFontSize], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];

}






@end
