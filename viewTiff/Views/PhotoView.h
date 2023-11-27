//
//  PhotoView.h
//  viewTiff
//
//  Created by Ben Larrison on 11/3/22.
//

#import <UIKit/UIkit.h>
#import "../Models/PhotoModel.h"

@protocol PhotoViewDelegate
-   (void)didTapPhoto:(NSNumber *)photoNumber;
@end

@interface PhotoView : UIImageView

@property       id <PhotoViewDelegate>          delegate;
@property       UITapGestureRecognizer          *tapRecognizer;

@property       int                             photoID;

-   (instancetype)init;
-   (void)tapAction;

@end
