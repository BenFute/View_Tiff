//
//  EffectsView.h
//  viewTiff
//
//  Created by Ben Larrison on 11/7/22.
//

#import <UIKit/UIKit.h>
#import "ViewUtilities.h"


static          int         kEffectEyes             =       0;
static          int         kEffectColorWhite       =       1;
static          int         kEffectSilo             =       2;
static          int         kEffectVImage           =       3;
typedef         int         EffectType;

@protocol EffectViewDelegate

-   (void)didTapEffect:(EffectType)effectID;

@end

@interface EffectsView : UIView
{
    CGImageRef          mainPhoto;
}

@property       id      <EffectViewDelegate>                delegate;
@property       UITapGestureRecognizer                      *tapRecognizer;
@property       EffectType                                  effectID;
-   (instancetype)initWithEffectID:(EffectType)effect       frame:(CGRect)viewFrame;
-   (void)tapAction;

-   (void)initMainPhoto;

-   (void)drawEyeEffect;
-   (void)drawWhiteEffect;
-   (void)drawSiloEffect;
-   (void)drawEffectVImage;
@end
