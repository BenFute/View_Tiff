//
//  SettingsModel.m
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//

#import <Foundation/Foundation.h>
#import "SettingsModel.h"

@implementation SettingsModel

-   (instancetype)              initWithFileURL:(NSURL *)url
{
    self                            =               [super initWithFileURL:url];
    
    return          self;
}

-   (id)                        contentsForType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError
{
    
    NSData                      *contents                       =       [self.saveString        dataUsingEncoding:NSUTF8StringEncoding];
    
    return                      contents;
}

-   (BOOL)                      loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    
    self.saveString                                             =       [[NSString              alloc]initWithData:contents encoding:NSUTF8StringEncoding];
    
    //NSLog(@"Settings opened: %@",self.saveString);
    if([self.saveString     characterAtIndex:0] == '1')
    {
        self.longVideoEnabled               =   YES;
    }
    else{
        self.longVideoEnabled               =   NO;
    }
    
    if([self.saveString     characterAtIndex:2] == '1')
    {
        self.audioEnabled                   =   YES;
    }
    else{
        self.audioEnabled                   =   NO;
    }
    
    if([self.saveString     characterAtIndex:4] == '1')
    {
        self.whiteOutPhotoSaveEnabled       =       YES;
    }
    else{
        self.whiteOutPhotoSaveEnabled       =       NO;
    }
    
    [self                   prepareSettings];
    
    return          YES;
    
}


-   (void)                  prepareSettings
{
    
    int                                 longVideoEnabled            =   0;
    int                                 audioEnabled                =   0;
    int                                 whiteOutPhotoSaveEnabled    =   0;
    
    if(self.longVideoEnabled)           longVideoEnabled            =   1;
    if(self.audioEnabled)               audioEnabled                =   1;
    if(self.whiteOutPhotoSaveEnabled)   whiteOutPhotoSaveEnabled    =   1;
    
    self.saveString                         =       [NSString       stringWithFormat:@"%d,%d,%d",longVideoEnabled,audioEnabled,whiteOutPhotoSaveEnabled];
    
    //NSLog(@"Settings: %@",self.saveString);
}
@end
