//
//  VideoModel.h
//  viewTiff
//
//  Created by Ben Larrison on 11/8/22.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "PhotoModel.h"
#import "../Controllers/DirectoryController.h"


@interface VideoModel : UIDocument

//Video Settings
@property       CGFloat                 fps;
@property       CGFloat                 numSeconds;

//Array of CGImageRef frames
@property       CFMutableArrayRef       video;
//Total frames to save into the video directory;
@property       size_t                  totalFrames;

//Preview image
@property       CGImageRef              previewImage;

//Document information
@property       NSURL                   *videoLocation;
@property       NSString                *videoName;

//Data
@property       CFMutableDataRef        videoOpenData;
@property       CFMutableDataRef        videoSaveData;

-   (instancetype)      initWithFileURL:(NSURL *)url;

//Save video
-   (id)                contentsForType:(NSString *)typeName error:(NSError **)outError;

//Open video
-   (void)              openWithCompletionHandler:(void (^)(BOOL))completionHandler;
-   (BOOL)              loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError;
-   (BOOL)              readFromURL:(NSURL *)url error:(NSError **)outError;


//Release Data
-   (void)              releaseSave;
-   (void)              releaseOpen;
-   (void)              releaseFrameData;

@end
