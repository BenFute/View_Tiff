//
//  ViewUtilities.h
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//



#import         <UIKit/UIKit.h>

@interface ViewUtilities : NSObject

+   (CGContextRef)createBitmapContext:(CGFloat)width pixelsHeight:(CGFloat)height;

@end
