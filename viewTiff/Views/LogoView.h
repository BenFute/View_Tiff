//
//  LogoView.h
//  viewTiff
//
//  Created by Ben Larrison on 11/22/22.
//

#import     <UIKit/UIKit.H>
#import     "ViewUtilities.h"
#import     <CoreText/CoreText.h>


@interface LogoView : UIView

-   (instancetype)  initWithCoder:(NSCoder *)coder;
-   (void)          drawTIFF;
-   (void)          drawRGB;

@end
