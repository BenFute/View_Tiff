//
//  VideoModel.m
//  viewTiff
//
//  Created by Ben Larrison on 11/8/22.
//

#import "VideoModel.h"

@implementation VideoModel

-   (instancetype)          initWithFileURL:(NSURL *)url
{
    self                    =           [super initWithFileURL:url];
    
    _fps                    =           30.0;
    _numSeconds             =           1.0;
    
    _video                  =           CFArrayCreateMutable(NULL, sizeof(CGImageRef) * self.fps * self.numSeconds, &kCFTypeArrayCallBacks);
    
    //NSLog(@"%f second video allocated.",self.numSeconds);
    
    return self;
}

-   (id)                    contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    //Save the video
    //NSLog(@"Video Save (contentsForType)");
    CFArrayRef              destinationTypes            =       CGImageDestinationCopyTypeIdentifiers();
    
    //TIFF index
    CFStringRef             type                        =       CFArrayGetValueAtIndex(destinationTypes, 3);
    CFDictionaryRef         options                     =       NULL;
    CFStringRef             keys[3];
    CFTypeRef               values[3];
    int    orientation                                  =       kCGImagePropertyOrientationUp;
    keys[0]                                             =       kCGImagePropertyOrientation;
    values[0]                                           =       CFNumberCreate(NULL, kCFNumberIntType, &orientation);
    keys[1]                                             =       kCGImagePropertyHasAlpha;
    values[1]                                           =       kCFBooleanTrue;
    //1.0 specifies lossless compression
    CGFloat                 compression                 =       1.0;
    keys[2]                                             =       kCGImageDestinationLossyCompressionQuality;
    values[2]                                           =       CFNumberCreate(NULL, kCFNumberFloatType, &compression);
    
    options                                             =       CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    _videoSaveData                                      =       CFDataCreateMutable(NULL, 0);
    //NSLog(@"Total video frames to save: %zu",self.totalFrames);
    CGImageDestinationRef   videoDestination            =       CGImageDestinationCreateWithData(self.videoSaveData, type, self.totalFrames, nil);
    
    //NSLog(@"Adding images to video data");
    for(int i = 0; i < self.totalFrames; i++)
    {
        CGImageDestinationAddImage(videoDestination, (CGImageRef)CFArrayGetValueAtIndex(self.video, i), options);
    }
    CGImageDestinationFinalize(videoDestination);
    CFRelease(videoDestination);

    
    return                  (id)self.videoSaveData;
}

-   (void)                  openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    //NSLog(@"Open()");

    //NSFileCoordinator       *fileCoordinator            =       [[NSFileCoordinator     alloc]initWithFilePresenter:nil];
    
    //[self                   performAsynchronousFileAccessUsingBlock:^{
        //[fileCoordinator    coordinateReadingItemAtURL:self.fileURL options:NSFileCoordinatorReadingForUploading error:nil byAccessor:^(NSURL * _Nonnull newURL) {
            //Executes syncrhonously
            //Blocks the current thread until the reader block finishes executing
            [self           readFromURL:self.fileURL error:nil];
            
            //NSLog(@"Call open completion handler from coordinated read from URL.");
            completionHandler(YES);
        //}];
    //}];
    
}

-   (BOOL)                  readFromURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    //NSLog(@"()ReadFromURL %@",url);
    
    NSFileManager           *fileManager                    =       [[NSFileManager         alloc]init];
    _videoOpenData                                          =       CFDataCreateMutable(NULL, 0);
    _videoOpenData                                          =       (__bridge CFMutableDataRef)[fileManager        contentsAtPath:url.path];
    
    [self                   loadFromContents:(__bridge id)self.videoOpenData ofType:@"NSData*" error:nil];
    
    return                  YES;
}

-   (BOOL)                  loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    //NSLog(@"()Load from contents. Type: %@",typeName);
    
    CGImageSourceRef        imageSource                     =       CGImageSourceCreateWithData((__bridge  CFDataRef)contents, NULL);
    
    if(imageSource          ==          NULL)
    {
        NSLog(@"Usage: Create image source with data passed in contents.");
    }
    
    _totalFrames                                            =       CGImageSourceGetCount(imageSource);
    //NSLog(@"Total frames from open: %zu",self.totalFrames);
    
    for(int i = 0; i < self.totalFrames; i++)
    //Copy on write
    {
        CGImageRef          tempImage                       =       CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        CFArrayInsertValueAtIndex(self.video, i, CGImageCreateCopy(tempImage));
        CGImageRelease(tempImage);
    }
    
    if(self.totalFrames > 10){
        _previewImage                                       =       (CGImageRef)CFArrayGetValueAtIndex(self.video, self.totalFrames/2);
    }
    else
    {
        _previewImage                                       =       (CGImageRef)CFArrayGetValueAtIndex(self.video, 0);
    }
    
    CFRelease(imageSource);
    
    //NSLog(@"Load successful");
    return                  YES;
}


-   (void)                  releaseSave
{
    CFRelease(self.videoSaveData);
}

-   (void)                  releaseOpen
{
    //CFRelease(self.videoOpenData);
    free(CFDataGetBytePtr(self.videoOpenData));

}

-   (void)                  releaseFrameData
{
    //NSLog(@"Frame retain count before release: %ld",(long)CFGetRetainCount((CGImageRef)CFArrayGetValueAtIndex(self.video, 0)));
    for(int i = 0; i < CFArrayGetCount(self.video); i++)
    {
        CGImageRelease((CGImageRef)CFArrayGetValueAtIndex(self.video, i));
    }
    //CFArrayRemoveAllValues(self.video);
    
}

@end

