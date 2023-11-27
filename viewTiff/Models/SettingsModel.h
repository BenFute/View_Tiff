//
//  SettingsModel.h
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//

#import <UIKit/UIKit.h>
#import "../Controllers/DirectoryController.h"

@interface SettingsModel :  UIDocument

@property   NSString        *saveString;

@property   BOOL            longVideoEnabled;
@property   BOOL            audioEnabled;
@property   BOOL            whiteOutPhotoSaveEnabled;


-   (instancetype)          initWithFileURL:(NSURL *)url;

-   (BOOL)                  loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError;


-   (void)                  prepareSettings;
@end
