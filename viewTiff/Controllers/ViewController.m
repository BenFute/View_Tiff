//
//  ViewController.m
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//



#import "ViewController.h"


void            RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    //NSLog(@"Schedule callback. \n");
    RunLoopSource       *obj                    =       (__bridge RunLoopSource*) info;
    RunLoopContext      *theContext             =       [[RunLoopContext            alloc]initWithSource:obj andLoop:rl];
    ViewController      *sharedVC               =       [obj                        getSharedViewController];
    if(obj.threadID == 0)
    {
        [sharedVC           performSelectorOnMainThread:@selector(registerSourceCapture:) withObject:theContext waitUntilDone:YES];
    }
    else if(obj.threadID == 1)
    {
        [sharedVC           performSelectorOnMainThread:@selector(registerSourcePlayback:) withObject:theContext waitUntilDone:YES];
    }
    else NSLog(@"Usage: Init, set thread ID, detatch, run with runloop");
}

void            RunLoopSourcePerformRoutine(void *info)
{
    //NSLog(@"Perform callback to process custom data.\n");
    //Process custom data when your input is signaled
    RunLoopSource       *obj                    =       (__bridge RunLoopSource*) info;
    [obj                sourceFired];
}

void            RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode)
{
    //NSLog(@"Cancel callback");
    RunLoopSource       *obj                    =       (__bridge RunLoopSource*)info;
    RunLoopContext      *theContext             =       [[RunLoopContext        alloc]initWithSource:obj andLoop:rl];
    ViewController      *sharedVC               =       [obj                    getSharedViewController];
    if(obj.threadID == 0)
    {
        [sharedVC           performSelectorOnMainThread:@selector(removeSourceCapture:) withObject:theContext waitUntilDone:YES];
    }
    else if(obj.threadID == 1)
    {
        [sharedVC           performSelectorOnMainThread:@selector(removeSourcePlayback:) withObject:theContext waitUntilDone:YES];
    }

}

void            *RunLoopObserver(CFRunLoopObserverRef CFRunLoopObserverRef,CFRunLoopActivity activity, void *info)
{
    //printf("Observer callback");
    return              info;
}

typedef struct DAinfo
{

    vImage_CGImageFormat    cgFormat;
    vImage_Buffer           buffer;
    
    void *dataPointer;
    
} DAInfo;


typedef size_t (*CGDataProviderGetBytesAtOffsetCallback)
(
    void    *info,
    void    *buffer,
    size_t  offset,
    size_t  count
 
 );

struct CGDataProviderDirectAcceessCallbacks
{
    CGDataProviderGetBytePointerCallback        getBytePointer;
    CGDataProviderReleaseBytePointerCallback    releaseBytePointer;
    CGDataProviderGetBytesAtOffsetCallback      getBytes;
    CGDataProviderReleaseInfoCallback           releaseProvider;
};
typedef struct CGDataProviderDirectAcceessCallbacks CGDataProviderDirectAccessCallbacks;

const void * DAgetBytePointer(void *info)
{
    //By supplying this pointer, you are goiving Core Graphics read-only access to both the pointer and the underlying provider data.
    
    //When Core Graphics needs direct access to your data provider data, this funciton is called.
    //NSLog(@"Direct acces get byte pointer");
    
    DAInfo *privateInfo  =   (void *)info;
    return privateInfo->dataPointer;
}
void DAreleaseBytePointer(void *info, const void * pointer)
{
    //NSLog(@"Direct Access Buffer released");

    DAInfo *privateInfo     =   (void *)info;
            
    free((void*)pointer);
    
    
    return;
}
void DAreleaseData(void *info, const void *data, size_t size)
{
    //NSLog(@"Direct Access release Data");
    //DAInfo *privateInfo     =   (void *)info;
    
    free((void*)data);
}

size_t  DAgetBytesAtOffset(void *info, void *buffer, off_t offset, size_t count)
{
    NSLog(@"Direct Access get bytes at offset");
    
    //Copies data from the provider into ta Core Graphics buffer
    DAInfo *privateInfo         =   (void *)info;
    
    //Allocates the necessary memory based on the pixel dimensions, format, and extended pixels describes in the buffer's attributes
    //CVPixelBufferCreate(NULL, privateInfo->width, privateInfo->height, privateInfo->pixelFormatType, privateInfo->attributes, buffer);
    
    int *source         =   privateInfo->dataPointer;
    //int buffer          =   malloc(sizeof(int)*count);
    int *destination    =   buffer;
    //buffer assumed to be allocated
    
    for(int i = (int)offset; i < count; i++)
    {
        destination[i]  =   source[i];
    }
    
    buffer              =   destination;
    return 0;
    
}

void DAReleaseInfo(void *info)
{
    //NSLog(@"Direct access release info");
    DAInfo  *privateInfo        =       (void *)info;
    
    free(privateInfo->dataPointer);
}
typedef struct vImageInfo
{
    vImage_Buffer           data;
    vImage_CGImageFormat    format;
    
} vImageInfo;

void vImageRelease(void *userData, void *buf_data)
{
    //NSLog(@"vImageRelease");
    
    free(buf_data);
}

@implementation RunLoopSource

//Autosynthesized property threadID will use synthesized instance variable _threadID, not existing instance variable threadID

-   (id) initWithSharedVC:(ViewController *)VC totalFrames:(int)frameNum;
{
    CFRunLoopSourceContext          context;
    context.cancel                  =           RunLoopSourceCancelRoutine;
    context.schedule                =           &RunLoopSourceScheduleRoutine;
    context.perform                 =           RunLoopSourcePerformRoutine;
    context.version                 =           0;
    
    context.equal                   =           NULL;
    context.hash                    =           NULL;
    context.copyDescription         =           NULL;
    context.release                 =           NULL;
    context.retain                  =           NULL;
    
    context.info                    =           (__bridge void *)self;
    
    runLoopSource                   =           CFRunLoopSourceCreate(NULL, 0, &context);
    commands                        =           [[NSMutableArray        alloc]init];
    
    sharedVC                        =           VC;
    totalFrames                     =           frameNum;

    currentVideoSaveArray           =           CFArrayCreateMutable(NULL, 30, &kCFTypeArrayCallBacks);

    
    
    return          self;
}

-   (ViewController *)getSharedViewController
{
    return          sharedVC;
}

//Client interface for registering commands to process
-   (void)  addCommand:(NSInteger)command withData:(id)data
{
    if(command == 0)
    {
        NSNumber        *receivedFrameNum               =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber         numberWithInt:(int)command]];
        [commands       addObject:receivedFrameNum];
        
        //NSLog(@"Add command: Set current frame number %@",receivedFrameNum);
    }
    else if(command == 1)
    {
        //NSLog(@"Add Command: set the total frames");
        NSNumber        *totalFrames                    =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber         numberWithInt:(int)command]];
        [commands       addObject:totalFrames];
    }
    
    else if(command == 2)
    {
        //NSLog(@"Add command: change the thread ID");
        NSNumber        *receivedThreadID               =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber         numberWithInt:(int)command]];
        [commands       addObject:receivedThreadID];
    }
    else if(command == 3)
    {
        //NSLog(@"Add command: change the current video save block");
        NSNumber        *receivedVideoSaveBlock         =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber         numberWithInt:(int)command]];
        [commands       addObject:receivedVideoSaveBlock];
    }
    else if(command == 4)
    {
        //NSLog(@"Add command: add frame to video");
        CGImageRef      receivedImage                   =       CGImageCreateCopy((__bridge CGImageRef)data);
        [commands       addObject:(id)[NSNumber         numberWithInt:(int)command]];
        [commands       addObject:(__bridge id)((CGImageRef)receivedImage)];
        
    }
    else if(command == 5)
    {
        //NSLog(@"Add command: Set the video Dir");
        NSNumber        *receivedDirNum                 =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)receivedDirNum];
    }
    else if(command == 6)
    {
        //NSLog(@"Add command: Set the frames per save block");
        NSNumber        *receivedFramesNum              =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)receivedFramesNum];
    }
    else if(command == 7)
    {
        //NSLog(@"Add command: Open the video register");
        NSNumber        *receivedDirNum                 =       (NSNumber *)data;
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)receivedDirNum];
    }
    else if(command == 8)
    {
        //NSLog(@"Add command: Play the video register");
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)0]];
    }
    else if(command == 10)
    {
        //NSLog(@"Add command: Thread ready to exit");
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)0]];
        
    }
    else if(command == 11)
    {
        //NSLog(@"Expunge thread");
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)command]];
        [commands       addObject:(id)[NSNumber     numberWithInt:(int)0]];
    }
    
    else{
        NSLog(@"Usage: Compare received command with available commands, send command to command array");
    }
}

-   (void)      fireAllCommandsOnRunLoop:(CFRunLoopRef)runLoop
{
    CFRunLoopSourceSignal(runLoopSource);
    CFRunLoopWakeUp(runLoop);
}


-   (void)      sourceFired
{
    //Process any commands in the command buffer
    //NSLog(@"Source fired.\n");
    //NSLog(@"%ld commands to fire.\n",commands.count/2);
    
    
    for(int i = 0; i < commands.count; i = i + 2)
    {
        NSNumber        *numberCommand  =   [commands       objectAtIndex:i];
        id  data                        =   [commands       objectAtIndex:i+1];
        
        NSInteger       command         =   [numberCommand  intValue];
        
        if(command == 0)
        {
            NSNumber    *receivedData   =   (NSNumber*)data;
            currentFrameNumber          =   receivedData.intValue;
            
            //NSLog(@"Execute setting the current frame number: %d.",currentFrameNumber);
        }
        else if(command == 1)
        {
            NSNumber    *receivedData   =   (NSNumber*)data;
            totalFrames                 =   receivedData.intValue;
            
            //NSLog(@"Execute setting the total frame number: %d.",totalFrames);
        }
        else if(command == 2)
        {
            NSNumber    *receivedData   =   (NSNumber*)data;
            threadID                    =   receivedData.intValue;
             
            //NSLog(@"Execute setting the thread ID: %d.",threadID);
        }
        else if(command == 3)
        {
            NSNumber    *receivedData   =   (NSNumber*)data;
            currentVideoSaveBlock       =   receivedData.intValue;
            
            //NSLog(@"Execute setting the current save block: %d.",currentVideoSaveBlock);
        }
        else if(command == 4)
        {
            int arrayIndex              =   currentFrameNumber - (currentVideoSaveBlock * totalFrames);
            //NSLog(@"Execute adding current frame to array[%d]",arrayIndex);
            
            CGImageRef  receivedData    =   CGImageCreateCopy((__bridge CGImageRef)data);
            CFArrayInsertValueAtIndex(currentVideoSaveArray, arrayIndex, receivedData);
            
            CGImageRelease((__bridge CGImageRef)data);
            
        }
        else if(command == 5)
        {
            //NSLog(@"Execute setting the video Dir");
            
            NSNumber    *receivedData   =   (NSNumber*)data;
            currentVideoDir             =   receivedData.intValue;
        }
        else if(command == 6)
        {
            //NSLog(@"Execute setting the frames per save block");
            
            NSNumber    *receivedData   =   (NSNumber*)data;
            framesPerSaveBlock          =   receivedData.intValue;
            
        }
        else if(command == 7)
        {
            NSNumber    *receivedData   =   (NSNumber*)data;
            currentVideoDir             =   receivedData.intValue;
            
            NSLog(@"Execute Opening the video %d",currentVideoDir);
            NSThread        *currentThread      =       [NSThread   currentThread];

            int             currentVid  =   currentVideoSaveBlock;

            currentRegister     =       [[VideoModel    alloc]initWithFileURL:[DirectoryController videoURL:currentVideoDir videoNum:currentVid]];
            
            [currentRegister   openWithCompletionHandler:^(BOOL opened) {
                if(opened == YES)
                {
                    ;//NSLog(@"Register opened");
                }
                else{
                    NSLog(@"Usage: Init, open.");
                }
            }];
        }
        
        else if(command == 8)
        {
            //NSLog(@"Execute Playing the video");
            
            CMTime      startTime       =   CMClockGetTime(CMClockGetHostTimeClock());
            float       timeInSeconds   =   CMTimeGetSeconds(startTime);
            float       nextFrameTime   =   timeInSeconds;
            float       lastFrameTime   =   timeInSeconds + framesPerSaveBlock;
            
            int currentFrame            =   0;
            
            while(currentFrame      <       framesPerSaveBlock)
            {
                while(CMTimeGetSeconds(CMClockGetTime(CMClockGetHostTimeClock())) > nextFrameTime && currentFrame < framesPerSaveBlock)
                {
                    //NSLog(@"(SB: %d)(%d < %d) Play frame (%d) %d",currentVideoSaveBlock,currentFrame, framesPerSaveBlock,currentFrame,currentFrame + framesPerSaveBlock * currentVideoSaveBlock);
                    if(currentFrame < CFArrayGetCount(currentRegister.video))
                    {
                        [self->sharedVC     performSelectorOnMainThread:@selector(setFrameToView:) withObject:CFArrayGetValueAtIndex(currentRegister.video, currentFrame) waitUntilDone:YES];
                    }
                    else
                    {
                        //NSLog(@"Last frame reached");
                    }

                    nextFrameTime       =   nextFrameTime + (1.0 / 30.0);
                    currentFrame++;
                    
                    //subtract for photo preview and audio
                    int     numExtraItemsInDir;
                    if([[[DirectoryController videoDir:currentVideoDir]URLByAppendingPathComponent:@"Audio"] checkPromisedItemIsReachableAndReturnError:NULL])
                    {
                        numExtraItemsInDir = 2;
                    }
                    else
                    {
                        numExtraItemsInDir = 1;
                    }
                    
                    if(currentFrame    ==   (int)framesPerSaveBlock/2.0 && currentVideoSaveBlock + 1 < [DirectoryController getNumVideosInVideoDirectory:currentVideoDir] - numExtraItemsInDir)
                    {
                        //Halfway point
                        //Prepare next save block
                        [self->sharedVC     performSelectorOnMainThread:@selector(prepareSaveBlock:) withObject:[NSNumber    numberWithInt:currentVideoSaveBlock + 1] waitUntilDone:NO];
                    }
                }
            }
            //NSLog(@"Video played, clear register");

            for(int i = 0; i < CFArrayGetCount(currentRegister.video); i++)
            {
                CGImageRelease((CGImageRef)CFArrayGetValueAtIndex(currentRegister.video, i));
            }

            [currentRegister                releaseFrameData];
            
            NSNumber            *nextSaveBlock   =   [NSNumber        numberWithInt:currentVideoSaveBlock + 1];
            
            int     numExtraItemsInDir;
            if([[[DirectoryController videoDir:currentVideoDir]URLByAppendingPathComponent:@"Audio"] checkPromisedItemIsReachableAndReturnError:NULL])
            {
                numExtraItemsInDir = 2;
            }
            else
            {
                numExtraItemsInDir = 1;
            }
            
            if(nextSaveBlock.intValue < [DirectoryController getNumVideosInVideoDirectory:currentVideoDir] - numExtraItemsInDir)
            {
                [self->sharedVC     performSelectorOnMainThread:@selector(playSaveBlock:) withObject:nextSaveBlock waitUntilDone:NO];
            }
            else
            {
                //[self->sharedVC     performSelectorOnMainThread:@selector(setFrameToView:) withObject:NULL waitUntilDone:YES];
                
                [self->sharedVC     performSelectorOnMainThread:@selector(didTapPhoto:) withObject:[NSNumber numberWithInt:[DirectoryController getPreviewPhotoNumber:currentVideoDir]] waitUntilDone:NO];
                
            }
            
            [self   removeFromCurrentRunLoop];
            
        }
        else if(command == 10)
        {
            //NSLog(@"Execute save & exit from thread.");
            //NSLog(@"(SB: %d) (Videos in Dir: %d)",currentVideoSaveBlock,[DirectoryController getNumVideosInVideoDirectory:currentVideoDir]);
            //Save the register
            
            int         videoSaveNum            =           currentVideoSaveBlock;
            VideoModel *register0               =           [[VideoModel             alloc]initWithFileURL:[DirectoryController videoURL:currentVideoDir videoNum:videoSaveNum]];
            
            
            register0.video                     =           CFArrayCreateMutableCopy(NULL, 30, currentVideoSaveArray);
            
            
            register0.totalFrames               =           CFArrayGetCount(currentVideoSaveArray);
            
            //Save preview image
            if([DirectoryController     getNumVideosInVideoDirectory:currentVideoDir] == 1)
            {
                NSString                *previewImageName   =       [[DirectoryController   createNextPhotoName] stringByAppendingString:@".tiff"];
                NSURL                   *previewImageURL    =       [[DirectoryController   videoDir:currentVideoDir] URLByAppendingPathComponent:previewImageName];
                
                PhotoModel              *previewImage       =       [[PhotoModel        alloc]initWithFileURL:previewImageURL];
                
                
                CIContext               *cictx              =       [[CIContext              alloc]init];
                CIImage                 *preview            =       [[CIImage               alloc]initWithCGImage:(CGImageRef)CFArrayGetValueAtIndex(register0.video, 0)];
                
                preview                                     =       [preview                imageByApplyingOrientation:kCGImagePropertyOrientationLeft];
                
                CGImageRef              processedImage      =       [cictx              createCGImage:preview fromRect:preview.extent];
                
                previewImage.photo                          =       processedImage;
                
                [previewImage           saveToURL:previewImage.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                    if(success)
                    {
                        NSLog(@"Preview Image saved");
                        [previewImage   closeWithCompletionHandler:^(BOOL success) {
                            if(success){
                                [previewImage       releaseSave];
                                CGImageRelease(previewImage.photo);
                            }
                            else NSLog(@"Usage: Init, save, close");
                        }];
                    }
                    else NSLog(@"Usage: Init, save");
                }];
            }
            
            
            [register0    saveToURL:register0.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if(success){
                    //NSLog(@"Video (%d) saved",self->currentVideoSaveBlock);
                                        
                    [register0    closeWithCompletionHandler:^(BOOL success) {
                        //NSLog(@"Exit from thread");
                        for(int i = 0; i < CFArrayGetCount(self->currentVideoSaveArray); i++)
                        {
                            CGImageRelease((CGImageRef)CFArrayGetValueAtIndex(self->currentVideoSaveArray, i));
                        }
                        CFArrayRemoveAllValues(self->currentVideoSaveArray);
                        
                        [register0  releaseFrameData];
                        CFRelease(register0.videoSaveData);
                        
                        //[self->sharedVC     performSelectorOnMainThread:@selector(expungeThread) withObject:NULL waitUntilDone:YES];
                    }];
                }
                else NSLog(@"Usage: Init, save.");
            }];
        }
        else if(command == 11)
        {
            //NSLog(@"Execute expunge thread");
            [self removeFromCurrentRunLoop];
            return;
        }
        else
        {
            NSLog(@"Usage: Retreive cammands and data from command array, compare with available commands, execute command");
        }
    }
    
    [commands                   removeAllObjects];
}

