//
//  Document.m
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import "PhotoModel.h"

@implementation PhotoModel

-   (instancetype)  initWithFileURL:(NSURL *)url
{
    self                                =       [super      initWithFileURL:url];
    
    return              self;
}

- (id)contentsForType:(NSString*)typeName error:(NSError **)errorPtr {
    // Encode your document with an instance of NSData or NSFileWrapper
    // NSLog(@"Contents loading");
    
    CFArrayRef      destinationType     =       CGImageDestinationCopyTypeIdentifiers();
    CFStringRef     type                =       CFArrayGetValueAtIndex(destinationType, 3);
    
    CFDictionaryRef options             =       NULL;
    CFStringRef     keys[3];
    CFTypeRef       values[3];
    int             orientation         =       kCGImagePropertyOrientationRight;
    keys[0]                             =       kCGImagePropertyOrientation;
    values[0]                           =       CFNumberCreate(0, kCFNumberIntType, &orientation);
    keys[1]                             =       kCGImagePropertyHasAlpha;
    values[1]                           =       kCFBooleanTrue;
    float           compression         =       1.0;
    keys[2]                             =       kCGImageDestinationLossyCompressionQuality;
    values[2]                           =       CFNumberCreate(0, kCFNumberFloatType, &compression);
    
    options                             =       CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    photoSaveData                       =                   CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef   photoDestination        =       CGImageDestinationCreateWithData(photoSaveData, type, 1, NULL);
    
    CGImageDestinationAddImage(photoDestination, self.photo, options);
    CGImageDestinationFinalize(photoDestination);
    
    CFRelease(photoDestination);
    return (__bridge NSData *)photoSaveData;
}
    
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)errorPtr {
    // Load your document from contents
    // NSLog(@"Load from contents");
    //photoOpenData                       =        (__bridge CFMutableDataRef)contents;
    
    //CGImageSource can load with URL
    CGImageSourceRef        imageSource =       CGImageSourceCreateWithData((__bridge CFMutableDataRef)contents, NULL);
    
    if(imageSource                      ==      NULL){
        NSLog(@"Usage: image source with (CFDataRef)contents");
    }
    
    //Copy on write
    CGImageRef              tempSavedImage  =       CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    self.photo                          =           CGImageCreateCopy(tempSavedImage);
    CGImageRelease(tempSavedImage);
    CFRelease(imageSource);

    return YES;
}

    

-   (void)      releaseSave
{
    //Release frame data after its saved to document URL
    CFRelease(photoSaveData);
}

-   (void)      releaseOpen
{
    //CFRelease(photoOpenData);
    //CGImageRelease(self.photo);

}
@end
