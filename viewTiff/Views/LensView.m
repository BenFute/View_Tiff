//
//  LensView.m
//  viewTiff
//
//  Created by Ben Larrison on 11/5/22.
//

#import "LensView.h"

@implementation LensView

-   (instancetype)initWithLensID:(CameraType)cameraType frame:(CGRect)viewFrame
{
    self                            =               [super                      init];
    
    [self               setFrame:viewFrame];
    //NSLog(@"Camera ID: %d",cameraType);
    _lensID                         =               cameraType;
    _tapRecognizer                  =               [[UITapGestureRecognizer    alloc]initWithTarget:self action:@selector(tapAction)];
    
    [self               setUserInteractionEnabled:YES];
    [self               addGestureRecognizer:self.tapRecognizer];
    
        
    if(cameraType                   ==              kDeviceFrontWideAngleCamera)    [self   drawWide];
    else if(cameraType              ==              kDeviceUltraWide)               [self   drawUltraWide];
    else if(cameraType              ==              kDeviceTelephotoCamera)         [self   drawTele];
    else if(cameraType              ==              kDeviceDualCamera)              [self   drawDual];
    else if(cameraType              ==              kDeviceDualWideCamera)          [self   drawDualWide];
    else if(cameraType              ==              kDeviceTripleCamera)            [self   drawTriple];
    else if(cameraType              ==              kDeviceLiDarDepth)              [self   drawLiDarDepth];
    else if(cameraType              ==              kDeviceTrueDepthCamera)         [self   drawTrueDepth];
    else if(cameraType              ==              kDeviceBackWideAngle)           [self   drawBackWide];
        
    return              self;
}

-   (void)      tapAction
{
    [self.delegate      didTapLens:self.lensID];
}

-   (void)      drawWide
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    
    CGContextFillRect(ctx, CGRectMake((5+ border + 20/2)*2, (verticalSpacing + 20)*1.5, 40*2, 20*2));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border)*2, (verticalSpacing + 20)*1.5, 20*2, 20*2));
    
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border + 40)*2, (verticalSpacing + 20)*1.5, 20*2, 20*2));

    
    
    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border + 35)*2, (verticalSpacing + 20 + 10)*1.5, 4*2, 4*2));

    
  
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(15,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Front Wide");
    

    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    

    
    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    CGImageRef          wideLens    =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)wideLens];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(wideLens);
}

-   (void)  drawUltraWide
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    //Right Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 -4, verticalSpacing + curveSize/2 +0 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21, verticalSpacing + curveSize/2 + 0, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.20);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 + 10, verticalSpacing + curveSize/2 + 0 + 10, curveSize * 0.35, curveSize * 0.35));
    //Right Lens
    
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(22,0, CGBitmapContextGetWidth(ctx) - 20, CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("UltraWide");
    
   
    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    

    
    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    
    CGImageRef          ultraWide   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)ultraWide];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(ultraWide);
    
}

-   (void)drawTele
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    
    //Top left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 +35 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 + 35, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.17);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 +35 + 10, curveSize * 0.35, curveSize * 0.35));
    //Top left Lens
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(22,0, CGBitmapContextGetWidth(ctx) - 20, CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Telephoto");
    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    

    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    //CGContextFillPath(ctx);
    
    CGImageRef          telephoto   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)telephoto];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(telephoto);
    
}

-   (void)drawBackWide
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3 * 2;
    CGFloat     verticalSpacing     =       ((viewSize.height - (viewSize.width - border))/2);
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    
    //Lower left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 80 -4, verticalSpacing + curveSize/2 - 27 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 80, verticalSpacing + curveSize/2 - 27, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.11);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 80 + 10, verticalSpacing + curveSize/2 - 27 + 10, curveSize * 0.35, curveSize * 0.35));
    //Lower left Lens


    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(15,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Back Wide");

    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);

    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    
    CGImageRef          DualLens   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)DualLens];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(DualLens);
    
}
-   (void)drawDual
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    //Top left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 +35 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 + 35, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.17);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 +35 + 10, curveSize * 0.35, curveSize * 0.35));
    //Top left Lens
    
    
    //Lower left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 - 27 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 - 27, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.11);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 - 27 + 10, curveSize * 0.35, curveSize * 0.35));
    //Lower left Lens

    
    
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(45,0, CGBitmapContextGetWidth(ctx) - 20, CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Dual");
 
    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    

    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    
    CGImageRef          DualLens   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)DualLens];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(DualLens);
    
}

-   (void) drawDualWide
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    
    //Lower left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 - 27 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 - 27, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.11);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 - 27 + 10, curveSize * 0.35, curveSize * 0.35));
    //Lower left Lens

    //Right Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 -4, verticalSpacing + curveSize/2 +0 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21, verticalSpacing + curveSize/2 + 0, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.20);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 + 10, verticalSpacing + curveSize/2 + 0 + 10, curveSize * 0.35, curveSize * 0.35));
    //Right Lens
    
    
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(15,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Dual Wide");

    
    
    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    
    
    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    CGImageRef          dualWide   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)dualWide];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(dualWide);
    
}