-   (void)      expungeOpen:(VideoModel*)videoRegister
{
    
    free((void *)CFDataGetBytePtr(videoRegister.videoOpenData));

}

-   (void)      addToCurrentRunLoop
{
    //NSLog(@"Add runloop source to current runloop.");
    CFRunLoopRef                runLoop         =       CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}
-   (void)      removeFromCurrentRunLoop
{
    //NSLog(@"Remove runloop source from current runloop.");
    CFRunLoopRef                runLoop         =       CFRunLoopGetCurrent();
    CFRunLoopSourceInvalidate(runLoopSource);
}

@end

@implementation RunLoopContext

-   (id)initWithSource:(RunLoopSource *)src andLoop:(CFRunLoopRef)loop
{
    _source                                     =       src;
    _runLoop                                    =       loop;
    
    return                                              self;
}

@end

@implementation VideoThread

-   (void)      detatchedMain:(id)sharedVC
{
    //NSLog(@"Thread entry point");

    @autoreleasepool {
        self.sharedVC                               =       (ViewController*)sharedVC;
        [self main];

    }
}

-   (void)      main
{
    
    @autoreleasepool {
        NSRunLoop           *myRunLoop              =       [NSRunLoop          currentRunLoop];
        
        CFRunLoopRef        cfLoop                  =       [myRunLoop          getCFRunLoop];
        
        RunLoopSource       *source                 =       [[RunLoopSource     alloc]initWithSharedVC:self.sharedVC totalFrames:self.totalFrames];
        RunLoopContext      *theContext             =       [[RunLoopContext    alloc]initWithSource:source andLoop:cfLoop];
        
        if(self.threadID == 0) source.threadID = 0;
        else if(self.threadID == 1) source.threadID = 1;
        else NSLog(@"Usage:Init, set thread id, detatch");
        [source             addToCurrentRunLoop];
        
        BOOL                done                    =       NO;
        
        NSInteger           loopCount               =       0;
        
        do
        {
            //NSLog(@"Run loop count: %ld",(long)loopCount);
            SInt32          result                  =       CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES);
            
            if((result  ==  kCFRunLoopRunStopped)   ||      (result == kCFRunLoopRunFinished))
            {
                
                //
                //            NSLog(@"Call stack symbols %@",VideoThread.callStackSymbols);
                //            NSLog(@"Call stack %@",VideoThread.callStackReturnAddresses);
                //
                //            NSLog(@"Number of call frames on the stack %d");
                [NSThread       exit];
                done    =   YES;
            }
            
            loopCount++;
            
            //        NSLog(@"Thread Dictionary %@",self.threadDictionary);
            //        NSLog(@"Thread stacK %lu",(unsigned long)self.stackSize);
        }
        while(!done);
        
    }
}

-   (void)      doFireTimer
{
    NSLog(@"Timer fired.");
}

@end


@implementation customSegue

-   (void)perform
{
    UINavigationController              *navVC          =       self.destinationViewController;
    
    SettingsViewController              *settingsVC     =       navVC.viewControllers.firstObject;
        
    settingsVC.configurationDelegate                    =       self.sourceViewController;

    PopOverPresentationManager          *popOverPresentationManager     =       [[PopOverPresentationManager alloc]initWithPresentingViewController:self PresentingViewController:settingsVC];
    
    self.destinationViewController.modalPresentationStyle   =   UIModalPresentationCustom;
    self.destinationViewController.transitioningDelegate    =   popOverPresentationManager;

    
    [self.sourceViewController          presentViewController:self.destinationViewController animated:YES completion:^{
        NSLog(@"Segue complete.\n");
    }];
}

@end



@implementation ViewController

-   (instancetype)initWithCoder:(NSCoder *)coder
{
    self                    =           [super initWithCoder:coder];
    
    
    return      self;
}

-   (void)viewDidLoad
{
    [[UIApplication     sharedApplication]      setIdleTimerDisabled:true];
    
    photoSelected                                       =       -1;
    videoSelected                                       =       -1;
    
    frameTransformed                                    =       0;
    
    //Set property delegates
    self.takePictureView.delegate                       =       self;
    
    //Start the AV camera view;
    [self           enableAVCapture];
    
    //Set up the machine learning models and vision
    
    VNRequestCompletionHandler          visionRequestComplete       =       ^(VNRequest *request, NSError *error)
    {
        if(request.results.count > 0)
        {
            NSArray <VNObservation *>       *visionResults              =       request.results;
            VNFaceObservation               *faceObservation            =       (VNFaceObservation*)visionResults.firstObject;
            //NSLog(@"Vision results: %@",visionResults);
            
            
            int             numPoints           =       sizeof(*faceObservation.landmarks.leftPupil.normalizedPoints) / sizeof(CGPoint);
            CGPoint         leftPupil           =       *faceObservation.landmarks.leftPupil.normalizedPoints;
            CGPoint         rightPupil          =       *faceObservation.landmarks.rightPupil.normalizedPoints;
            
            
            CGRect          boundingBox         =       faceObservation.boundingBox;
            self.faceBoundingBox                =       boundingBox;
        

            
            //NSLog(@"Normalized Left Pupil: (%f,%f)",leftPupil.x,leftPupil.y);
            //NSLog(@"Normalized Right Pupil: (%f,%f)",rightPupil.x,rightPupil.y);
            
            self.leftPupilPosition              =       leftPupil;
            self.leftPupilLandmarkRegion        =       faceObservation.landmarks.leftPupil;
            self.rightPupilPosition             =       rightPupil;
            self.rightPupilLandmarkRegion       =       faceObservation.landmarks.rightPupil;
        }
        
        else{
            //NSLog(@"Scanning...");
            
            self.leftPupilPosition              =       CGPointMake(-1, -1);
            self.rightPupilPosition             =       CGPointMake(-1, -1);
        }
        
    };
    
    self.visionRequest                          =       [[VNDetectFaceLandmarksRequest       alloc]initWithCompletionHandler:visionRequestComplete];

    
    self.savesButtonSelected                    =       1;
    
    _savedPhotos                                =       [[NSMutableArray        alloc]init];
    
    self.recording                              =       0;
    
    //[DirectoryController        listDirContents:@"Photos"];
    //[DirectoryController        listDirContents:@"Video"];
    
    int *   videoDirNums                    =       malloc(sizeof(int) * [DirectoryController getVideoDirectoryCount]);
    int *   photoNums                       =       malloc(sizeof(int) * [DirectoryController getVideoDirectoryCount]);

    [DirectoryController    previewPhotoArrayWithVideoDirNums:&videoDirNums photoNum:&photoNums];
    
    _totalFrames                                =       1;
    self.currentFrame                           =       0;
    self.framesPerSaveBlock                     =       30;
    
    //first video thread
    sourcesToPingCapture                        =       [[NSMutableArray        alloc]init];
    sourcesToPingPlayback                       =       [[NSMutableArray        alloc]init];
    

    VideoThread     *captureThread0             =       [[VideoThread           alloc]init];
    captureThread0.threadID                     =       0;
    [VideoThread    detachNewThreadSelector:@selector(detatchedMain:) toTarget:captureThread0 withObject:(id)self];
    
    
    VideoThread     *playbackThread0            =       [[VideoThread           alloc]init];
    playbackThread0.threadID                    =       1;
    [VideoThread    detachNewThreadSelector:@selector(detatchedMain:) toTarget:playbackThread0 withObject:(id)self];
    
    [[NSNotificationCenter  defaultCenter]addObserver:self selector:@selector(setCameraChanged)         name:AVCaptureDeviceWasDisconnectedNotification object:NULL];
    [[NSNotificationCenter  defaultCenter]addObserver:self selector:@selector(appDidEnterBackground)    name:UIApplicationDidEnterBackgroundNotification object:NULL];
    
    //Prepare goggles effect.  Division by 3.0 makes the effect quicker (513x513 matrix at 30 fps vs 513x513/3.0 at 30 fps)
    int gogglesWidth        =   (int)513/3.0;
    int gogglesHeight       =   (int)513/3.0;
    
    predictionsFrameRate    =   0;
    model                   =   [[DeepLabV3      alloc]init];
    
    
    gogglesOverlayBitmap                    =       malloc(sizeof(uint8_t) * gogglesWidth * gogglesHeight * 4);
    
    
    gogglesOverlayCTX                       =       CGBitmapContextCreate((void*)gogglesOverlayBitmap, gogglesWidth, gogglesHeight, 8, 4 * gogglesHeight, CGColorSpaceCreateWithName(kCGColorSpaceSRGB), kCGImageAlphaPremultipliedFirst);
    overlayCTXCreated                       =       0;
    
    [self.TIFF          drawTIFF];
    
    [self.RGB           drawRGB];
    
    firstOpen                               =       0;
}

-   (void)                  viewSafeAreaInsetsDidChange
{
    [super                  viewSafeAreaInsetsDidChange];
    firstOpen                               =       0;
}

