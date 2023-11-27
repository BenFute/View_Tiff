//
//  EffectsView.m
//  viewTiff
//
//  Created by Ben Larrison on 11/7/22.
//

#import "EffectsView.h"

@implementation EffectsView

-   (instancetype)initWithEffectID:(EffectType)effect    frame:(CGRect)viewFrame
{
    self                    =               [super                      init];
    
    [self                                   setFrame:viewFrame];
    _effectID               =               effect;
    _tapRecognizer          =               [[UITapGestureRecognizer    alloc]initWithTarget:self action:@selector(tapAction)];
    
    [self           setUserInteractionEnabled:YES];
    [self           addGestureRecognizer:self.tapRecognizer];
    
    [self           initMainPhoto];
    
    if(effect               ==              kEffectEyes)            [self       drawEyeEffect];
    else if(effect          ==              kEffectColorWhite)      [self       drawWhiteEffect];
    else if(effect          ==              kEffectSilo)            [self       drawSiloEffect];
    else if(effect          ==              kEffectVImage)          [self       drawEffectVImage];
    else NSLog(@"Usage: compare effect with every available effect");
    
    return          self;
    
}
-   (void)      tapAction
{
    [self.delegate      didTapEffect:self.effectID];
}

-   (void)      initMainPhoto
{
    NSURL               *mainPhotoURL           =       [[NSBundle      mainBundle]URLForResource:@"Effects" withExtension:@"jpg"];
    CFURLRef            cfMainPhotoURL          =       CFURLCreateWithString(0, (CFStringRef)mainPhotoURL.absoluteString, NULL);
    
    CGImageSourceRef    mainPhotoSource         =       CGImageSourceCreateWithURL(cfMainPhotoURL, NULL);
        
    mainPhoto                                   =       CGImageSourceCreateImageAtIndex(mainPhotoSource, 0, NULL);
    CFRelease(mainPhotoSource);
}

-   (void)drawEyeEffect
{
    //NSLog(@"Draw eye effect");
    CGSize          viewSize            =       self.bounds.size;
    
    CGContextRef    ctx                 =       [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx)), mainPhoto);
    
    uint8_t         *bitmapData         =       CGBitmapContextGetData(ctx);
    
    for(int i = 0; i < CGBitmapContextGetWidth(ctx) * CGBitmapContextGetHeight(ctx) * 4; i = i + 4)
    {
        bitmapData[i]   =   255;    //alpha

        bitmapData[i+1] =   bitmapData[i+3] + 20;
        bitmapData[i+2] =   bitmapData[i+3] + 20;
        bitmapData[i+3] =   bitmapData[i+3] + 50;

    }
    
    
    CGContextRef    blueCTX             =       CGBitmapContextCreate(bitmapData, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx), CGBitmapContextGetBitsPerComponent(ctx), CGBitmapContextGetBytesPerRow(ctx), CGBitmapContextGetColorSpace(ctx), CGBitmapContextGetBitmapInfo(ctx));
    
    CGImageRef      blueImage           =       CGBitmapContextCreateImage(blueCTX);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx)), blueImage);
    
    
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(CGBitmapContextGetWidth(ctx)/3.9, CGBitmapContextGetHeight(ctx)/1.7, CGBitmapContextGetWidth(ctx)/4, CGBitmapContextGetWidth(ctx)/4));
    CGContextFillEllipseInRect(ctx, CGRectMake((CGBitmapContextGetWidth(ctx)/3.9) * 2.1, CGBitmapContextGetHeight(ctx)/1.7, CGBitmapContextGetWidth(ctx)/4, CGBitmapContextGetWidth(ctx)/4));
    CGImageRef          contentImage    =       CGBitmapContextCreateImage(ctx);
    
    
    
    [self.layer     setContents:(__bridge id)contentImage];
    
}

-   (void)drawWhiteEffect
{
    NSURL               *mainPhotoURL           =       [[NSBundle      mainBundle]URLForResource:@"WhiteOut" withExtension:@"jpg"];
    CFURLRef            cfMainPhotoURL          =       CFURLCreateWithString(0, (CFStringRef)mainPhotoURL.absoluteString, NULL);
    
    CGImageSourceRef    mainPhotoSource         =       CGImageSourceCreateWithURL(cfMainPhotoURL, NULL);
        
    CGImageRef whiteOutPhoto                    =       CGImageSourceCreateImageAtIndex(mainPhotoSource, 0, NULL);
    CFRelease(mainPhotoSource);
    
    
    CGSize          viewSize            =       self.bounds.size;
    
    CGContextRef    ctx                 =       [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    [self.layer     setContents:(__bridge id)whiteOutPhoto];
}


-   (void)drawSiloEffect
{
    CGSize          viewSize            =       self.bounds.size;
    
    CGContextRef    ctx                 =       [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx)), mainPhoto);
    
    uint8_t         *bitmapData         =       CGBitmapContextGetData(ctx);
    
    for(int i = 0; i < CGBitmapContextGetWidth(ctx) * CGBitmapContextGetHeight(ctx) * 4; i = i + 4)
    {
        bitmapData[i]   =   255;    //alpha
        bitmapData[i+1] =   0;
        bitmapData[i+2] =   0;
        bitmapData[i+3] =   bitmapData[i+3];
    }
    
    
    CGContextRef    blueCTX             =       CGBitmapContextCreate(bitmapData, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx), CGBitmapContextGetBitsPerComponent(ctx), CGBitmapContextGetBytesPerRow(ctx), CGBitmapContextGetColorSpace(ctx), CGBitmapContextGetBitmapInfo(ctx));
    
    CGImageRef      blueImage           =       CGBitmapContextCreateImage(blueCTX);
    
    [self.layer     setContents:(__bridge id)blueImage];
}

-   (void)drawEffectVImage
{
    NSURL               *mainPhotoURL           =       [[NSBundle      mainBundle]URLForResource:@"Balance" withExtension:@"jpg"];
    CFURLRef            cfMainPhotoURL          =       CFURLCreateWithString(0, (CFStringRef)mainPhotoURL.absoluteString, NULL);
    
    CGImageSourceRef    mainPhotoSource         =       CGImageSourceCreateWithURL(cfMainPhotoURL, NULL);
        
    CGImageRef balancePhoto                     =       CGImageSourceCreateImageAtIndex(mainPhotoSource, 0, NULL);
    CFRelease(mainPhotoSource);
    
    CGSize          viewSize            =       self.bounds.size;
    
    CGContextRef    ctx                 =       [ViewUtilities          createBitmapContext:(int)viewSize.width pixelsHeight:(int)viewSize.height];
    [self.layer     setContents:(__bridge id)balancePhoto];
}

@end
