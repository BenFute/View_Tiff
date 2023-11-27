//
//  LogoView.m
//  viewTiff
//
//  Created by Ben Larrison on 11/22/22.
//

#import <Foundation/Foundation.h>
#import "LogoView.h"
#import "DirectoryController.h"

#import "LogoModel.h"
@implementation LogoView

-   (instancetype)initWithCoder:(NSCoder *)coder
{
    self                =           [super initWithCoder:coder];
    
    
    return  self;
}

-   (void)drawTIFF
{
    
    CGContextRef                ctx             =       [ViewUtilities          createBitmapContext:1024 pixelsHeight:1024];
    
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
    
    //CGContextFillRect(ctx, CGRectMake(0, 0, 100, 100));
    
    CGContextMoveToPoint(ctx, 0, 0);
    
    CGContextTranslateCTM(ctx, 75, -1*(250));
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    CGMutablePathRef            path            =       CGPathCreateMutable();
    
    CGRect                      bounds          =       CGRectMake(0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef                 textString      =       CFSTR("TIFF");
    
    
    
    
    //CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), textString);
    
    CGFloat                     components[]    =       {0.0,0.0,1.0,1.0};
    CGColorRef                  blue            =       CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
    
    CGFloat                     *fontSize        =      malloc(sizeof(CGFloat));
    *fontSize                                   =       100.0;
    
    //CFShow(CTFontManagerCopyAvailableFontFamilyNames());
    
    CTFontRef                   font            =       CTFontCreateWithName(CFSTR("Helvetica"), 400, nil);
    
    CFStringRef                 keys[]          =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef                   values[]        =       { font , blue};
    
    CFDictionaryRef             attributes      =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) /sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    
    
    CFAttributedStringRef       attrString      =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    
    

    
    CTFramesetterRef            framesetter     =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef                  frame           =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    CGContextStrokePath(ctx);

    
    CGImageRef                  TIFF            =       CGBitmapContextCreateImage(ctx);
    
    
    
    
    //[self.layer                 setBackgroundColor:CGColorCreateSRGB(0.5, 0.5, 0.5, 1.0)];
    
    [self.layer                 setContents:(__bridge id)TIFF];
    //[self.layer                 setBackgroundColor:CGColorCreateSRGB(0, 0, 1, 1)];
    
    



//    CGImageDestinationRef       destination     =       CGImageDestinationCreateWithURL(CFURLCreateWithString(0, CFStringCreateWithCString(NULL, tiffLocation.UTF8String, kCFStringEncodingUTF8), nil), CFSTR("public.jpeg"), 1, NULL);
//
//    CGImageDestinationAddImage(destination, TIFF, NULL);
//
//    CGImageDestinationFinalize(destination);
    
    CFArrayRef      destinationType     =       CGImageDestinationCopyTypeIdentifiers();
    //CFShow(destinationType);
    
    void *contentImageData                      =       CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(TIFF);
    
    
    
}

-   (void)      drawRGB
{
    
    CGContextRef                ctx     =       [ViewUtilities          createBitmapContext:1024 pixelsHeight:1024];
//
//    CGFloat                     y       =       350;
//
//    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
//    CGContextFillRect(ctx, CGRectMake(0, y, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
//
//    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
//    CGContextFillRect(ctx, CGRectMake(CGBitmapContextGetWidth(ctx)/3, y, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
//
//    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
//    CGContextFillRect(ctx, CGRectMake(CGBitmapContextGetWidth(ctx)/3*2, y, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
//
//    CGImageRef                  RGB     =       CGBitmapContextCreateImage(ctx);
    
    CGFloat                     x       =       CGBitmapContextGetWidth(ctx)/2 - CGBitmapContextGetWidth(ctx)/6;
    
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(x, CGBitmapContextGetWidth(ctx)/3 * 0, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
    
    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(x, CGBitmapContextGetWidth(ctx)/3 * 1, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextFillRect(ctx, CGRectMake(x, CGBitmapContextGetWidth(ctx)/3 * 2, CGBitmapContextGetWidth(ctx)/3, CGBitmapContextGetWidth(ctx)/3));
    
    CGImageRef                  RGB     =       CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)RGB];
}

@end
