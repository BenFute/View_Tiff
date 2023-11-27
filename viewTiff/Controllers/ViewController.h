//
//  ViewController.h
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import <Foundation/Foundation.h>
#import <objc/NSObject.h>
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

#import <IOSurface/IOSurfaceRef.h>
#import <Accelerate/Accelerate.h>

#import <VideoToolbox/VideoToolbox.h>

#import "../Models/PhotoModel.h"
#import "../Models/VideoModel.h"
#import "../Models/SettingsModel.h"
#import "DeepLabV3.h"

#import "../Views/TakePicture.h"
#import "../Views/PhotoView.h"
#import "../Views/LensView.h"
#import "../Views/EffectsView.h"
#import "../Views/LogoView.h"

#import "../Controllers/DirectoryController.h"
#import "../Controllers/SettingsViewController.h"
#import "../Controllers/PopOverModalViewController.h"

@class ViewController;
@class VideoThread;


void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine(void *info);
void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);

void *RunLoopObserver(CFRunLoopObserverRef CFRunLoopObserverRef,CFRunLoopActivity activity, void *info);

@interface RunLoopSource : NSObject
{
    CFRunLoopSourceRef              runLoopSource;
    NSMutableArray                  *commands;
    ViewController                  *sharedVC;
    
    CFMutableArrayRef               currentVideoSaveArray;
    
    VideoModel                      *currentRegister;       //command 4
    
    int                             currentFrameNumber;     //command 0
    int                             totalFrames;            //command 1
    int                             threadID;               //command 2
    int                             currentVideoSaveBlock;  //command 3
    
                                        
    int                             framesPerSaveBlock;     //command 6
                                            //Open video    //command 7
    int                             currentVideoDir;
    int                             currentVideoURL;
    

};
@property                           int                 threadID;


-   (id)                initWithSharedVC:(ViewController *)VC totalFrames:(int)frameNum;
-   (void)              addToCurrentRunLoop;
-   (void)              removeFromCurrentRunLoop;
-   (void)              removeFromRunLoop:(CFRunLoopRef)runLoop;
-   (ViewController*)   getSharedViewController;

-   (void)      expungeOpen:(VideoModel*)video;


-   (void)              invalidate;

//Handler method
-   (void)              sourceFired;

//Client interface for registering commands to process
-   (void)              addCommand:(NSInteger)command withData:(id)data;
-   (void)              fireAllCommandsOnRunLoop:(CFRunLoopRef)runLoop;

@end

//RunLoopContext is a container object used during registeration of the input source
@interface RunLoopContext : NSObject
{
    CFRunLoopRef        runLoop;
    RunLoopSource       *source;
}

@property           (readonly)      CFRunLoopRef        runLoop;
@property           (readonly)      RunLoopSource       *source;