-   (void)                  setupAudioCapture
{
    //NSLog(@"Setup audio capture");
    systemSharedAudioSession                    =       [AVAudioSession     sharedInstance];
    
    [systemSharedAudioSession       setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    
    [systemSharedAudioSession       setActive:YES error:NULL];
    
    
    NSURL                   *audioURL           =       [[DirectoryController    videoDir:self.currentVideoDir]URLByAppendingPathComponent:@"Audio"];
    
    NSDictionary    <NSString*,id>  *settings   =   @{ (NSString*)AVFormatIDKey         : @(kAudioFormatLinearPCM),
                                                       (NSString*)AVSampleRateKey       : @64,
                                                       (NSString*)AVNumberOfChannelsKey : @1
    };
    
    recorder                                    =       [[AVAudioRecorder    alloc]initWithURL:audioURL settings:settings error:NULL];
    
}
    
-   (void)  appDidEnterBackground
{
    [self       setCameraChanged];
}

-   (void)  setCameraChanged
{
    NSLog(@"Camera changed.");
    cameraChanged                               =       1;
}

-   (void)background:(CGColorRef)color
{
    [self.view      setBackgroundColor:[UIColor colorWithCGColor:color]];
}

-   (void)  setFrameToView:(CGImageRef)frame
{
    [self.currentFrameView      setImage:[UIImage   imageWithCGImage:frame]];
    //CGImageRelease(frame);
}

-   (void)  registerSourceCapture:(RunLoopContext *)sourceInfo
{
    //NSLog(@"Main thread register capture source from VC");
    [sourcesToPingCapture          addObject:sourceInfo];
    //NSLog(@"Capture sources to ping: %@",sourcesToPingCapture);
}

-   (void)  registerSourcePlayback:(RunLoopContext *)sourceInfo
{
    //NSLog(@"Main thread register playback source from VC");
    [sourcesToPingPlayback          addObject:sourceInfo];
    //NSLog(@"Playback sources: %@",sourcesToPingPlayback);
}

-   (void)  removeSourceCapture:(RunLoopContext *)sourceInfo
{
    //NSLog(@"Main thread remove capture input source from VC");
    //[sourcesToPing          removeObject:[sourcesToPing     objectAtIndex:0]];
    //NSLog(@"Capture Sources to ping: %@",sourcesToPingCapture);
}
-   (void)  removeSourcePlayback:(RunLoopContext *)sourceInfo
{
    //NSLog(@"Main thread remove input");
    //[sourcesToPingPlayback        removeObject:[sourcesToPing     objectAtIndex:0]
    //NSLog(@"Playback sources to ping: %@", sourcesToPingPlayback);
}

-   (void)  expungePlaybackThreads
{
    //NSLog(@"expunge playBack thread");
    
    [sourcesToPingPlayback      removeAllObjects];
    
    //Prepare base thread
    VideoThread         *nextPlaybackThread     =       [[VideoThread        alloc]init];
    nextPlaybackThread.threadID                 =       1;
    [VideoThread        detachNewThreadSelector:@selector(detatchedMain:) toTarget:nextPlaybackThread withObject:(id)self];
}

-   (void)layoutFullscreenView
{
    //self.leadingFrameViewLayoutConstraint.constant      =       1*(self.currentFrameView.frame.size.width -[UIScreen   mainScreen].bounds.size.width)/2;
    if((int)1*((int)([UIScreen mainScreen].bounds.size.height * 1080/1920) -[UIScreen   mainScreen].bounds.size.width)/2 > 0)
    {
        //Center
        //NSLog(@"Center");
        self.leadingFrameViewLayoutConstraint.constant      =   1*((int)([UIScreen mainScreen].bounds.size.height * 1080/1920) -[UIScreen   mainScreen].bounds.size.width)/2;
        
        //NSLog(@"Center: (%f)",-1*((int)([UIScreen mainScreen].bounds.size.height * 1080/1920) -[UIScreen   mainScreen].bounds.size.width)/2);

    }
    else{
        //NSLog(@"does not need centering");
        self.leadingFrameViewLayoutConstraint.constant      =   0;
    }
    
    
    self.heightFrameViewLayoutConstraint.constant       =       [UIScreen   mainScreen].bounds.size.height;
    
    //NSLog(@"Top : %f screen top: %f",[[self view]safeAreaInsets].top, [UIScreen mainScreen].bounds.origin.y);
    
    self.topFrameViewLayoutConstraint.constant          =       [[self view]safeAreaInsets].top; //[[self       view]safeAreaInsets].top;

}
-   (void)viewDidAppear:(BOOL)animated
{
    //Called when view with edge rects appears
    //NSLog(@"View Did appear");
    
    [super  viewDidAppear:animated];
    
    //firstOpen       =       0;
    //[self   layoutFullscreenView];
    
    frameTransformViewHeight                            =       (5*[UIScreen mainScreen].bounds.size.height/8) - self.view.safeAreaInsets.top;
    
    //Scroll view
    //NSLog(@"Scroll view height: %f",frameTransformViewHeight/4);
    CGFloat         scrollViewHeight        =       frameTransformViewHeight/4;
    scrollViewSize                          =       scrollViewHeight/1920;
    scrollViewImageHeight                   =       scrollViewSize * 1920;
    scrollViewImageWidth                    =       scrollViewSize * 1080;
    
    self.SavesButtonProperty.tintColor      =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    self.VideoButtonProperty.tintColor      =       [UIColor        systemGrayColor];
    self.EffectsButtonProperty.tintColor    =       [UIColor        systemGrayColor];
    self.LensButtonProperty.tintColor       =       [UIColor        systemGrayColor];
    
    self.PlayButtonProperty.tintColor       =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    self.CameraButtonProperty.tintColor     =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    self.SettingsButtonProperty.tintColor   =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];

    CGRect          scrollViewFrame                     =       CGRectMake([UIScreen mainScreen].bounds.origin.x, frameTransformViewHeight, [UIScreen mainScreen].bounds.size.width, scrollViewHeight);
    [self.scrollView        setFrame:scrollViewFrame];
    
    //Load the settings
    NSURL           *settingsURL            =       [[DirectoryController        localDocumentsDirectoryURL]URLByAppendingPathComponent:@"Settings"];
    
    if([settingsURL     checkPromisedItemIsReachableAndReturnError:NULL])
    {
        //NSLog(@"Settings opened.");
        
        settings                =       [[SettingsModel         alloc]initWithFileURL:settingsURL];
        
        [settings                       openWithCompletionHandler:^(BOOL success) {
            if(success) [self->settings       prepareSettings];
            else NSLog(@"Usage: Init, open, prepare");
        }];
    }
    else
    {
        //NSLog(@"Settings created");
        settings               =       [[SettingsModel          alloc]initWithFileURL:settingsURL];
        
        settings.longVideoEnabled               =       NO;
        settings.audioEnabled                   =       NO;
        settings.whiteOutPhotoSaveEnabled       =       NO;
        
        [settings       prepareSettings];
        [settings       saveToURL:settings.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if(success);
            else NSLog(@"Usage: Init settings, set information, prepare, save");
        }];
    }
  
    //Initializes the photoViewStack, load photos from disk, and add the photo views to the scroll view
    [self           loadVC];
}

-   (void)          loadVC
{
    
    self.topScrollViewLayoutConstraint.constant         =       frameTransformViewHeight + 3.0;
    self.leadingScrollViewLayoutConstraint.constant     =       0.0;
    self.widthScrollViewLayoutConstraint.constant       =       0.0;
    self.heightScrollViewLayoutConstraint.constant      =       scrollViewImageHeight;
    
    _scrollView.contentSize                             =       CGSizeMake(3.0 + (scrollViewImageWidth + 3.0) * ([DirectoryController getNumPhotos]), 0);
    
    //Stack view
    _photoStackViewSource                               =       [[NSMutableArray        alloc]init];
    
    //Lens stack
    _lensStackView                                      =       [[NSMutableArray        alloc]init];
    
    //Effect stack
    _effectsStackView                                   =       [[NSMutableArray        alloc]init];
    
    _eyeEffectSelected                                  =       0;
    _whiteEffectSelected                                =       0;
    _siloEffectSelected                                 =       0;
    
    //Load the photos from disk intol the model and photoViewStack
    [self           loadPhotos];
    //Add the photo views to the scroll view
    
    //load the stack view in order (called from loadPhotos)
    
    //Photos updated
}

-   (void)          loadPhotos
{
    //NSLog(@"Load Photos");
    [self.savedPhotos           removeAllObjects];
    
    NSURL               *searchDir                          =       [DirectoryController        photosDirectoryURL];
    NSFileManager       *fm                                 =       [NSFileManager              defaultManager];
    NSArray             <NSString*>     *dirContents        =       [fm contentsOfDirectoryAtPath:(NSString*)searchDir error:NULL];
    NSMutableArray      *mutableDirContents                 =       [[NSMutableArray            alloc]initWithArray:dirContents];
    
    [mutableDirContents removeObject:@".Trash"];
    //Increment the ordered index only after opening and closing is complete.
    //This differes from the 'i' index in that it is not attatched to any current execution besides the current close completion handler
    //which is often in non-incremental order -- saving and loading in asynchronous
    //Use the ordered Index to load the stack view after the for loop has completed every iteration
    
    __block int orderedIndex = 0;

    for(int i = 0; i < mutableDirContents.count; i++)
    {
        //For every photo, add the model to the arrray of photos, open and store the data (in a view), create a view, and add the view to the stack of views
        //Current photo is the current location in the app's photo directory
        PhotoModel      *currentPhoto                       =       [[PhotoModel                alloc]initWithFileURL:[searchDir    URLByAppendingPathComponent:[mutableDirContents objectAtIndex:i]]];
        currentPhoto.photoName                              =       [mutableDirContents         objectAtIndex:i];
        
        //Insert the current photo into the saved photos array
        [self.savedPhotos       insertObject:currentPhoto atIndex:i];
        
        PhotoView           *currentPhotoView               =       [[PhotoView                 alloc]init];
        currentPhotoView.delegate                           =       self;
        currentPhotoView.contentMode                        =       UIViewContentModeScaleAspectFit;
        //Add the view to the stack view
        [self.photoStackViewSource          addObject:currentPhotoView];
        
        
        //Open the photos and store the data
        [[self.savedPhotos                  objectAtIndex:i]openWithCompletionHandler:^(BOOL success) {
            if(success == true)
            {
                //Set the photo location
                [self.savedPhotos           objectAtIndex:i].photoLocation      =       [self.savedPhotos objectAtIndex:i].fileURL;
                //Set the photo name
                [self.savedPhotos           objectAtIndex:i].photoName          =       [DirectoryController    getItemName:[self.savedPhotos objectAtIndex:i].photoLocation];
                //Set the photo ID number (changed to a simple count)
                [self.savedPhotos           objectAtIndex:i].photoID            =       [DirectoryController    getPhotoNumber:[self.savedPhotos objectAtIndex:i].photoLocation];
                
                
                //Set the view's image to the data
                
                //Create a photo view
                CGImageRef          currentSavedPhoto                           =       [self.savedPhotos   objectAtIndex:i].photo;
                
                UIImage *currentImage       =       [UIImage            imageWithCGImage:currentSavedPhoto scale:1.0 orientation:UIImageOrientationRight];

                //[[self.photoStackViewSource objectAtIndex:i]setImage:currentImage];
                [[self.photoStackViewSource objectAtIndex:i]setImage:[currentImage imageByPreparingThumbnailOfSize:CGSizeMake(1080*.1, 1920*.1)]];
                [[self.photoStackViewSource objectAtIndex:i]setPhotoID:[self.savedPhotos objectAtIndex:i].photoID];
            }
            else
            {
                NSLog(@"Usage: Init Current photo, insert into saved photos array, create photo view, add the view to the stack, open and save the data.");
            }
            
            //Close the photo model
            [[self.savedPhotos              objectAtIndex:i]closeWithCompletionHandler:^(BOOL success) {
                if(success == true)
                {
                    orderedIndex++;
                    if(orderedIndex == mutableDirContents.count){
                        //Done loading models, load stack view in order with photo IDs attatched after removing the data.
                        for(int j = 0; j < self.savedPhotos.count; j++){
                            //[[self.savedPhotos objectAtIndex:j]releaseOpen];
                            CGImageRelease([self.savedPhotos   objectAtIndex:j].photo);
                        }
                        
                        //[self               reloadVC];
                        [self               loadStackView];
                        
                    }
                }
                else{
                    NSLog(@"Usage: close photos after opening, seting data, and adding data to the photo stack view.");
                }
            }];
        }];
    }
    
    //photos updated
    self.updateSavedPhotos              =       0;
    
}

-   (void)          reloadVC
{
    //NSLog(@"Reload VC");
    //remove all photos from main view
    
    if(self.savesButtonSelected == 1)
    {
        [self removeSavedPhotosStackView];
    }
    
    [self.savedPhotos               removeAllObjects];
}
 
-   (void)          removeSavedPhotosStackView
{
    for(int i = 0; i < self.photoStackViewSource.count; i++)
    {
        [[self.photoStackViewSource         objectAtIndex:i]setImage:NULL];
        [[self.photoStackViewSource         objectAtIndex:i]removeFromSuperview];
    }
    [self.photoStackViewSource              removeAllObjects];
}

-   (void)          hideSavedPhotosStackView
{
    for(int i = 0; i < self.photoStackViewSource.count; i++)
    {
        [[self.photoStackViewSource         objectAtIndex:i] setHidden:YES];
    }
}
-   (void)          showSavedPhotosStackView
{
    for(int i = 0; i < self.photoStackViewSource.count; i++)
    {
        [[self.photoStackViewSource         objectAtIndex:i] setHidden:NO];
    }
    
    //Set the content size
    self.scrollView.contentSize     =       CGSizeMake(3.0 + (self.photoStackViewSource.count * (scrollViewImageWidth + 3.0)), 0);
    
    
}
-   (void)          removeLensStackView
{
    for(int i = 0; i < self.lensStackView.count;i++)
    {
        [[self.lensStackView                objectAtIndex:i]setImage:NULL];
        [[self.lensStackView                objectAtIndex:i]removeFromSuperview];
    }
    [self.lensStackView                     removeAllObjects];
}

-   (void)          hideLensStackView
{
    for(int i = 0; i < self.lensStackView.count; i++)
    {
        [[self.lensStackView objectAtIndex:i] setHidden:YES];
    }
}
-   (void)          showLensStackView
{
    for(int i = 0; i < self.lensStackView.count; i ++)
    {
        [[self.lensStackView objectAtIndex:i] setHidden:NO];
    }
    
    self.scrollView.contentSize     =       CGSizeMake(3.0 + (self.lensStackView.count * (scrollViewImageWidth + 3.0)), 0.0);
}

-   (void)          hideEffectsStackView
{
    for(int i = 0; i < self.effectsStackView.count; i++)
    {
        [[self.effectsStackView             objectAtIndex:i] setHidden:YES];
    }
}
-   (void)          showEffectsStackView
{
    for(int i = 0; i < self.effectsStackView.count; i++)
    {
        [[self.effectsStackView             objectAtIndex:i]setHidden:NO];
    }
    
    //Set the content size
    self.scrollView.contentSize     =       CGSizeMake(3.0 + (self.effectsStackView.count * (scrollViewImageWidth + 3.0)), 0.0);
}

