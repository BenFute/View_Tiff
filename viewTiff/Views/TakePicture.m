//
//  takePicture.m
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import "TakePicture.h"

@implementation TakePicture

-   (instancetype)initWithCoder:(NSCoder *)coder
{
    self                                                =       [super      initWithCoder:coder];
    
    [self                           drawButton];
    
    UITapGestureRecognizer          *tapRecognizer      =       [[UITapGestureRecognizer        alloc]initWithTarget:self action:@selector(tap)];
    
    [self                           addGestureRecognizer:tapRecognizer];
    
    return self;
}

-   (void)tap
{
    [self.delegate                  didPressButton];
}

-   (void)drawButton
{
    CGContextRef                    ctx                 =       [ViewUtilities                  createBitmapContext:self.bounds.size.width * 2 pixelsHeight:self.bounds.size.height * 2];
    CGContextSetShouldAntialias(ctx, true);
    
    int size        =   11;
    
    
    //CGContextSetStrokeColorWithColor(ctx, [blueColor CGColor]);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(ctx, size);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(size, size, CGBitmapContextGetWidth(ctx) - size*2, CGBitmapContextGetHeight(ctx)- size*2));
    
    
    CGImageRef                      button              =       CGBitmapContextCreateImage(ctx);
    
    [self.layer                     setContents:(__bridge id)(button)];
    
}

@end