-   (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop;
@end

@interface VideoThread : NSThread
{
    
}
@property           ViewController      *sharedVC;
@property           int                 totalFrames;
@property           int                 threadID;

-   (void)  detatchedMain:(id)sharedVC;
-   (void)  main;
-   (void)  doFireTimer;


@end

@interface customSegue  :   UIStoryboardSegue
-   (void)perform;
@end

//View controller
@interface ViewController : UIViewController <AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ButtonViewDelegate, PhotoViewDelegate,LensViewDelegate,EffectViewDelegate,ConfigurationDelegate>
{
    int             firstOpen;
    
    //Thread
    NSMutableArray  <RunLoopContext*>   *sourcesToPingCapture;
    NSMutableArray  <RunLoopContext*>   *sourcesToPingPlayback;
    

    NSThread                            *captureThread;
    AVCaptureSession                    *captureSession;
    AVCaptureVideoDataOutput            *videoDataOutput;
    AVCaptureDevice                     *iosCamera;
    AVCaptureDevice                     *iosMicrophone;
    
    CGContextRef                        ctx;
    
    CameraPosition                      position;
    CameraType                          frontCamera;
    CameraType                          backCamera;
    int                                 cameraChanged;
    
    AVCapturePhotoOutput                *photoOutput;

    int                                 numberOfPhotos;
    int                                 photoSelected;
    int                                 videoSelected;
    
    int                                 frameTransformed;

    
    CGFloat                             frameTransformViewHeight;
    
    CGFloat                             scrollViewSize;
    CGFloat                             scrollViewImageHeight;
    CGFloat                             scrollViewImageWidth;
    
    AVCaptureDeviceDiscoverySession     *availableCameraCaptureDevices;
    
    vImageConverterRef              converter;
    vImage_Buffer                   sourceBuffers[2];
    vImage_Buffer                   destinationBuffer;
    
    CGDataProviderRef               DAprovider;
    
    //Goggles
    CGContextRef                    gogglesOverlayCTX;
    CGContextRef                    gogglesOverlayWithImageCTX;
    int                             overlayCTXCreated;
    vImage_CGImageFormat            cgFormat;
    
    uint8_t                         *gogglesOverlayBitmap;
    
    DeepLabV3                       *model;                                        
    DeepLabV3Input                  *modelInput;
    DeepLabV3Output                 *modelOutput;
    MLMultiArray                    *imageClass;
    
    int                             predictionsFrameRate;
    
    CGImageRef                          lastFrame;
    
    
    //Audio
    AVAudioSession                  *systemSharedAudioSession;
    AVAudioRecorder                 *recorder;
    AVAudioPlayer                   *audioPlayer;
    
    SettingsModel                   *settings;
    

}
@property                           ViewController                  *sharedVC;

@property   (strong, nonatomic) IBOutlet    UIImageView             *currentFrameView;

//Camera view layout constraints
@property                       IBOutlet    NSLayoutConstraint      *topFrameViewLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *leadingFrameViewLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *heightFrameViewLayoutConstraint;

//Scroll view
@property (strong, nonatomic)   IBOutlet    UIScrollView            *scrollView;

@property                       IBOutlet    NSLayoutConstraint      *topScrollViewLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *leadingScrollViewLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *heightScrollViewLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *widthScrollViewLayoutConstraint;

//Photos
@property                       NSMutableArray  <PhotoModel*>       *savedPhotos;
@property                       NSMutableArray  <PhotoView*>        *photoStackViewSource;
@property                       int                                 updateSavedPhotos;

//Video
@property                       int                                 recording;
@property                       VideoThread                         *thread0;
@property                       VideoModel                          *register0;
@property                       VideoModel                          *register1;
@property                       VideoModel                          *register2;

@property                       int                                 currentVideoDir;
@property                       int                                 currentVideoDocument;
@property                       int                                 currentVideoSaveBlock;
@property                       int                                 framesPerSaveBlock;
@property                       int                                 totalFrames;
@property                       int                                 currentFrame;



//Lens
@property                       NSMutableArray  <LensView*>         *lensStackView;

//Effects
@property                       NSMutableArray  <EffectsView*>      *effectsStackView;
@property                       int                                 eyeEffectSelected;
@property                       int                                 whiteEffectSelected;
@property                       int                                 siloEffectSelected;
@property                       int                                 vImageEffectSelected;

@property                       CGPoint                             leftPupilPosition;
@property                       VNFaceLandmarkRegion2D              *leftPupilLandmarkRegion;
@property                       CGPoint                             rightPupilPosition;
@property                       VNFaceLandmarkRegion2D              *rightPupilLandmarkRegion;
@property                       CGRect                              faceBoundingBox;

//ML Models
@property                       VNDetectFaceLandmarksRequest        *visionRequest;
//@property                       DeepLabRequest                      *deepLabRequest;

//Button Layout
@property                       IBOutlet    NSLayoutConstraint      *topCameraButtonLayoutConstraint;
@property                       IBOutlet    NSLayoutConstraint      *leadingCameraButtonLayoutConstraint;





@property   (strong, nonatomic) IBOutlet TakePicture            *takePictureView;



-   (instancetype)initWithCoder:(NSCoder *)coder;
-   (void)viewDidLoad;
-   (void)layoutFullscreenView;
//Threads
-   (id)        sharedVC;
-   (void)      registerSourceCapture:(RunLoopContext*)sourceInfo;
-   (void)      registerSourcePlayback:(RunLoopContext*)sourceInfo;
-   (void)      removeSourceCapture:(RunLoopContext*)sourceInfo;
-   (void)      removeSourcePlayback:(RunLoopContext*)sourceInfo;

-   (void)      expungePlaybackThreads;

-   (void)      background:(CGColorRef)color;

-   (void)      loadVC;
-   (void)      loadPhotos;

-   (void)      enableAVCapture;
-   (void)      verifyAVCaptureAuthorization;

-   (void)      setupAudioCapture;


-   (void)      frameReceived:(CGImageRef)image;
-   (CGImageRef)processFrame:(CGImageRef)frame;
-   (void)      initRecording;
-   (void)      recordFrame:(CGImageRef)frame;
-   (void)      setFrameToView:(CGImageRef)frame;
-   (void)      addToFrameBuffer:(int)frameBufferNumber frame:(CGImageRef)frame;
-   (void)      playSaveBlock:(NSNumber*)saveBlock;
-   (void)      prepareSaveBlock:(NSNumber *)saveBlock;


-   (void)      photoReceived:(CGImageRef)image;
-   (CGImageRef)processPhoto:(CGImageRef)photo;

-   (CGImageRef)addEyeEffect:(CGImageRef)image;
-   (CGImageRef)addWhiteEffect:(CGImageRef)image;
-   (CGImageRef)addSiloEffect:(CGImageRef)image;
-   (CGImageRef)addvImageEffect:(CGImageRef)image;

-   (void)      selectInputs;
-   (void)      setupAVCameraSession;
-   (void)      runAVCaptureSession;

-   (void)      reloadVC;

-   (void)      removeSavedPhotosStackView;
-   (void)      hideSavedPhotosStackView;
-   (void)      showSavedPhotosStackView;

-   (void)      hideEffectsStackView;
-   (void)      showEffectsStackView;

-   (void)      removeLensStackView;
-   (void)      hideLensStackView;
-   (void)      showLensStackView;

-   (void)      loadStackView;

-   (void)      loadLensStackView;

-   (void)      loadEffectsStackView;
-   (void)      appDidEnterBackground;


//Buttons
@property (strong, nonatomic) IBOutlet  UIButton    *CameraButtonProperty;
- (IBAction)CameraButton;

@property (strong, nonatomic) IBOutlet  UIButton    *VideoButtonProperty;
@property                               int         videoButtonSelected;
- (IBAction)VideoButton;

@property (strong, nonatomic) IBOutlet  UIButton    *EffectsButtonProperty;
@property                               int         effectsButtonSelected;
- (IBAction)EffectsButton:(id)sender;

@property (strong, nonatomic) IBOutlet  UIButton    *LensButtonProperty;
@property                               int         lensButtonSelected;
- (IBAction)LensButton:(id)sender;

@property (strong, nonatomic) IBOutlet  UIButton    *SettingsButtonProperty;
@property                               int         settingsButtonSelected;
- (IBAction)SettingsButton;

@property (strong, nonatomic) IBOutlet  UIButton    *PlayButtonProperty;
@property                               int         playButtonSelected;
- (IBAction)PlayButton;


@property (strong, nonatomic) IBOutlet LogoView *TIFF;
@property (strong, nonatomic) IBOutlet LogoView *RGB;


@property (strong, nonatomic) IBOutlet  UIButton    *SavesButtonProperty;
@property                               int         savesButtonSelected;
- (IBAction)SavesButton;
- (IBAction)flipButton;
- (IBAction)upButton;


//Lens View Delegate
-   (void)didTapLens:(int)lensNumber;

//PHoto View Delegate
-   (void)didTapPhoto:(NSNumber*)photoNumber;

//Settings delegate

-   (void)didUpdateLongVideoEnabled:(SettingsModel *)receivedSettings;
-   (void)didUpdateAudioEnabled:(SettingsModel *)receivedSettings;
-   (void)didUpdateWhiteOutSaveEnabled:(SettingsModel *)receivedSettings;

@end