-   (void)          loadStackView
{
    //NSLog(@"Load stack view");
    int             viewNumber          =       0;
    
    for(int i = (int)self.photoStackViewSource.count - 1; i >= 0; i--)
    {
        for(int x = 0; x < self.photoStackViewSource.count; x++)
        {
            //When the next view is found, add it to the scroll view with an updated frame.
            if([[self           photoStackViewSource]objectAtIndex:x].photoID == i){
                //CGPoint         pos     =       CGPointMake(0, 0);
                CGSize          size    =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos     =       CGPointMake(3.0 + (viewNumber * (scrollViewImageWidth + 3.0)), 0);
                [[[self         photoStackViewSource]objectAtIndex:x]setFrame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                [self.scrollView            addSubview:[[self           photoStackViewSource] objectAtIndex:i]];

                //Break out of the current search
                viewNumber++;
                x = (int)self.photoStackViewSource.count;
            }
        }
    }
}

-   (void)      loadEffectsStackView
{
    int             effectID;
    int             effectNum   =   0;
    CGSize          size;
    CGPoint         pos;
    
    
    if(self.effectsStackView.count > 0){
        //Effects already loaded
        ;//[self showEffectsStackView];
    }
    else{
        //load effects
        //Eyes;
        effectID        =       kEffectEyes;
        size            =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
        pos             =       CGPointMake(3.0 + (effectNum * (scrollViewImageWidth + 3.0)), 0);
        
        EffectsView     *eyeEffectView              =       [[EffectsView   alloc]initWithEffectID:effectID frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
        eyeEffectView.delegate                 =       self;
        [self.effectsStackView  addObject:eyeEffectView];
        [self.scrollView        addSubview:[[self       effectsStackView] objectAtIndex:effectNum]];
        
        effectNum++;
        
        //White effect
        effectID        =       kEffectColorWhite;
        size            =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
        pos             =       CGPointMake(3.0 + (effectNum * (scrollViewImageWidth + 3.0)), 0);
        
        EffectsView     *whiteEffectsView           =       [[EffectsView   alloc]initWithEffectID:effectID frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
        whiteEffectsView.delegate                   =       self;
        [self.effectsStackView  addObject:whiteEffectsView];
        [self.scrollView        addSubview:[[self       effectsStackView] objectAtIndex:effectNum]];
        
        effectNum++;
        
        
        //Silo effect
        effectID        =       kEffectSilo;
        size            =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
        pos             =       CGPointMake(3.0 + (effectNum * (scrollViewImageWidth + 3.0)), 0);
        
        EffectsView     *siloEffectView             =       [[EffectsView   alloc]initWithEffectID:effectID frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
        siloEffectView.delegate                   =       self;
        [self.effectsStackView  addObject:siloEffectView];
        [self.scrollView        addSubview:[[self       effectsStackView] objectAtIndex:effectNum]];
        
        effectNum++;
        
        
        
        
        //vImage effect
        effectID        =       kEffectVImage;
        size            =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
        pos             =       CGPointMake(3.0 + (effectNum * (scrollViewImageWidth + 3.0)), 0);
        
        EffectsView     *vImageEffectView           =       [[EffectsView   alloc]initWithEffectID:effectID frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
        vImageEffectView.delegate                   =       self;
        [self.effectsStackView  addObject:vImageEffectView];
        [self.scrollView        addSubview:[[self       effectsStackView] objectAtIndex:effectNum]];
        
        effectNum++;
    }
        
    
}

-   (void)      loadLensStackView
{
    
    if(self.lensStackView.count > 0) ;  //Lens view already loaded, only need to show lenses;
    else
    {
        
        
        int             lensNumber                  =       0;
        
        for(AVCaptureDevice *device in availableCameraCaptureDevices.devices)
        {
            
            //NSLog(@"devices: %@, lens Number: %d",device.description,lensNumber);
            if(device.deviceType == AVCaptureDeviceTypeBuiltInTelephotoCamera)
            {
                
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceTelephotoCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else if(device.deviceType ==  AVCaptureDeviceTypeBuiltInDualWideCamera)
            {
                
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceDualWideCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInUltraWideCamera)
            {
                
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceUltraWide frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInTripleCamera)
            {
                
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceTripleCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInDualCamera)
            {
                position                            =       kDevicePositionBack;
                backCamera                          =       kDeviceDualCamera;
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceDualCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInLiDARDepthCamera)
            {
                position                            =       kDevicePositionBack;
                backCamera                          =       kDeviceLiDarDepth;
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceLiDarDepth frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera)
            {
                //NSLog(@"Device: %@",device.description);
                if(device.position  ==  AVCaptureDevicePositionFront)
                {
                    position                            =       kDevicePositionFront;
                    frontCamera                         =       kDeviceFrontWideAngleCamera;
                    
                    CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                    CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                    
                    LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceFrontWideAngleCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                    currentLensView.delegate            =       self;
                    
                    [self.lensStackView addObject:currentLensView];
                    [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                    lensNumber++;

                }
                //Wide angle also available for back position, requires extra branch when active
                else if(device.position    ==  AVCaptureDevicePositionBack)
                {
                    position                            =       kDevicePositionBack;
                    backCamera                          =       kDeviceBackWideAngle;
                    CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                    CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
    
                    LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceBackWideAngle frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                    currentLensView.delegate            =       self;
    
                    [self.lensStackView addObject:currentLensView];
                    [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                    lensNumber++;
    
    
                }
                
            }
            else if(device.deviceType == AVCaptureDeviceTypeBuiltInTrueDepthCamera)
            {
                
                CGSize          size                =       CGSizeMake(scrollViewImageWidth, scrollViewImageHeight);
                CGPoint         pos                 =       CGPointMake(3.0 + (lensNumber * (scrollViewImageWidth + 3.0)), 0);
                
                LensView        *currentLensView    =       [[LensView  alloc]initWithLensID:kDeviceTrueDepthCamera frame:CGRectMake(pos.x, pos.y, size.width, size.height)];
                currentLensView.delegate            =       self;
                
                [self.lensStackView addObject:currentLensView];
                [self.scrollView    addSubview:[[self       lensStackView] objectAtIndex:lensNumber]];
                lensNumber++;

            }
            else {
                NSLog(@"Usage: add lens from device discovery array to the scroll view");
            }
            
            
            
        }
        
        //Set the content size
        self.scrollView.contentSize                 =       CGSizeMake(3.0 + (self.lensStackView.count * (scrollViewImageWidth + 3.0)), 0);
    }
}

-   (void)          frameReceived:(CGImageRef)image
{
    //NSLog(@"Frame received %ldx%ld",CGImageGetWidth(image),CGImageGetHeight(image));
    if(firstOpen == 0)
    {
        //NSLog(@"First open");
        [self layoutFullscreenView];
        firstOpen++;
    }
    else{

    }
    
    if(self.PlayButtonProperty.isHidden == NO)  [self.PlayButtonProperty        setHidden:YES];

    
    CGImageRef      processedImage      =       [self                   processFrame:image];
    UIImage         *frameImage         =       [UIImage                imageWithCGImage:processedImage];

    
    [self.currentFrameView                      setImage:frameImage];
    
    
    if(self.recording                   ==      true)
    {
        
        if(settings.longVideoEnabled == NO)
        {
            if(self.totalFrames             >       160)
            {
                [self       VideoButton];
                self.totalFrames        =       0;
            }
        }
        
        
        self.totalFrames                =       self.totalFrames+1;
        
        [self       recordFrame:processedImage];
    }
    
    //NSLog(@"Number of retains : %ld",(long)CFGetRetainCount(processedImage));
    
    //free(destinationBuffer.data);
    
    //Image not returned, release here
    
    CGImageRelease(lastFrame);
    lastFrame                           =       processedImage;
}

-   (void)          initRecording
{
    //Record into a new video directory
    int *   videoDirNums    =       malloc(sizeof(int) * [DirectoryController   getVideoDirectoryCount]);
    int *   photoNums       =       malloc(sizeof(int) * [DirectoryController   getVideoDirectoryCount]);
    
    int     nextDir         =       [DirectoryController    getVideoDirectoryCount];
    int     dirNew          =       1;      //check to see if dir is non-duplicate
    [DirectoryController        previewPhotoArrayWithVideoDirNums:&videoDirNums photoNum:&photoNums];
    
    while(dirNew == 1)
    {
        dirNew  =   0;
        for(int i = 0; i < [DirectoryController getVideoDirectoryCount]; i++)
        {
            if(nextDir      ==      videoDirNums[i])
            {
                nextDir++;
                dirNew      =       1;//Enter the loop again;
            }
        }
    }
    
    _currentVideoDir        =       nextDir;
    _currentFrame           =       0;
    _currentVideoSaveBlock  =       0;
        
        
    [DirectoryController        createVideoDir:self.currentVideoDir];

}

-   (void)          recordFrame:(CGImageRef)frame
{
    //NSLog(@"Recording, current frame: %d total frames: %d",self.currentFrame,self.totalFrames);
    
    RunLoopContext              *theContext     =       [sourcesToPingCapture          objectAtIndex:self.currentVideoSaveBlock];
    RunLoopSource               *theSource      =       [theContext             source];
    
    
    int lastFrame           =       self.totalFrames - 1;
    int saveBlockStart      =       (self.currentVideoSaveBlock * self.framesPerSaveBlock);
    int saveBlockHalfway    =       ((self.currentVideoSaveBlock + 1)   * self.framesPerSaveBlock) - self.framesPerSaveBlock/2;
    int saveBlockLastFrame  =       ((self.currentVideoSaveBlock + 1)     *  self.framesPerSaveBlock) - 1;
    
    
    //Preprossesing
    if(self.currentFrame            >=  lastFrame)
    {
        //NSLog(@"Last frame of video.");
    }
    if(self.currentFrame       ==  saveBlockLastFrame)
    {
        //NSLog(@"Last frame of save block.  Switch to next thread.");
    }
    else if(self.currentFrame       ==  saveBlockHalfway){
        //Current thread halfway point
        //Prepare next thread;
        //NSLog(@"Current block halfway point \n\n");
        VideoThread         *nextThread     =       [[VideoThread           alloc]init];
        nextThread.threadID                 =       0;
        [VideoThread        detachNewThreadSelector:@selector(detatchedMain:) toTarget:nextThread withObject:(id)self];
    }
    else if(self.currentFrame       ==  saveBlockStart)
    {
        //Initialize new save block
        [theSource                  addCommand:1 withData:[NSNumber numberWithInt:self.framesPerSaveBlock]];
        //[theSource                  addCommand:2 withData:[NSNumber numberWithInt:self.currentVideoSaveBlock]]; //threadID
        [theSource                  addCommand:3 withData:[NSNumber numberWithInt:self.currentVideoSaveBlock]];
        [theSource                  addCommand:5 withData:[NSNumber numberWithInt:self.currentVideoDir]];
        
        //Fire preprocessing before processing
        //[theSource                  fireAllCommandsOnRunLoop:theContext.runLoop];
    }
    
    //Process frame
    if(self.currentFrame        <   lastFrame)
    {
        [theSource                  addCommand:0 withData:[NSNumber numberWithInt:self.currentFrame]];
        [theSource                  addCommand:4 withData:(__bridge id)frame];
    }
    else
    {
        [theSource                  addCommand:0 withData:[NSNumber numberWithInt:self.currentFrame]];
        [theSource                  addCommand:4 withData:(__bridge id)frame];
        
        //Last frame has access to additional post processing. Such as firing early.
        //[theSource                  fireAllCommandsOnRunLoop:theContext.runLoop];
    }
    
    
    //Post processing
    
    //End of video

    if(self.currentFrame       >= lastFrame)
    {
        //NSLog(@"End of video. End recording.");
        
        self.recording          =       0;
    }
    
   
    
    if(self.currentFrame        >=  lastFrame )
    {
        [theSource                  addCommand:10 withData:[NSNumber    numberWithInt:self.currentVideoDir]];
        self.currentVideoSaveBlock++;

        //Send preview image to stack view
        //NSLog(@"Preview photo %@",[DirectoryController getPreviewPhoto:self.currentVideoDir]);
        PhotoModel      *preview    =   [[PhotoModel     alloc]initWithFileURL:[DirectoryController      getPreviewPhoto:self.currentVideoDir]];
        
        BOOL     __block    previewExists   =   [preview.fileURL        checkResourceIsReachableAndReturnError:NULL];
        
        //Handle preview being unprepared gracefully: set preview to last available frame
        if(previewExists                    ==      NO)
        {
            CIContext           *cictx      =       [[CIContext         alloc]init];
            CIImage             *ciPreview  =       [[CIImage           alloc]initWithCGImage:frame];
            
            ciPreview                       =       [ciPreview          imageByApplyingOrientation:kCGImagePropertyOrientationLeft];
            preview.photo                   =       [cictx              createCGImage:ciPreview fromRect:ciPreview.extent];

            [preview    saveToURL:preview.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if(success) previewExists   =       YES;
                else NSLog(@"Usage: init preview photo, save current frame");
            }];
        }
        else
        {
                        previewExists       =   YES;
        }
        
        
        [preview        openWithCompletionHandler:^(BOOL success) {
            if(success)
            {
                //NSLog(@"Preview photo opened.");
                //Add a time stamp;
                
                //Save to stack
                NSString    *stackString    =   [[DirectoryController   createNextPhotoName] stringByAppendingString:@".tiff"];
                NSURL       *stackURL       =   [[DirectoryController   photosDirectoryURL]URLByAppendingPathComponent:stackString];
                int         photoNum        =   [DirectoryController    getPhotoNumber:stackURL];
                
                PhotoModel  *previewSave    =   [[PhotoModel    alloc]initWithFileURL:stackURL];
                previewSave.photo           =   preview.photo;
                previewSave.photoID         =   photoNum;
                
                [previewSave    saveToURL:stackURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                    if(success)
                    {
                        NSLog(@"Preview photo saved");
                        [previewSave    closeWithCompletionHandler:^(BOOL success) {
                            
                            [self.savedPhotos       addObject:previewSave];
                            
                            PhotoView               *currentPhotoView           =       [[PhotoView alloc]init];
                            currentPhotoView.delegate                           =       self;
                            currentPhotoView.contentMode                        =       UIViewContentModeScaleAspectFit;
                            currentPhotoView.photoID                            =       photoNum;
                            UIImage                 *UIphoto               =       [UIImage imageWithCGImage:previewSave.photo scale:1.0 orientation:UIImageOrientationRight];
                            [currentPhotoView   setImage:[UIphoto   imageByPreparingThumbnailOfSize:CGSizeMake(1080*.1, 1920*.1)]];
                            
                            [self.photoStackViewSource                                  addObject:currentPhotoView];
                            
                            
                            if(self.savesButtonSelected)
                            {
                                self.scrollView.contentSize                         =       CGSizeMake(3.0 + (self->scrollViewImageWidth + 3.0) * ([DirectoryController getNumPhotos]), 0);
                                [currentPhotoView   setHidden:NO];
                            }
                            else
                            {
                                [currentPhotoView   setHidden:YES];
                            }

                            
                            [self                   loadStackView];
                            
                            //CGImageRelease(previewSave.photo);
                            [previewSave            releaseSave];
                            
                            [preview                closeWithCompletionHandler:^(BOOL success) {
                                if(success)
                                {
                                    CGImageRelease(preview.photo);
                                    //[preview        releaseOpen];
                                }
                                else NSLog(@"Usage: Init preview from video directory, open preview from video directory, Init previewSave from photo directory, save previewSave from photo Directory, close previewSave, close preview");
                            }];
                        }];
                    }
                    else{
                        NSLog(@"Usage: init preview from video dir, open, edit, save to stack view.");
                    }
                }];
                
            }
            else{
                NSLog(@"Usage: Init preview frmo video dir, open");
            }
        }];
        
        
    }
    else if(self.currentFrame    >= saveBlockLastFrame)
    {
        //NSLog(@"End of save block.  Expunge thread.");
        [theSource                  addCommand:10 withData:[NSNumber numberWithInt:self.currentVideoDir]];
    
        self.currentVideoSaveBlock++;
    }
    
    
    //Fire all commands
    [theSource                      fireAllCommandsOnRunLoop:theContext.runLoop];
    self.currentFrame++;

    

}

-   (CGImageRef)    processFrame:(CGImageRef)frame
{

    CGImageRef      processedFrame      =       frame;
    
    if(self.eyeEffectSelected == 1)
    {
        self.leftPupilPosition          =       CGPointMake(-1, -1);
        self.rightPupilPosition         =       CGPointMake(-1, -1);
        
        processedFrame                  =       [self       addEyeEffect:processedFrame];
        //processedFrame              =       frame;
    }
    else if(self.whiteEffectSelected == 1)
    {
        processedFrame                  =       [self       addWhiteEffect:processedFrame];
    }
    else if(self.siloEffectSelected == 1)
    {
        processedFrame                  =       [self       addSiloEffect:processedFrame];
    }
    else if(self.vImageEffectSelected == 1)
    {
        processedFrame                  =       [self       addvImageEffect:processedFrame];
    }
    else
    {
        //NSLog(@"Process frame without effect");
    }
    return processedFrame;
}

-   (CGImageRef)        addEyeEffect:(CGImageRef)image
{
    //NSLog(@"Add Eye Effect");
    
    //CGImageRef                  imageWithEyeEffect  =       image;
    //image released when copied
    

    
    
    
    VNImageRequestHandler       *visionHandler      =       [[VNImageRequestHandler        alloc]initWithCGImage:image options:nil];
    [visionHandler              performRequests:@[self.visionRequest] error:NULL];
    
    
    //Draw effect
    CGSize                      imageSize           =       CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    //NSLog(@"Eye effect image size: %fx%f",imageSize.width,imageSize.height);

    CGContextRef                ctx                 =       [ViewUtilities      createBitmapContext:imageSize.width pixelsHeight:imageSize.height];
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx)), image);
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 1.0, 1.0);
    
    
    if(self.leftPupilLandmarkRegion && self.rightPupilLandmarkRegion && self.leftPupilPosition.x != -1){
        CGPoint                     leftPupilInImage        =       *[self.leftPupilLandmarkRegion pointsInImageOfSize:imageSize];
        CGPoint                     rightPupilInImage       =       *[self.rightPupilLandmarkRegion pointsInImageOfSize:imageSize];
        
        
        //NSLog(@"Pupil positions: (%f,%f) (%f,%f)",leftPupilInImage.x,leftPupilInImage.y,rightPupilInImage.x,rightPupilInImage.y);
        
        CGFloat faceDepth   =   self.faceBoundingBox.size.height;
        CGFloat eyeSize = (CGImageGetHeight(image)/4 * faceDepth);
        
        CGContextFillEllipseInRect(ctx, CGRectMake(leftPupilInImage.x - eyeSize/2 , leftPupilInImage.y - eyeSize/2, eyeSize,eyeSize));
        CGContextFillEllipseInRect(ctx, CGRectMake(rightPupilInImage.x - eyeSize/2, rightPupilInImage.y - eyeSize/2, eyeSize, eyeSize));
    }
    else
    {
        //NSLog(@"Scanning for regions");
    }

    //Draw face bounding box
    /*
    CGContextSetRGBStrokeColor(ctx, 0.0, 1.0, 0.0, 1.0);
    
    CGContextStrokeRectWithWidth(ctx, CGRectMake(self.faceBoundingBox.origin.x * imageSize.width, self.faceBoundingBox.origin.y * imageSize.height, self.faceBoundingBox.size.width * imageSize.width, self.faceBoundingBox.size.height * imageSize.height), 20.0);
    */
    
    CGImageRelease(image);

    CGImageRef  imageWithEyeEffect                  =       CGBitmapContextCreateImage(ctx);
    
    void *contextData                               =       CGBitmapContextGetData(ctx);
    free(contextData);
    CGContextRelease(ctx);
    
    
    return imageWithEyeEffect;
}

-   (CGImageRef)    addSiloEffect:(CGImageRef)image
{
    //NSLog(@"add silo effect");
    
    modelInput                                      =       [[DeepLabV3Input    alloc]initWithImageFromCGImage:image error:NULL];
    modelOutput                                     =       [model          predictionFromFeatures:modelInput error:NULL];
    imageClass                                      =       modelOutput.semanticPredictions;
    
    //NSLog(@"image class: %dx%d",imageClass.shape[0].intValue,imageClass.shape[1].intValue);
        
    uint8_t         gogglesOverlayAlpha;
    uint8_t         gogglesOverlayRed;
    uint8_t         gogglesOverlayGreen;
    uint8_t         gogglesOverlayBlue;
    

    for(int i = 0; i < (int)imageClass.shape[0].intValue/3.0; i++)
    {
        for(int j = 0; j < (int)imageClass.shape[1].intValue/3.0; j++)
        {
            int                 class                   =       [imageClass      objectForKeyedSubscript:@[[NSNumber numberWithInt:j*3],[NSNumber numberWithInt:i*3]]].intValue;
            
            int                 alphaLocation           =       (j + (int)imageClass.shape[0].intValue/3.0 *i)*4;
            int                 redLocation             =       (j + (int)imageClass.shape[0].intValue/3.0 *i)*4 + 1;
            int                 greenLocation           =       (j + (int)imageClass.shape[0].intValue/3.0 *i)*4 + 2;
            int                 blueLcoation            =       (j + (int)imageClass.shape[0].intValue/3.0 *i)*4 + 3;
            
            if(class == 0)
            {
                gogglesOverlayAlpha                     =       0;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       255;
                gogglesOverlayBlue                      =       255;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            
            else if(class == 1)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       64;
                gogglesOverlayGreen                     =       128;
                gogglesOverlayBlue                      =       255;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 2)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       128;
                gogglesOverlayBlue                      =       64;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 3)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       232;
                gogglesOverlayGreen                     =       128;
                gogglesOverlayBlue                      =       255;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 4)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       232;
                gogglesOverlayGreen                     =       0;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 5)
            {
                gogglesOverlayAlpha                     =       164;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       0;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 6)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       64;
                gogglesOverlayBlue                      =       64;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 7)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       0;
                gogglesOverlayGreen                     =       232;
                gogglesOverlayBlue                      =       232;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 8)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       232;
                gogglesOverlayGreen                     =       128;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 10)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       32;
                gogglesOverlayBlue                      =       32;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
                
                
            }
            else if(class == 12)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       0;
                gogglesOverlayGreen                     =       32;
                gogglesOverlayBlue                      =       128;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
                
                
            }
            else if(class == 13)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       32;
                gogglesOverlayGreen                     =       32;
                gogglesOverlayBlue                      =       64;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
                
            }
            else if(class == 14)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       128;
                gogglesOverlayGreen                     =       128;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 15)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       0;
                gogglesOverlayGreen                     =       0;
                gogglesOverlayBlue                      =       255;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
                
                
            }
            else if(class == 16)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       16;
                gogglesOverlayBlue                      =       16;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 17)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       200;
                gogglesOverlayGreen                     =       0;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 18)
            {
                gogglesOverlayAlpha                     =       0;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       255;
                gogglesOverlayBlue                      =       255;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 19)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       0;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else if(class == 20)
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       0;
                gogglesOverlayGreen                     =       255;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            else
            {
                gogglesOverlayAlpha                     =       128;
                gogglesOverlayRed                       =       255;
                gogglesOverlayGreen                     =       255;
                gogglesOverlayBlue                      =       0;
                
                gogglesOverlayBitmap[alphaLocation]     =       gogglesOverlayAlpha;
                gogglesOverlayBitmap[redLocation]       =       gogglesOverlayRed;
                gogglesOverlayBitmap[greenLocation]     =       gogglesOverlayGreen;
                gogglesOverlayBitmap[blueLcoation]      =       gogglesOverlayBlue;
            }
            
            //if(class != 0) printf("%d ",class);
            
        }
    }


    
    CGImageRef      gogglesOverlaySrc                   =       CGBitmapContextCreateImage(gogglesOverlayCTX);
    
    vImage_Buffer   imageBuffer;
    
    vImage_Buffer   gogglesOverlaySrcBuffer;
    vImage_Buffer   gogglesOverlaySrcBufferRotate;
    vImage_Buffer   gogglesOverlayDestBuffer;
    
    
    CGFloat                 decodeArray[6]              =       {0.0,1.0,0.0,1.0,0.0,1.0};
    CGFloat                 background[3]               =       {0.0,0.0,0.0};
    Pixel_8888              pixelBackground             =       {0,255,255,255};
    
    vImage_CGImageFormat    cgFormat;
    cgFormat.bitsPerComponent                           =       8;
    cgFormat.bitsPerPixel                               =       32;
    cgFormat.colorSpace                                 =       CGColorSpaceCreateDeviceRGB();
    cgFormat.bitmapInfo                                 =       kCGImageAlphaFirst      |       kCGBitmapByteOrder32Little;
    cgFormat.version                                    =       0;
    cgFormat.decode                                     =       decodeArray;
    cgFormat.renderingIntent                            =       kCGRenderingIntentAbsoluteColorimetric;
    
    vImageBuffer_InitWithCGImage(&gogglesOverlaySrcBuffer, &cgFormat, nil, gogglesOverlaySrc, kvImagePrintDiagnosticsToConsole);
    vImageBuffer_InitWithCGImage(&gogglesOverlaySrcBufferRotate, &cgFormat, nil, gogglesOverlaySrc, kvImagePrintDiagnosticsToConsole);
    vImageBuffer_InitWithCGImage(&gogglesOverlayDestBuffer, &cgFormat, nil, image, kvImagePrintDiagnosticsToConsole);
    
    vImageRotate90_ARGB8888(&gogglesOverlaySrcBuffer, &gogglesOverlaySrcBufferRotate, 3, pixelBackground, kvImagePrintDiagnosticsToConsole);
    vImageHorizontalReflect_ARGB8888(&gogglesOverlaySrcBufferRotate, &gogglesOverlaySrcBufferRotate, kvImagePrintDiagnosticsToConsole);
    
    
    CGImageRef  gogglesOverlay                          =       vImageCreateCGImageFromBuffer(&gogglesOverlaySrcBufferRotate, &cgFormat, vImageRelease, nil, kvImagePrintDiagnosticsToConsole, NULL);

    if(overlayCTXCreated    ==      0)
    {
        //NSLog(@"Create Overlay context");
        gogglesOverlayWithImageCTX                      =       [ViewUtilities      createBitmapContext:CGImageGetWidth(image) pixelsHeight:CGImageGetHeight(image)];
        overlayCTXCreated   =       0;
    }
    else{
        //NSLog(@"Overlay saved.");
    }
    
    CGContextDrawImage(gogglesOverlayWithImageCTX, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGContextDrawImage(gogglesOverlayWithImageCTX, CGRectMake(0, 0, CGImageGetWidth(image) ,CGImageGetHeight(image)), gogglesOverlay);
    
    CGImageRelease(gogglesOverlay);
    gogglesOverlay                                      =       CGBitmapContextCreateImage(gogglesOverlayWithImageCTX);
    
    free(gogglesOverlaySrcBuffer.data);
    free(gogglesOverlaySrcBufferRotate.data);
    free(gogglesOverlayDestBuffer.data);
    
    void*       gogglesOverlayWithImageData     =       CGBitmapContextGetData(gogglesOverlayWithImageCTX);
    free(gogglesOverlayWithImageData);
    
    CGContextRelease(gogglesOverlayWithImageCTX);
    
    
    CGImageRelease(image);
    CGImageRelease(gogglesOverlaySrc);
    
    
    return gogglesOverlay;
}

