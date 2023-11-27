//
//  AudioModel.h
//  viewTiff
//
//  Created by Ben Larrison on 11/20/22.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "../Controllers/DirectoryController.h"


@interface AudioModel : UIDocument

//Video Settings
@property       size_t                  totalFrames;

@property       NSURL                   *audioLocation;
@property       NSString                *audioName;

@property       CFMutableDataRef        audioOpenData;
@property       CFMutableDataRef        audioSaveData;

-   (instancetype)      initWithFileURL:(NSURL *)url;

//Save Audio
-   (id)                contentsForType:(NSString *)typeName error:(NSError **)outError;

-   (BOOL)              loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError;


@end
