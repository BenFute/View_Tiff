//
//  LogoModel.h
//  viewTiff
//
//  Created by Ben Larrison on 11/22/22.
//

#import <UIKit/UIKit.h>

@interface LogoModel : UIDocument

@property       CGImageRef      photo;

-   (instancetype)      initWithFileURL:(NSURL *)URL;
-   (id)                contentsForType:(NSString *)typeName error:(NSError **)outError;

@end
