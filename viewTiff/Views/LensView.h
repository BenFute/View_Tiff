//
//  LensView.h
//  viewTiff
//
//  Created by Ben Larrison on 11/5/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewUtilities.h"
#import <CoreText/CoreText.h>


static          int         kDevicePositionFront        =       0;
static          int         kDevicePositionBack         =       1;
typedef         int         CameraPosition;

static          int         kDeviceFrontWideAngleCamera =       0;
static          int         kDeviceUltraWide            =       1;
static          int         kDeviceTelephotoCamera      =       2;
static          int         kDeviceDualCamera           =       3;
static          int         kDeviceDualWideCamera       =       4;
static          int         kDeviceTripleCamera         =       5;
static          int         kDeviceLiDarDepth           =       6;
static          int         kDeviceTrueDepthCamera      =       7;
static          int         kDeviceBackWideAngle        =       8;


typedef         int         CameraType;


@protocol LensViewDelegate

-   (void)didTapLens:(int)lensNumber;

@end

@interface LensView : UIImageView
{
    CGImageRef                          wide;
    CGImageRef                          ultraWide;
    CGImageRef                          Tele;
    CGImageRef                          Dual;
    CGImageRef                          DualWide;
    CGImageRef                          Triple;
    CGImageRef                          LiDARDepth;
    CGImageRef                          TrueDepth;
}

@property   id  <LensViewDelegate>          delegate;
@property   UITapGestureRecognizer          *tapRecognizer;


@property   int                         lensID;

-   (instancetype)initWithLensID:(CameraType)cameraType frame:(CGRect)viewFrame;
-   (void)tapAction;


-   (void)drawWide;
-   (void)drawUltraWide;
-   (void)drawTele;
-   (void)drawDual;
-   (void)drawDualWide;
-   (void)drawTriple;
-   (void)drawLiDarDepth;
-   (void)drawTrueDepth;
-   (void)drawBackWide;

@end