-   (void)drawTriple
{
    //73 and 130 are the iphone 14 pro max scroll view dimensions
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);
    
    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    
    
    //Lower left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 - 27 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 - 27, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.11);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 - 27 + 10, curveSize * 0.35, curveSize * 0.35));
    //Lower left Lens

    
    
    //Top left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 +35 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 + 35, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.17);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 +35 + 10, curveSize * 0.35, curveSize * 0.35));
    //Top left Lens
    
    //Right Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 -4, verticalSpacing + curveSize/2 +0 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21, verticalSpacing + curveSize/2 + 0, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 0.20);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 21 + 10, verticalSpacing + curveSize/2 + 0 + 10, curveSize * 0.35, curveSize * 0.35));
    //Right Lens
    
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(44,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("Triple");

    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    
    CGColorSpaceRelease(rgbColorSpace);
    

    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    CGImageRef          tripleLens   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)tripleLens];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(tripleLens);
    
}
-   (void)drawLiDarDepth
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + curveSize/2, viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing, curveSize, curveSize));
    //lower right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing, curveSize, curveSize));
    //Top right circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border + viewSize.width - border*2 - curveSize, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));
    //Top left circle
    CGContextFillEllipseInRect(ctx, CGRectMake(border, verticalSpacing + viewSize.width-border*2 - curveSize, curveSize, curveSize));

    //Top Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing + viewSize.width-border*2 - curveSize, viewSize.width - border*2 - curveSize, curveSize));
    
    
    //Bottom rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2, verticalSpacing, viewSize.width - border*2 - curveSize, curveSize));
    
    //Right Rect
    CGContextFillRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Left Rect
    CGContextFillRect(ctx, CGRectMake(border, verticalSpacing + curveSize/2, curveSize/2, viewSize.width - border*2 - curveSize));
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    
    
    //Lower left Lens
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.95, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 -4, verticalSpacing + curveSize/2 - 27 - 4, curveSize * 0.7, curveSize * 0.7));
    
    //Main lens
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84, verticalSpacing + curveSize/2 - 27, curveSize * 0.6, curveSize * 0.6));
    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.11);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 84 + 10, verticalSpacing + curveSize/2 - 27 + 10, curveSize * 0.35, curveSize * 0.35));
    //Lower left Lens
    //Lidar

    
    //Main lens

    
    //Lens reflection
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 13 + 7 - 16 + 5, verticalSpacing + curveSize/2 + 7 - 33, curveSize * 0.35, curveSize * 0.35));
    
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 0.20);
    CGContextFillEllipseInRect(ctx, CGRectMake(border + curveSize/2 + viewSize.width - border*2 - curveSize - 13 + 7 - 14 + 5 -1, verticalSpacing + curveSize/2 + 7 - 33 + 1, curveSize * 0.30, curveSize * 0.30));
    
    
    
    
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(45,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("LiDar");
    
    
    
    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);

    
    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    CGImageRef          liDar   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)liDar];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(liDar);
    
}
-   (void)drawTrueDepth
{
    CGSize              viewSize    =               CGSizeMake(73*2, 130*2);

    CGContextRef        ctx         =               [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    

    //Draw rounded square
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1.0);
    CGContextSetRGBStrokeColor(ctx, 0.9, 0.9, 0.9, 1.0);
    
    int border                      =       3;
    CGFloat     verticalSpacing     =       (viewSize.height - (viewSize.width - border))/2;
    CGFloat     curveSize           =       42 * 2;
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);

    CGContextFillRect(ctx, CGRectMake((5+ border + 20/2)*2, (verticalSpacing + 20)*1.5, 40*2, 20*2));
    //Lower left circle
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border)*2, (verticalSpacing + 20)*1.5, 20*2, 20*2));
    
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border + 40)*2, (verticalSpacing + 20)*1.5, 20*2, 20*2));

    
    
    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake((5+ border + 35)*2, (verticalSpacing + 20 + 10)*1.5, 4*2, 4*2));

    
  
    //Add Lens name
    CGContextMoveToPoint(ctx, 0, 0);

    CGContextTranslateCTM(ctx, 0, -1*(viewSize.height - 50));
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    //Bounds the area where you will be drawing text
    CGMutablePathRef    path        =       CGPathCreateMutable();
    
    CGRect              bounds      =       CGRectMake(10,0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx));
    CGPathAddRect(path, NULL, bounds);
    
    CFStringRef         textString  =       CFSTR("TrueDepth");
    

    
    //Text color
    CGColorSpaceRef     rgbColorSpace               =       CGColorSpaceCreateDeviceRGB();
    CGFloat             components[]                =       {0.0,0.0,0.0,1.0};
    CGColorRef          black                       =       CGColorCreate(rgbColorSpace, components);
    
    CGFloat             *fontSize                   =       malloc(sizeof(CGFloat));
    *fontSize                                       =       24;
    
    CTFontRef           font                        =       CTFontCreateWithName(CFSTR("Helvetica"), 24, nil);
    
    CFStringRef         keys[]                      =       { kCTFontAttributeName , kCTForegroundColorAttributeName};
    CFTypeRef           values[]                    =       { font, black};
    
    CFDictionaryRef     attributes                  =       CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef   attrString                 =       CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    

    
    CGColorSpaceRelease(rgbColorSpace);
    
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, black);
    
    CTFramesetterRef    framesetter                 =       CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    CTFrameRef          frame                       =       CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    
    
    
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    
    
    
    //Fill square
    //CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    CGImageRef          trueDepth   =               CGBitmapContextCreateImage(ctx);
    
    [self.layer         setContents:(__bridge id)trueDepth];
    void *contentImageData          =               CGBitmapContextGetData(ctx);
    free(contentImageData);
    CGContextRelease(ctx);
    CGImageRelease(trueDepth);
    
}




@end
