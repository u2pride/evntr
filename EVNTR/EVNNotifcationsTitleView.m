//
//  EVNNotifcationsTitleView.m
//  EVNTR
//
//  Created by Alex Ryan on 5/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNNotifcationsTitleView.h"

@implementation EVNNotifcationsTitleView


- (void) setTitleText:(NSString *)titleText {
    
    [self setNeedsDisplay];
    
    _titleText = titleText;
}

- (void)drawRect:(CGRect)rect {
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Text Drawing
    CGRect textRect = CGRectMake(1, 9, 125, 28);
    {
        NSString *textContent;
        
        if (self.titleText) {
            textContent = self.titleText;
        } else {
            textContent = @"Notifications";
        }
        
        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Lato-Regular" size: 18], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: textStyle, NSLigatureAttributeName: @0};
        
        CGFloat textTextHeight = [textContent boundingRectWithSize: CGSizeMake(textRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height;
        CGContextSaveGState(context);
        CGContextClipToRect(context, textRect);
        [textContent drawInRect: CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes: textFontAttributes];
        CGContextRestoreGState(context);
    }
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(13.5, 36.5)];
    [bezierPath addLineToPoint: CGPointMake(81.44, 36.5)];
    [bezierPath addLineToPoint: CGPointMake(136.5, 36.5)];
    [UIColor.whiteColor setStroke];
    bezierPath.lineWidth = 1.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(120.5, 20.5)];
    [bezier2Path addLineToPoint: CGPointMake(127.42, 30.5)];
    [bezier2Path addLineToPoint: CGPointMake(135.5, 20.5)];
    [UIColor.whiteColor setStroke];
    bezier2Path.lineWidth = 1.5;
    [bezier2Path stroke];

}


@end