-   (CGImageRef)    addWhiteEffect:(CGImageRef)image
{
    CGFloat                 decodeArray[6]          =       {0.0,1.0,0.0,1.0,0.0,1.0};
    CGFloat                 background[3]           =       {1.0,1.0,1.0};
    
    vImage_CGImageFormat    cgFormat;
    cgFormat.bitsPerComponent                       =       8;
    cgFormat.bitsPerPixel                           =       32;
    cgFormat.colorSpace                             =       CGColorSpaceCreateDeviceRGB();
    cgFormat.bitmapInfo                             =       kCGImageAlphaFirst      |       kCGBitmapByteOrder32Little;
    cgFormat.version                                =       0;
    cgFormat.decode                                 =       decodeArray;
    cgFormat.renderingIntent                        =       kCGRenderingIntentAbsoluteColorimetric;
    
    
    const uint8_t permuteMap[4]                         =       {3,0,0,0};
    
    vImage_YpCbCrPixelRange         pixelRange;
    vImage_YpCbCrToARGB             matrixToARGBInfo;
    vImage_ARGBToYpCbCr             matrixToYpCbCr;
    
    vImage_YpCbCrToARGBMatrix       matrixToARGB;
    
    matrixToARGB.Yp                                 =       2.0f;
    matrixToARGB.Cb_G                               =       -0.3441f;
    matrixToARGB.Cb_B                               =       1.772f;
    matrixToARGB.Cr_R                               =       1.402f;
    matrixToARGB.Cr_G                               =       -0.7141f;
    
    pixelRange.Yp_bias                              =       16;
    pixelRange.CbCr_bias                            =       128;
    pixelRange.YpRangeMax                           =       255;
    pixelRange.CbCrRangeMax                         =       240;
    pixelRange.YpMax                                =       255;
    pixelRange.YpMin                                =       0;
    pixelRange.CbCrMax                              =       255;
    pixelRange.CbCrMin                              =       0;
    
    vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_709_2, &pixelRange, &matrixToARGBInfo, kvImage420Yp8_CbCr8, kvImageARGB8888, kvImagePrintDiagnosticsToConsole);
    vImageConvert_ARGBToYpCbCr_GenerateConversion(kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2, &pixelRange, &matrixToYpCbCr, kvImageARGB8888, kvImage420Yp8_CbCr8, kvImagePrintDiagnosticsToConsole);
    
    vImageCVImageFormatRef  YpCbCrFormat            =   vImageCVImageFormat_Create(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, kvImage_ARGBToYpCbCrMatrix_ITU_R_709_2, kCVImageBufferChromaLocation_Center, CGColorSpaceCreateDeviceRGB(), 0);
    
    vImage_Buffer           srcBuffer;
    vImageBuffer_InitWithCGImage(&srcBuffer, &cgFormat, background, image, kvImagePrintDiagnosticsToConsole);
    
    
    vImageConverterRef      converter               =       vImageConverter_CreateForCGToCVImageFormat(&cgFormat, YpCbCrFormat, background, kvImagePrintDiagnosticsToConsole, NULL);
    
    
    vImage_Buffer           destBuffer[2];
    
    CVPixelBufferRef        pixelBuffer;
    CVPixelBufferCreate(NULL, CGImageGetWidth(image), CGImageGetHeight(image), kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, NULL, &pixelBuffer);
    
    vImageBuffer_InitForCopyToCVPixelBuffer(destBuffer, converter, pixelBuffer, kvImagePrintDiagnosticsToConsole);
    
    vImageConvert_ARGB8888To420Yp8_CbCr8(&srcBuffer, &destBuffer[0], &destBuffer[1], &matrixToYpCbCr, permuteMap, kvImagePrintDiagnosticsToConsole);
    
    
    vImage_Buffer           lumaSource[2];
    vImage_Buffer           lumaDestination;
    
    lumaSource[0]                                      =        destBuffer[0];
    lumaSource[1]                                      =        destBuffer[1];
    
    vImageBuffer_InitWithCGImage(&lumaDestination, &cgFormat, background, image, kvImagePrintDiagnosticsToConsole);
        
    
    const uint8_t           alpha                       =       0;
    
    
    const uint8_t YpCbCrPermute[4]                      =       {3,0,3,3};
    vImageConvert_420Yp8_CbCr8ToARGB8888(&lumaSource[0],&lumaSource[1],&lumaDestination,&matrixToARGBInfo,YpCbCrPermute,alpha,kvImagePrintDiagnosticsToConsole);
    

    CGImageRef              vImage                  =       vImageCreateCGImageFromBuffer(&lumaDestination, &cgFormat, vImageRelease , nil, kvImagePrintDiagnosticsToConsole, NULL);
    
    
    
    CGContextRef            vImageCTX               =       [ViewUtilities          createBitmapContext:CGImageGetWidth(vImage) pixelsHeight:CGImageGetHeight(vImage)];
    
    CGContextDrawImage(vImageCTX, CGRectMake(0, 0, CGBitmapContextGetWidth(vImageCTX), CGBitmapContextGetHeight(vImageCTX)), vImage);
    
    
    uint8_t                 whiteAlpha;
    uint8_t                 whiteRed;
    uint8_t                 whiteGreen;
    uint8_t                 whiteBlue;
    
    uint8_t*                whiteOutBitmap          =       CGBitmapContextGetData(vImageCTX);
    CGBitmapInfo            info                    =       CGBitmapContextGetBitmapInfo(vImageCTX);
    
    for(int i = 0; i < CGBitmapContextGetWidth(vImageCTX) * CGBitmapContextGetHeight(vImageCTX) * 4; i= i + 4)
    {
        whiteAlpha              =       whiteOutBitmap[i];
        whiteBlue               =       whiteOutBitmap[i+1];
        whiteGreen              =       whiteOutBitmap[i+2];
        whiteRed                =       whiteOutBitmap[i+3];
        
        uint8_t     largestComp;
        
        if(whiteRed >= whiteGreen && whiteRed >= whiteBlue)     largestComp = whiteRed;
        if(whiteBlue >= whiteRed && whiteBlue >= whiteGreen)    largestComp = whiteBlue;
        if(whiteGreen >= whiteRed && whiteGreen >= whiteBlue)   largestComp = whiteGreen;
        else largestComp = whiteBlue;
        
        
        if(largestComp < 64)        largestComp = largestComp + largestComp*0.7;
        else if(largestComp < 200)  largestComp = largestComp + largestComp*0.35;
        else if(largestComp >=200)  largestComp = largestComp + largestComp*0.2;
        if(largestComp > 255)       largestComp = 255;
        
        if(whiteAlpha       >   128)    whiteAlpha = whiteAlpha - whiteAlpha*0.25;
        else if(whiteAlpha  >   200)    whiteAlpha = whiteAlpha - whiteAlpha*0.12;
        
        if(whiteAlpha < 32)             whiteAlpha = whiteAlpha + whiteAlpha*0.75;
        
        whiteAlpha              =       whiteAlpha;        //0 - invisible, 255 - opaque
        whiteRed                =       whiteBlue;
        whiteGreen              =       whiteBlue;
        whiteBlue               =       whiteBlue;
        
        if (largestComp < 4)                largestComp = largestComp + 3;
        else if(largestComp < 8)            largestComp = largestComp + 5;
        else if(largestComp  < 16)               largestComp = largestComp * 16.0;
        else if(largestComp  < 32)          largestComp = largestComp * 8.0;
        else if(largestComp  < 64)          largestComp = largestComp * 4.0;

        whiteOutBitmap[i]       =       whiteAlpha;
        whiteOutBitmap[i+1]     =       largestComp;
        whiteOutBitmap[i+2]     =       largestComp;
        whiteOutBitmap[i+3]     =       largestComp;
        
        
        if(i%CGBitmapContextGetWidth(vImageCTX) == 0)
        {
            //printf("\n");
        }
    }
    
    CGContextRef            whiteOutCTX             =       CGBitmapContextCreate((void*)whiteOutBitmap, CGBitmapContextGetWidth(vImageCTX), CGBitmapContextGetHeight(vImageCTX), CGBitmapContextGetBitsPerComponent(vImageCTX), CGBitmapContextGetBytesPerRow(vImageCTX), CGBitmapContextGetColorSpace(vImageCTX), CGBitmapContextGetBitmapInfo(vImageCTX));
    
    CGImageRef              whiteOut                =       CGBitmapContextCreateImage(whiteOutCTX);
    
    
    //white backgound bitmap
    /*
    if(whiteBackground == nil)
    {
    uint8_t                 *whiteBackgroundBitmap  =       malloc(CGBitmapContextGetWidth(vImageCTX) * CGBitmapContextGetHeight(vImageCTX) * 4);

    for(int i = 0; i < CGBitmapContextGetWidth(vImageCTX) * CGBitmapContextGetHeight(vImageCTX) * 4; i= i + 4)
    {
        whiteBackgroundBitmap[i]                    =       255;
        whiteBackgroundBitmap[i + 1]                =       255;
        whiteBackgroundBitmap[i + 2]                =       255;
        whiteBackgroundBitmap[i + 3]                =       255;
    }
    CGContextRef            whiteBackgroundCTX      =       CGBitmapContextCreate(whiteBackgroundBitmap, CGBitmapContextGetWidth(vImageCTX), CGBitmapContextGetHeight(vImageCTX), CGBitmapContextGetBitsPerComponent(vImageCTX), CGBitmapContextGetBytesPerRow(vImageCTX), CGBitmapContextGetColorSpace(vImageCTX), CGBitmapContextGetBitmapInfo(vImageCTX));

    CGImageRef              whiteBackground         =       CGBitmapContextCreateImage(whiteBackgroundCTX);




    vImage_Buffer           whiteBackgroundBuffer;
    vImageBuffer_InitWithCGImage(&whiteBackgroundBuffer, &cgFormat, nil, whiteBackground, kvImagePrintDiagnosticsToConsole);

    vImage_Buffer           whiteOutBuffer;
    vImageBuffer_InitWithCGImage(&whiteOutBuffer, &cgFormat, nil, whiteOut, kvImagePrintDiagnosticsToConsole);

    CGImageRef              whiteOutWithWhiteBackground = vImageCreateCGImageFromBuffer(&whiteOutBuffer, &cgFormat, vImageRelease, nil, kvImagePrintDiagnosticsToConsole, nil);
    */
     
    free(destBuffer[0].data);
    free(destBuffer[1].data);
    free(srcBuffer.data);
    free(lumaDestination.data);

    free(whiteOutBitmap);

    
    CFRelease(pixelBuffer);
    
    CGContextRelease(vImageCTX);
    CGContextRelease(whiteOutCTX);
    CGImageRelease(image);
    CGImageRelease(vImage);

    
    return whiteOut;
}

