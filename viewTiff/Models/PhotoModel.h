//
//  Document.h
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import <UIKit/UIKit.h>

@interface PhotoModel : UIDocument <UIActivityItemSource>
{
    CFMutableDataRef            photoOpenData;
    CFMutableDataRef            photoSaveData;
}
@property           NSURL       *photoLocation;
@property           NSString    *photoName;
@property           int         photoID;
@property           CGImageRef  photo;

-   (instancetype)  initWithFileURL:(NSURL *)url;
-   (id)            contentsForType:(NSString *)typeName error:(NSError **)outError;
-   (BOOL)          loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError;

-   (void)          releaseSave;
-   (void)          releaseOpen;

@end
