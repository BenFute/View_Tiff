//
//  LogoModel.m
//  viewTiff
//
//  Created by Ben Larrison on 11/22/22.
//

#import "LogoModel.h"

@implementation LogoModel


-   (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    
    
    CFArrayRef      destinationType     =       CGImageDestinationCopyTypeIdentifiers();
    CFStringRef     type                =       CFArrayGetValueAtIndex(destinationType, 0);
    
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
    
    CFMutableDataRef photoSaveData                       =                   CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef   photoDestination        =       CGImageDestinationCreateWithData(photoSaveData, type, 1, NULL);
    
    CGImageDestinationAddImage(photoDestination, self.photo, options);
    CGImageDestinationFinalize(photoDestination);
    
    CFRelease(photoDestination);
    return (__bridge NSData *)photoSaveData;
}


@end