-   (CGImageRef)    addvImageEffect:(CGImageRef)image
{
    //NSLog(@"AddVimageEffect");
    vImage_Buffer           destBuffer;
    
    CGFloat                 decodeArray[6]          =       {0.0,1.0,0.0,1.0,0.0,1.0};
    CGFloat                 background[3]           =       {1.0,1.0,1.0};
    
    vImage_CGImageFormat    cgFormat;
    cgFormat.bitsPerComponent                       =       8;
    cgFormat.bitsPerPixel                           =       32;
    cgFormat.colorSpace                             =       CGColorSpaceCreateDeviceRGB();
    cgFormat.bitmapInfo                             =       kCGImageAlphaFirst      |       kCGBitmapByteOrder32Little;
    cgFormat.version                                =       0;
    cgFormat.decode                                 =       decodeArray;
    cgFormat.renderingIntent                        =       kCGRenderingIntentAbsoluteColorimetric;
    
    vImageBuffer_InitWithCGImage(&destBuffer, &cgFormat, background, image, 0);
    
    vImageEqualization_ARGB8888(&destBuffer, &destBuffer, 0);
    
    CGImageRef  vImage = vImageCreateCGImageFromBuffer(&destBuffer, &cgFormat, vImageRelease, nil, 0, NULL);
    
    free(destBuffer.data);
    CGImageRelease(image);
    return      vImage;
}

-   (void)          photoReceived:(CGImageRef)image
{
    NSLog(@"photoReceived");
    CGImageRef      processedPhoto      =       [self                   processPhoto:image];
        
    //Save photo
    PhotoModel      *photo              =       [[PhotoModel             alloc]initWithFileURL:[[DirectoryController photosDirectoryURL] URLByAppendingPathComponent:[[DirectoryController createNextPhotoName]stringByAppendingString:@".tiff"]]];
    
    //NSLog(@"photo URL %@",photo.fileURL);
    photo.photo                 =       processedPhoto;
    [photo  saveToURL:photo.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if(success){
            [photo  closeWithCompletionHandler:^(BOOL success) {
                if(success);//NSLog(@"Photo successfully closed.");
                else NSLog(@"Usage: Init, open, save, close.");
                
                //[photo releaseSave];
                //ReloadVC if saved photos is selected
                
                photo.photoID                           =       [DirectoryController    getPhotoNumber:photo.fileURL];
                
                PhotoView       *currentPhotoView       =       [[PhotoView alloc]init];
                currentPhotoView.delegate               =       self;
                currentPhotoView.contentMode            =       UIViewContentModeScaleAspectFit;
                currentPhotoView.photoID                =       photo.photoID;
                UIImage         *UIphoto                =       [UIImage        imageWithCGImage:photo.photo scale:1.0 orientation:UIImageOrientationRight];
                [currentPhotoView       setImage:[UIphoto       imageByPreparingThumbnailOfSize:CGSizeMake(1080*.1, 1920*.1)]];
                
                [self.photoStackViewSource                      addObject:currentPhotoView];
                
                [self.savedPhotos       addObject:photo];
                
                if(self.savesButtonSelected)
                {
                    self.scrollView.contentSize         =       CGSizeMake(3.0 + (self->scrollViewImageWidth + 3.0) * ([DirectoryController getNumPhotos]), 0);
                    [currentPhotoView   setHidden:NO];
                }
                else
                {
                    [currentPhotoView   setHidden:YES];
                }
                
                [self                   loadStackView];

                //NSLog(@"Set photo to frame view");
                
                //Set photo review
                UIImage *photoImage                 =       [[UIImage           alloc]initWithCGImage:photo.photo scale:1.0 orientation:UIImageOrientationRight];

                [self.currentFrameView                      setImage:photoImage];
                NSTimer         *photoTimer         =       [NSTimer        scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    self->photoSelected             =       -1;
                }];
                
                CGImageRelease(photo.photo);
                [photo releaseSave];
            }];
        }
        else NSLog(@"Usage: Init, open, save.");
    }];

    

    
    
}

-   (CGImageRef)    processPhoto:(CGImageRef)photo
{
    
    CIContext                   *cictx              =       [[CIContext     alloc]init];
    CIImage                     *portraitImage      =       [[CIImage       alloc]initWithCGImage:photo];
    
    portraitImage                                   =      ([portraitImage      imageByApplyingOrientation:kCGImagePropertyOrientationRight]);
    
    CGImageRef                  processedPhoto      =       [cictx              createCGImage:portraitImage fromRect:portraitImage.extent];
    
    CGImageRelease(photo);
    
    if(self.eyeEffectSelected           ==      1)
    {
        self.leftPupilPosition          =       CGPointMake(-1, -1);
        self.rightPupilPosition         =       CGPointMake(-1, -1);
        processedPhoto                  =       [self       addEyeEffect:processedPhoto];
    }
    else if(self.whiteEffectSelected    ==      1)
    {
        processedPhoto                  =       [self       addWhiteEffect:processedPhoto];
    }
    else if(self.siloEffectSelected     ==      1)
    {
        processedPhoto                  =       [self       addSiloEffect:processedPhoto];
    }
    else if(self.vImageEffectSelected   ==      1)
    {
        processedPhoto                  =       [self       addvImageEffect:processedPhoto];
    }
    
    
    portraitImage                       =       [[CIImage       alloc]initWithCGImage:processedPhoto];
    
    portraitImage                       =      ([portraitImage      imageByApplyingOrientation:kCGImagePropertyOrientationLeft]);
    
    processedPhoto                      =       [cictx              createCGImage:portraitImage fromRect:portraitImage.extent];
    
    
    return processedPhoto;
}

//AV
-   (void)          enableAVCapture
{
    [self           verifyAVCaptureAuthorization];
    
    captureSession                                          =           [[AVCaptureSession          alloc]init];
    position                                                =           kDevicePositionFront;
    //If new iPhone avaialable, set to trueDepth Camera
    frontCamera                                             =           kDeviceFrontWideAngleCamera;
    //If new iPhone available, set to ultraWide
    backCamera                                              =           kDeviceUltraWide;
    
    
    //Selects AVCapture devices iosCamera and iosMicrophone
    [self           selectInputs];
    //Adds inputs and outputs to the session
    [self           setupAVCameraSession];
    
    captureThread                                           =           [[NSThread                  alloc]initWithTarget:captureSession selector:@selector(startRunning) object:nil];
    
    [captureThread  start];
}


-   (void)          verifyAVCaptureAuthorization
{
    //NSLog(@"Authorization");
    AVAuthorizationStatus           cameraStatus            =           [AVCaptureDevice                authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus           microphoneStatus        =           [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch(cameraStatus)
    {
        case AVAuthorizationStatusAuthorized:
            break;
        case AVAuthorizationStatusDenied:
            NSLog(@"Camera authorization: denied.");
            break;
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"Determining status...");
            [AVCaptureDevice        requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted) NSLog(@"Authorized.");
                else NSLog(@"Denied.");
            }];
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"Restricted.");
            break;
        default:
            NSLog(@"Status not found.");
            break;
    }
    
    switch(microphoneStatus)
    {
        case AVAuthorizationStatusAuthorized:
            break;
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"Determining status...");
            [AVCaptureDevice        requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if(granted) NSLog(@"Authorized.");
                else NSLog(@"Denied.");
            }];
            break;
        case AVAuthorizationStatusDenied:
            NSLog(@"Microhpone authorization: denied.");
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"Restricted.");
            break;
        default:
            NSLog(@"Status not found.");
            break;
    }
}

