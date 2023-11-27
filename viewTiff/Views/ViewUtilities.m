//
//  ViewUtilities.m
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//



#import "ViewUtilities.h"

@implementation ViewUtilities

+   (CGContextRef)createBitmapContext:(CGFloat)width pixelsHeight:(CGFloat)height
{
    CGContextRef                                context;
    CGColorSpaceRef                             colorSpace;
    void    *                                   bitmapData;
    int                                         bitmapByteCount;
    int                                         bitmapBytesPerRow;
    
    bitmapBytesPerRow                                               =           (width * 4);
    bitmapByteCount                                                 =           (bitmapBytesPerRow          *       height);
    
    colorSpace                                                      =           CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    bitmapData                                                      =           malloc(bitmapByteCount * sizeof(uint8_t));
    
    context                                                         =           CGBitmapContextCreate(bitmapData, width, height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGColorSpaceRelease(colorSpace);
    
    return              context;
    
}

@end
