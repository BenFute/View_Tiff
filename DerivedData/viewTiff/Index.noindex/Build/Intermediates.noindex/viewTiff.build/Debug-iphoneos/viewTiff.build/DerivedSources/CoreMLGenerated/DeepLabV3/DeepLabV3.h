//
// DeepLabV3.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>
#include <os/log.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface DeepLabV3Input : NSObject<MLFeatureProvider>

/// Input image to be segmented as color (kCVPixelFormatType_32BGRA) image buffer, 513 pixels wide by 513 pixels high
@property (readwrite, nonatomic) CVPixelBufferRef image;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithImage:(CVPixelBufferRef)image NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithImageFromCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));

- (nullable instancetype)initWithImageAtURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));

-(BOOL)setImageWithCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error  API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
-(BOOL)setImageWithURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error  API_AVAILABLE(macos(10.15), ios(13.0), watchos(6.0), tvos(13.0)) __attribute__((visibility("hidden")));
@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface DeepLabV3Output : NSObject<MLFeatureProvider>

/// Array of integers of the same size as the input image, where each value represents the class of the corresponding pixel. as 513 by 513 matrix of 32-bit integers
@property (readwrite, nonatomic, strong) MLMultiArray * semanticPredictions;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSemanticPredictions:(MLMultiArray *)semanticPredictions NS_DESIGNATED_INITIALIZER;

@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")))
@interface DeepLabV3 : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;

/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle;

/**
    Initialize DeepLabV3 instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of DeepLabV3.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model NS_DESIGNATED_INITIALIZER;

/**
    Initialize DeepLabV3 instance with the model in this bundle.
*/
- (nullable instancetype)init;

/**
    Initialize DeepLabV3 instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize DeepLabV3 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for DeepLabV3.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Initialize DeepLabV3 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for DeepLabV3.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Construct DeepLabV3 instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid DeepLabV3 instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(DeepLabV3 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Construct DeepLabV3 instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid DeepLabV3 instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(DeepLabV3 * _Nullable model, NSError * _Nullable error))handler API_AVAILABLE(macos(11.0), ios(14.0), watchos(7.0), tvos(14.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the standard interface
    @param input an instance of DeepLabV3Input to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as DeepLabV3Output
*/
- (nullable DeepLabV3Output *)predictionFromFeatures:(DeepLabV3Input *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of DeepLabV3Input to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as DeepLabV3Output
*/
- (nullable DeepLabV3Output *)predictionFromFeatures:(DeepLabV3Input *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Make an asynchronous prediction using the standard interface
    @param input an instance of DeepLabV3Input to predict from
    @param completionHandler a block that will be called upon completion of the prediction. error will be nil if no error occurred.
*/
- (void)predictionFromFeatures:(DeepLabV3Input *)input completionHandler:(void (^)(DeepLabV3Output * _Nullable output, NSError * _Nullable error))completionHandler API_AVAILABLE(macos(14.0), ios(17.0), watchos(10.0), tvos(17.0)) __attribute__((visibility("hidden")));

/**
    Make an asynchronous prediction using the standard interface
    @param input an instance of DeepLabV3Input to predict from
    @param options prediction options
    @param completionHandler a block that will be called upon completion of the prediction. error will be nil if no error occurred.
*/
- (void)predictionFromFeatures:(DeepLabV3Input *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(DeepLabV3Output * _Nullable output, NSError * _Nullable error))completionHandler API_AVAILABLE(macos(14.0), ios(17.0), watchos(10.0), tvos(17.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the convenience interface
    @param image Input image to be segmented as color (kCVPixelFormatType_32BGRA) image buffer, 513 pixels wide by 513 pixels high:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as DeepLabV3Output
*/
- (nullable DeepLabV3Output *)predictionFromImage:(CVPixelBufferRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of DeepLabV3Input instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<DeepLabV3Output *>
*/
- (nullable NSArray<DeepLabV3Output *> *)predictionsFromInputs:(NSArray<DeepLabV3Input*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