-   (void)          selectInputs;
{
    availableCameraCaptureDevices      =   [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInUltraWideCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInTelephotoCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInDualCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInDualWideCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInTripleCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInLiDARDepthCamera,
                                                                                                                                                           AVCaptureDeviceTypeBuiltInTrueDepthCamera
                                                                                                                                                         ] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    
    AVCaptureDeviceDiscoverySession             *availableMicrophoneCaptureDevices  =   [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInMicrophone] mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
    
    NSArray <AVCaptureDevice*>                  *cameraDevices                      =       availableCameraCaptureDevices.devices;
    
    AVCaptureDevice                             *cameraSelection;
    
    if(position                                 ==              kDevicePositionFront)
    {
        for(AVCaptureDevice *device in cameraDevices)
        {
            if(device.position == AVCaptureDevicePositionFront)
            {
                //NSLog(@"Found front facing camera %@",device.deviceType);
                if(device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera && frontCamera == kDeviceFrontWideAngleCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInTrueDepthCamera && frontCamera == kDeviceTrueDepthCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else
                {
                    //NSLog(@"Front camera selection usage: device type && CameraType.  Device: %@",device.deviceType);
                }
            }
        }
    }
    else if(position                            ==              kDevicePositionBack)
    {
        for(AVCaptureDevice *device in cameraDevices)
        {
            if(device.position == AVCaptureDevicePositionBack)
            {
                //NSLog(@"Found back facing camera %@",device.deviceType);

                if(device.deviceType == AVCaptureDeviceTypeBuiltInTelephotoCamera       &&  backCamera      ==  kDeviceTelephotoCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInDualCamera       &&  backCamera      ==  kDeviceDualCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInDualWideCamera   &&  backCamera      ==  kDeviceDualWideCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInTripleCamera     &&  backCamera      ==  kDeviceTripleCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInUltraWideCamera  &&  backCamera      ==  kDeviceUltraWide)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInLiDARDepthCamera &&  backCamera      ==  kDeviceLiDarDepth)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else if(device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera)
                {
                    cameraSelection             =               device;
                    cameraChanged               =               1;
                }
                else
                {
                    //NSLog(@"Back camera selection usage: device type && CameraType");
                }
            }
        }
    }
    
    iosCamera               =           [AVCaptureDevice        deviceWithUniqueID:cameraSelection.uniqueID];
    iosMicrophone           =           [AVCaptureDevice        deviceWithUniqueID:availableMicrophoneCaptureDevices.devices[0].uniqueID];
    
    
}

-   (void)setupAVCameraSession
{
    AVCaptureDeviceInput        *iosCameraInput     =       [AVCaptureDeviceInput       deviceInputWithDevice:iosCamera error:NULL];
    AVCaptureDeviceInput        *iosMicrophoneInput =       [AVCaptureDeviceInput       deviceInputWithDevice:iosMicrophone error:NULL];
    
    [captureSession             beginConfiguration];
    
    if([captureSession          canAddInput:iosCameraInput])
    {
        [captureSession         addInput:iosCameraInput];
    }
    else
    {
        NSLog(@"Usage: Capture session with iosCameraInput");
    }
    if([captureSession          canAddInput:iosMicrophoneInput])
    {
        [captureSession         addInput:iosMicrophoneInput];
    }
    
    videoDataOutput                                 =       [AVCaptureVideoDataOutput   new];
    NSDictionary                *videoSettings      =       @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    [videoDataOutput            setAlwaysDiscardsLateVideoFrames:YES];
    
    dispatch_queue_t            videoDataOutputQueue=       dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput            setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if([captureSession          canAddOutput:videoDataOutput]) [captureSession      addOutput:videoDataOutput];
    else NSLog(@"Usage: Cpature session with video data output");
    
    photoOutput                                     =       [AVCapturePhotoOutput   new];
    if ([captureSession         canAddOutput:photoOutput]) [captureSession      addOutput:photoOutput];
    else NSLog(@"Usage Capture session with photo output");
    
    //NSLog(@"Capture session connections: %@",[captureSession        connections]);
    [[[captureSession           connections]objectAtIndex:0]setVideoOrientation:AVCaptureVideoOrientationPortrait];

    [captureSession             commitConfiguration];
    
}

