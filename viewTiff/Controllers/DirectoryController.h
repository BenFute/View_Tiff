//
//  DirectoryController.h
//  viewTiff
//
//  Created by Ben Larrison on 11/2/22.
//

#import <UIKit/UIkit.h>

@interface DirectoryController : NSObject

+   (NSURL *)localDocumentsDirectoryURL;
+   (NSURL *)photosDirectoryURL;
+   (NSURL *)videoDirectoryURL;

+   (NSString *)createNextPhotoName;

+   (int)       createNextVideoDir;
+   (NSString *)createNextVideoName:(int)videoDir;
+   (NSString *)createVideoName:(int)videoNum;

+   (void)          createDir:(int)dirNum inDir:(NSURL *)dir;

+   (NSURL *)       videoDir:(int)dirNum;
+   (int)           nextVideoNum:(int)videoDir;
+   (NSURL *)       videoURL:(int)dirNum videoNum:(int)videoNum;
+   (void)          deleteVideoDir:(int)dirNum;
+   (void)          createVideoDir:(int)videoNum;
+   (NSURL *)       createItemURLInDir:(NSURL *)Directory       withName:(NSString *)itemName;
+   (void)          listDirContents:(NSString *)dirName;
+   (void)          listVideoDirContents:(NSString *)dirName;
+   (int)           getNumItemsInDir:(NSURL*)dir;

+   (NSURL *)       getPreviewPhoto:(int)videoDir;
+   (int)           getPreviewPhotoNumber:(int)videoDir;
+   (void)          previewPhotoArrayWithVideoDirNums:(int**)videoNums photoNum:(int**)photoNums;

+   (NSString *)getItemName:(NSURL*)itemURL;
+   (int)getPhotoNumber:(NSURL*)itemURL;

+   (int)getVideoDirectoryCount;
+   (int)getNumVideosInVideoDirectory:(int)videoDir;
+   (int)getNumPhotos;
@end
