//
//  takePicture.h
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import <UIKit/UIKit.h>
#import "ViewUtilities.h"

@protocol ButtonViewDelegate

-   (void)didPressButton;

@end

@interface TakePicture :    UIView

@property       id <ButtonViewDelegate> delegate;

-   (instancetype)initWithCoder:(NSCoder *)coder;
-   (void)tap;
-   (void)drawButton;


@end