//Buttons
- (IBAction)flipButton
{
    //NSLog(@"Flip button pressed.");
    [self       setCameraChanged];
    
    if(photoSelected == -1 && videoSelected == -1){
        
        cameraChanged   =   1;
        
        if(position     ==  kDevicePositionFront) position = kDevicePositionBack;
        else position   =   kDevicePositionFront;
        
        [captureSession     beginConfiguration];
        
        for(AVCaptureDeviceInput    *input      in     captureSession.inputs)
        {
            [captureSession     removeInput:input];
        }
        
        [self               selectInputs];
        
        AVCaptureDeviceInput        *iosCameraInput     =       [AVCaptureDeviceInput   deviceInputWithDevice:iosCamera error:NULL];
        AVCaptureDeviceInput        *iosMicrophoneInput =       [AVCaptureDeviceInput   deviceInputWithDevice:iosMicrophone error:NULL];
        
        if([captureSession  canAddInput:iosCameraInput])[captureSession addInput:iosCameraInput];
        else NSLog(@"Usage: Capture session iOSCameraInput");
        
        if([captureSession canAddInput:iosMicrophoneInput])[captureSession addInput:iosMicrophoneInput];
        else NSLog(@"*Usage: Capture session iOSMicrophoneInput");
        
        [[[captureSession   connections]objectAtIndex:0]setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [captureSession     commitConfiguration];
    }
    else{
        photoSelected = -1;
        videoSelected = -1;
    }
}

- (IBAction)SavesButton {
    NSLog(@"Saves button.");
    if(self.savesButtonSelected             ==      0)
    {
        //reload the stack view when new photos have arrived
        if(self.updateSavedPhotos)
        {
            [self reloadVC];
            [self loadVC];
        }
        
        if(self.effectsButtonSelected == 1){
            [self   hideEffectsStackView];
        }
        else if(self.lensButtonSelected == 1)
        {
            [self hideLensStackView];
        }
        
        self.savesButtonSelected            =       1;
        self.effectsButtonSelected          =       0;
        self.lensButtonSelected             =       0;
        
        
        self.EffectsButtonProperty.tintColor=       [UIColor        grayColor];
        self.LensButtonProperty.tintColor   =       [UIColor        grayColor];
        self.SavesButtonProperty.tintColor  =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        
        [self               showSavedPhotosStackView];
    }
    else
    {
        ;
    }
}
- (IBAction)VideoButton {
    NSLog(@"Video button.");
    
    if(settings.whiteOutPhotoSaveEnabled == NO && self.whiteEffectSelected)
    {
        //NSLog(@"Enable white out");
        return;
    }
    
    else{
        
        
        if(self.videoButtonSelected             ==      0)
        {
            
            
            [self                   initRecording];
            
            
            if(settings.audioEnabled == YES)
            {
                [self                   setupAudioCapture];
                [recorder               record];
            }
            
            
            
            //videoSelected                       =       _currentVideoDir;
            self.recording                      =       1;
            self.videoButtonSelected            =       1;
            self.VideoButtonProperty.tintColor  =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        }
        else
        {
            if(settings.audioEnabled == YES)
            {
                [recorder               stop];
            }
            self.totalFrames                    =       self.currentVideoSaveBlock * self.framesPerSaveBlock;
            //NSLog(@"Total frames (%d) = (%d) * (%d)",self.totalFrames, self.currentVideoSaveBlock, self.framesPerSaveBlock);
            
            //self.recording                      =       0;    //recording stopped from recording save
            videoSelected                       =       -1;
            self.videoButtonSelected            =       0;
            self.VideoButtonProperty.tintColor  =       [UIColor        systemGrayColor];
            
        }
    }
    
}
- (IBAction)SettingsButton
{
    //NSLog(@"Settings button.");
}
- (IBAction)EffectsButton:(id)sender {
    //NSLog(@"Effects button.");
    if(self.effectsButtonSelected               ==      0)
    {
        if(self.savesButtonSelected == 1) [self hideSavedPhotosStackView];
        else if(self.lensButtonSelected == 1) [self hideLensStackView];
        

        self.effectsButtonSelected              =       1;
        self.savesButtonSelected                =       0;
        self.lensButtonSelected                 =       0;
        
        self.SavesButtonProperty.tintColor      =       [UIColor        grayColor];
        self.LensButtonProperty.tintColor       =       [UIColor        grayColor];
        self.EffectsButtonProperty.tintColor    =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        
        //[self reloadVC];
        [self       loadEffectsStackView];
        [self       showEffectsStackView];

    }
    else
    {
//        self.effectsButtonSelected              =       0;
//        self.EffectsButtonProperty.tintColor    =       [UIColor        systemGrayColor];
//
//        [self       hideEffectsStackView];
    }
    
}
- (IBAction)PlayButton
{
    //NSLog(@"Play button.");
    
    [systemSharedAudioSession       setCategory:AVAudioSessionCategorySoloAmbient error:NULL];
    
    videoSelected                               =       self.currentVideoDir;
    self.currentVideoSaveBlock                  =       0;
    [self   prepareSaveBlock:0];
    [self   playSaveBlock:0];
    [audioPlayer    play];
    

}

-   (void)prepareSaveBlock:(NSNumber *)saveBlock
{
    //NSLog(@"Prepare save block %d",saveBlock.intValue);
    
    self.currentVideoSaveBlock                  =       saveBlock.intValue;
    RunLoopContext  *theContext                 =       [sourcesToPingPlayback  objectAtIndex:saveBlock.intValue];
    RunLoopSource   *theSource                  =       [theContext     source];
    
    [theSource      addCommand:1 withData:[NSNumber     numberWithInt:30]]; //Set total frames
    [theSource      addCommand:6 withData:[NSNumber     numberWithInt:30]]; //Set rames per save block
    [theSource      addCommand:3 withData:[NSNumber     numberWithInt:saveBlock.intValue]];
    //[theSource      fireAllCommandsOnRunLoop:theContext.runLoop];
    
    [theSource      addCommand:7 withData:[NSNumber     numberWithInt:self.currentVideoDir]];
    [theSource      fireAllCommandsOnRunLoop:theContext.runLoop];

}

-   (void)playSaveBlock:(NSNumber *)saveBlock
{
    //NSLog(@"Play save block %d (num in Dir: %d)",saveBlock.intValue,[DirectoryController getNumVideosInVideoDirectory:self.currentVideoDir]);
    
    self.currentVideoSaveBlock                  =       saveBlock.intValue;
    RunLoopContext  *theContext                 =       [sourcesToPingPlayback  objectAtIndex:saveBlock.intValue];
    RunLoopSource   *theSource                  =       [theContext     source];
   

    [theSource      addCommand:8 withData:[NSNumber     numberWithInt:0]];
    [theSource      fireAllCommandsOnRunLoop:theContext.runLoop];
    
    //Prepare next save block
    int     numExtraItemsInDir;
    if([[[DirectoryController videoDir:self.currentVideoDir]URLByAppendingPathComponent:@"Audio"] checkPromisedItemIsReachableAndReturnError:NULL])
    {
        numExtraItemsInDir = 3;
    }
    else
    {
        numExtraItemsInDir = 2;
    }
    

    if(saveBlock.intValue        ==      [DirectoryController    getNumVideosInVideoDirectory:self.currentVideoDir] - numExtraItemsInDir)
    {
        //NSLog(@"Last save block");
        [self       expungePlaybackThreads];
    }
    else
    {
        //prepare for next save block
        VideoThread     *nextThread                 =       [[VideoThread       alloc]init];
        nextThread.threadID                         =       1;
        [VideoThread    detachNewThreadSelector:@selector(detatchedMain:) toTarget:nextThread withObject:(id)self];
    }
    
}





- (IBAction)LensButton:(id)sender {
    NSLog(@"Lens button.");
    
    if(self.lensButtonSelected                  ==      0)
    {
        if(self.savesButtonSelected == 1) [self hideSavedPhotosStackView];
        else if(self.effectsButtonSelected == 1) [self hideEffectsStackView];
        
        self.lensButtonSelected                 =       1;
        self.savesButtonSelected                =       0;
        self.effectsButtonSelected              =       0;
        
        self.EffectsButtonProperty.tintColor    =       [UIColor        grayColor];
        self.SavesButtonProperty.tintColor      =       [UIColor        grayColor];
        self.LensButtonProperty.tintColor       =       [UIColor        colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        
        [self       loadLensStackView];
        [self       showLensStackView];
        
    }
    else
    {
        ;
    }
}



- (IBAction)upButton {
    NSLog(@"Up button.");
    
    if(frameTransformed == 1)
    {
        frameTransformed    =   0;
        
        //Transform photo view
        //self.topFrameViewLayoutConstraint.constant          +=   self.currentFrameView.frame.origin.y;
        self.topFrameViewLayoutConstraint.constant          =       [[self       view]safeAreaInsets].top;

        
        self.heightFrameViewLayoutConstraint.constant       =   [UIScreen mainScreen].bounds.size.height;
        
        //self.heightFrameViewLayoutConstraint.constant       =  [UIScreen mainScreen].bounds.size.width / self.view.frame.size.width;
        
        [self                           layoutFullscreenView];
        
        //Hide scroll view
        [self.scrollView                setHidden:YES];
        
        //Hide buttons
        [self.SavesButtonProperty       setHidden:YES];
        [self.CameraButtonProperty      setHidden:YES];
        [self.VideoButtonProperty       setHidden:YES];
        [self.EffectsButtonProperty     setHidden:YES];
        [self.LensButtonProperty        setHidden:YES];
        [self.SettingsButtonProperty    setHidden:YES];
        [self.PlayButtonProperty        setHidden:YES];
        
        [self.TIFF                      setHidden:YES];
        [self.RGB                       setHidden:YES];

    }
    else if(frameTransformed == 0)
    {
        frameTransformed    =   1;
        //NSLog(@"Leading: %f frame: %f screen: %f",(self.currentFrameView.frame.size.width - [UIScreen mainScreen].bounds.size.width),self.currentFrameView.frame.size.width,[UIScreen mainScreen].bounds.size.width);

        
        //Transform photo view
        //-1*[screen width -(photo width)]/2
        self.leadingFrameViewLayoutConstraint.constant      =   -1*([UIScreen mainScreen].bounds.size.width - (frameTransformViewHeight * 1080/1920))/2;
        self.topFrameViewLayoutConstraint.constant          =   0;

        self.heightFrameViewLayoutConstraint.constant       =   frameTransformViewHeight;
        
        //Show scroll view
        [self.scrollView                setHidden:NO];
        
        //Show buttons
        [self.SavesButtonProperty       setHidden:NO];
        [self.CameraButtonProperty      setHidden:NO];
        [self.VideoButtonProperty       setHidden:NO];
        [self.EffectsButtonProperty     setHidden:NO];
        [self.LensButtonProperty        setHidden:NO];
        [self.SettingsButtonProperty    setHidden:NO];
        [self.PlayButtonProperty        setHidden:YES];
        
        [self.TIFF                      setHidden:NO];
        [self.RGB                       setHidden:NO];


    }
    
}
- (IBAction)CameraButton {
    photoSelected = -1;
}
//Delegates

-   (void)didUpdateLongVideoEnabled:(SettingsModel *)receivedSettings
{
    //NSLog(@"Did update settings");
    settings        =       receivedSettings;
}
-   (void)didUpdateAudioEnabled:(SettingsModel *)receivedSettings
{
    settings        =       receivedSettings;
}
-   (void)didUpdateWhiteOutSaveEnabled:(SettingsModel *)receivedSettings
{
    settings        =       receivedSettings;
}

//Button view delegate
-   (void)didPressButton
{
    //NSLog(@"Capture Button Pressed");
        
    NSDictionary                *format             =           @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    AVCapturePhotoSettings      *photoSettings      =           [AVCapturePhotoSettings         photoSettingsWithFormat:format];
    
    
    if(photoSelected == -1 && videoSelected == -1)
    {
        if(settings.whiteOutPhotoSaveEnabled == NO && self.whiteEffectSelected)
        {
            //NSLog(@"Enable white out");
        }
        else
        {
            [photoOutput                capturePhotoWithSettings:photoSettings delegate:self];
        }
    }
    else{
        photoSelected = -1;
        videoSelected = -1;
    }
}

//Photo view delegate
-   (void)  didTapPhoto:(NSNumber*)photo
{
    int photoNumber     =       photo.intValue;
    //NSLog(@"Tapped photo number: %d", photoNumber);
    
    //Set the photo selected to the photo number to select the photo, activate the photo view, and deactivate the camera view
    photoSelected                                   =           photoNumber;
    

    //Change the video dir when selected photo is the preview to a video
    int *   videoDirNums                            =           malloc(sizeof(int) * [DirectoryController getVideoDirectoryCount]);
    int *   photoNums                               =           malloc(sizeof(int) * [DirectoryController getVideoDirectoryCount]);
    
    [DirectoryController        previewPhotoArrayWithVideoDirNums:&videoDirNums photoNum:&photoNums];
    
    int videoFound                                  =           0x0;
    
    for(int i = 0; i < [DirectoryController getVideoDirectoryCount]; i++)
    {
        if(photoSelected            ==      photoNums[i])
        {
            _currentVideoDir            =       videoDirNums[i];
            videoSelected               =       self.currentVideoDir;
            
            audioPlayer             =       [[AVAudioPlayer      alloc]initWithContentsOfURL:[[DirectoryController videoDir:self.currentVideoDir]URLByAppendingPathComponent:@"Audio"] error:NULL];
            
            videoFound                  =       0x1;
            //NSLog(@"Tapped video number: %d",self.currentVideoDir);
        }
        else
        {
            videoSelected               =       -1;
        }
    }
    
    if(videoFound == 0x1)
    {
        [self.PlayButtonProperty            setHidden:NO];
    }
    else
    {
        [self.PlayButtonProperty            setHidden:YES];
    }
    
    
    //Correct the orientation
    
    //Search for the image coooresponding to the photo selected
    for (int i = 0; i < self.savedPhotos.count; i++)
    {
        if(photoSelected == [self.savedPhotos       objectAtIndex:i].photoID){
            
            PhotoModel          *fullResolutionSave =           [[PhotoModel         alloc]initWithFileURL:[self.savedPhotos objectAtIndex:i].fileURL];
            [fullResolutionSave     openWithCompletionHandler:^(BOOL success) {
                if(success)
                {
                    self.currentFrameView.image             =           [UIImage            imageWithCGImage:fullResolutionSave.photo scale:1.0 orientation:UIImageOrientationRight];
                    [fullResolutionSave closeWithCompletionHandler:^(BOOL success) {
                        if(success)
                        {
                            CGImageRelease(fullResolutionSave.photo);
                        }
                        else NSLog(@"Usage: Init full resolution photo from save in memory, open the photo, set view image, close.");
                    }];
            
                }
                else NSLog(@"Usage: Init full resolution photo from save in memory, open.");
            }];
        }
    }
}
//Lens view delegate
-   (void)didTapLens:(int)lensNumber
{
    //NSLog(@"Tapped lens number: %d",lensNumber);
    if(lensNumber == kDeviceFrontWideAngleCamera || lensNumber == kDeviceTrueDepthCamera)
    {
        frontCamera                 =       lensNumber;
        position                    =       kDevicePositionFront;
    }
    else if(lensNumber == kDeviceUltraWide || lensNumber == kDeviceTelephotoCamera || lensNumber == kDeviceDualCamera || lensNumber == kDeviceDualWideCamera || lensNumber == kDeviceTripleCamera || lensNumber == kDeviceLiDarDepth || lensNumber == kDeviceBackWideAngle)
    {
        backCamera                  =       lensNumber;
        position                    =       kDevicePositionBack;
    }
    else
    {
        NSLog(@"Usage: Compare lensNumber to every available lens");
    }
    //Change lens
    [captureSession         beginConfiguration];
    
    for(AVCaptureDeviceInput        *input  in      captureSession.inputs)
    {
        [captureSession     removeInput:input];
    }
    
    [self       selectInputs];
    
    AVCaptureDeviceInput    *iosCameraInput         =       [AVCaptureDeviceInput       deviceInputWithDevice:iosCamera error:NULL];
    AVCaptureDeviceInput    *iosMicrophoneInput     =       [AVCaptureDeviceInput       deviceInputWithDevice:iosMicrophone error:NULL];
    
    if([captureSession      canAddInput:iosCameraInput])[captureSession                 addInput:iosCameraInput];
    else NSLog(@"Usage: Capture session iOSCameraInput");
    
    if([captureSession      canAddInput:iosMicrophoneInput])[captureSession             addInput:iosMicrophoneInput];
    else NSLog(@"Usage: Capture session iOSMicrophoneInput");
    
    [[[captureSession        connections]objectAtIndex:0]setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [captureSession         commitConfiguration];
    
}

//Effect view delegate
-   (void)didTapEffect:(EffectType)effectID
{
    //NSLog(@"Did tap effect %d",effectID);
    if(effectID == kEffectEyes              &&  self.eyeEffectSelected == 0)
    {
        self.eyeEffectSelected      =       1;
    }
    else if(effectID == kEffectEyes         &&  self.eyeEffectSelected == 1)
    {
        self.eyeEffectSelected      =       0;
    }
    else if(effectID == kEffectColorWhite   &&  self.whiteEffectSelected == 0)
    {
        self.whiteEffectSelected    =       1;
    }
    else if(effectID == kEffectColorWhite   &&  self.whiteEffectSelected == 1)
    {
        self.whiteEffectSelected    =       0;
    }
    else if(effectID == kEffectSilo         &&  self.siloEffectSelected == 0)
    {
        self.siloEffectSelected     =       1;
    }
    else if(effectID == kEffectSilo         &&  self.siloEffectSelected == 1)
    {
        self.siloEffectSelected     =       0;
    }
    else if(effectID == kEffectVImage       &&  self.vImageEffectSelected == 0)
    {
        self.vImageEffectSelected   =       1;
    }
    else if(effectID == kEffectVImage       &&  self.vImageEffectSelected == 1)
    {
        self.vImageEffectSelected   =       0;
    }
    
}

//Photo output delegate
-   (void)  captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error
{
    //NSLog(@"Received photo");
    photoSelected                               =       1;
    
    CVImageBufferRef        imageBuffer         =       photo.pixelBuffer;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    vImage_Buffer           srcBuffer;
    
    vImage_CGImageFormat    cgFormat;
    CGFloat                 decodeArray[6]      =       {0.0,1.0,0.0,1.0,0.0,1.0};
    CGFloat                 background[3]       =       {1.0,1.0,1.0};
    
    cgFormat.bitsPerComponent                   =       8;
    cgFormat.bitsPerPixel                       =       32;
    cgFormat.colorSpace                         =       CGColorSpaceCreateDeviceRGB();
    cgFormat.bitmapInfo                         =       kCGImageAlphaFirst  |   kCGBitmapByteOrder32Little;
    cgFormat.version                            =       0;
    cgFormat.decode                             =       decodeArray;
    cgFormat.renderingIntent                    =       kCGRenderingIntentAbsoluteColorimetric;
    
    
    vImageCVImageFormatRef  cvFormat            =       vImageCVImageFormat_CreateWithCVPixelBuffer(imageBuffer);
    vImageCVImageFormat_SetColorSpace(cvFormat, CGColorSpaceCreateDeviceRGB());
    vImageCVImageFormat_SetChromaSiting(cvFormat, kCVImageBufferChromaLocation_Center);
    
    vImageConverterRef      photoConverter           =       vImageConverter_CreateForCVToCGImageFormat(cvFormat, &cgFormat, background, kvImageNoFlags, NULL);
    
    vImageBuffer_InitForCopyFromCVPixelBuffer(&srcBuffer, photoConverter, imageBuffer, kvImageNoAllocate);
    
    //NSLog(@"Set number of source buffers: %lu",vImageConverter_GetNumberOfSourceBuffers(converter));
    
    vImage_Buffer           destBuffer;
    
    vImageBuffer_Init(&destBuffer, CVPixelBufferGetHeight(imageBuffer), CVPixelBufferGetWidth(imageBuffer), cgFormat.bitsPerPixel, kvImagePrintDiagnosticsToConsole);
    
    vImageConvert_AnyToAny(photoConverter, &srcBuffer, &destBuffer, nil, 0);
        
    DAInfo                  DAprivateInfo;
    DAprivateInfo.cgFormat                      =       cgFormat;
    
    CGDataProviderRef DAphotoProvider                                  =       CGDataProviderCreateWithData(destBuffer.data, destBuffer.data, destBuffer.rowBytes * destBuffer.height, &DAreleaseData);
    
    CGImageRef              vImage              =       CGImageCreate(destBuffer.width, destBuffer.height, cgFormat.bitsPerComponent, cgFormat.bitsPerPixel, destBuffer.rowBytes, cgFormat.colorSpace, cgFormat.bitmapInfo, DAphotoProvider, cgFormat.decode, NO, kCGRenderingIntentRelativeColorimetric);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
    [self       performSelectorOnMainThread:@selector(photoReceived:) withObject:(__bridge id)(vImage) waitUntilDone:YES];

    
    CFRelease(DAphotoProvider);
}

//Video data output delegate
-   (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"Received video frame");

    int perFrameCameraChanged       =                   cameraChanged;
    if(perFrameCameraChanged        ==  1)              cameraChanged   =   0;
    
    if(photoSelected        ==      -1 && videoSelected ==                  -1)
    {
        CVPixelBufferRef            pixelBuffer         =           CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);

        vImage_CGImageFormat    cgFormat;
        CGFloat                 decodeArray[6]          =       {0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
        CGFloat                 background[3]           =       {1.0,1.0,1.0};
        
        cgFormat.bitsPerComponent                       =       8;
        cgFormat.bitsPerPixel                           =       32;
        cgFormat.colorSpace                             =       CGColorSpaceCreateDeviceRGB();
        cgFormat.bitmapInfo                             =       kCGImageAlphaFirst | kCGBitmapByteOrder32Little;
        cgFormat.version                                =       0;
        cgFormat.decode                                 =       decodeArray;
        cgFormat.renderingIntent                        =       kCGRenderingIntentAbsoluteColorimetric;
        
        if (converter == nil || perFrameCameraChanged == 1)
        {
            //NSLog(@"Creating converter");
        
            if(perFrameCameraChanged == 1){
                //NSLog(@"Camera changed");
            }
            
            vImageCVImageFormatRef  cvFormat                =   vImageCVImageFormat_CreateWithCVPixelBuffer(pixelBuffer);
            vImageCVImageFormat_SetColorSpace(cvFormat, CGColorSpaceCreateDeviceRGB());
            vImageCVImageFormat_SetChromaSiting(cvFormat, kCVImageBufferChromaLocation_Center);
            
            converter                               =       vImageConverter_CreateForCVToCGImageFormat(cvFormat, &cgFormat, background, kvImagePrintDiagnosticsToConsole, nil);
        }

        //Pass kvImageNoAllocate flag so that the function initializes the buffer to read from the locked pixel buffer
            
        //Init source bufffer (Y CbCr)
        vImageBuffer_InitForCopyFromCVPixelBuffer(sourceBuffers, converter, pixelBuffer, kvImagePrintDiagnosticsToConsole | kvImageNoAllocate);
            
        //Init Destination buffer(CGImage Format)
        vImageBuffer_Init(&destinationBuffer, CVPixelBufferGetHeightOfPlane(pixelBuffer, 0), CVPixelBufferGetWidthOfPlane(pixelBuffer, 0), cgFormat.bitsPerPixel, kvImagePrintDiagnosticsToConsole);
        
        
        //Convert y CbCr to CGImage format
        vImageConvert_AnyToAny(converter, (vImage_Buffer *)sourceBuffers, &destinationBuffer, nil, kvImageNoFlags);

    
        //Direct access data source
        DAInfo      DAprivateInfo;
        DAprivateInfo.cgFormat          =   cgFormat;

        DAprovider  =   CGDataProviderCreateWithData(destinationBuffer.data, destinationBuffer.data, destinationBuffer.height * destinationBuffer.rowBytes, &DAreleaseData);

        CGImageRef      vImage  =   CGImageCreate(destinationBuffer.width, destinationBuffer.height, cgFormat.bitsPerComponent, cgFormat.bitsPerPixel, destinationBuffer.rowBytes, cgFormat.colorSpace, cgFormat.bitmapInfo, DAprovider, cgFormat.decode, NO, kCGRenderingIntentAbsoluteColorimetric);
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);


        [self                       performSelectorOnMainThread:@selector(frameReceived:) withObject:(__bridge id)vImage waitUntilDone:YES];
        
        CFRelease(DAprovider);
    }
}

-   (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    if(self.recording       ==      true)
    {
        NSLog(@"Sample buffer dropped.");
        self.totalFrames    =       self.totalFrames+1;
        
        [self                       performSelectorOnMainThread:@selector(recordFrame:) withObject:(__bridge id)lastFrame waitUntilDone:YES];
    }
}




@end
