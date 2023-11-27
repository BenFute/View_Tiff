//
// DeepLabV3.m
//
// This file was automatically generated and should not be edited.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with automatic reference counting enabled (-fobjc-arc)
#endif

#import "DeepLabV3.h"

@implementation DeepLabV3Input

- (instancetype)initWithImage:(CVPixelBufferRef)image {
    self = [super init];
    if (self) {
        _image = image;
        CVPixelBufferRetain(_image);
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_image);
}

- (nullable instancetype)initWithImageFromCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __image = [MLFeatureValue featureValueWithCGImage:image pixelsWide:513 pixelsHigh:513 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__image == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithImage:(CVPixelBufferRef)__image.imageBufferValue];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

- (nullable instancetype)initWithImageAtURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __image = [MLFeatureValue featureValueWithImageAtURL:imageURL pixelsWide:513 pixelsHigh:513 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__image == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithImage:(CVPixelBufferRef)__image.imageBufferValue];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

-(BOOL)setImageWithCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __image = [MLFeatureValue featureValueWithCGImage:image pixelsWide:513 pixelsHigh:513 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__image != nil) {
            CVPixelBufferRelease(self.image);
            self.image =  (CVPixelBufferRef)__image.imageBufferValue;
            CVPixelBufferRetain(self.image);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

-(BOOL)setImageWithURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __image = [MLFeatureValue featureValueWithImageAtURL:imageURL pixelsWide:513 pixelsHigh:513 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__image != nil) {
            CVPixelBufferRelease(self.image);
            self.image =  (CVPixelBufferRef)__image.imageBufferValue;
            CVPixelBufferRetain(self.image);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"image"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"image"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:self.image];
    }
    return nil;
}

@end

@implementation DeepLabV3Output

- (instancetype)initWithSemanticPredictions:(MLMultiArray *)semanticPredictions {
    self = [super init];
    if (self) {
        _semanticPredictions = semanticPredictions;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"semanticPredictions"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"semanticPredictions"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.semanticPredictions];
    }
    return nil;
}

@end

@implementation DeepLabV3


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"DeepLabV3" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load DeepLabV3.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize DeepLabV3 instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of DeepLabV3.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model {
    self = [super init];
    if (!self) { return nil; }
    _model = model;
    if (_model == nil) { return nil; }
    return self;
}


/**
    Initialize DeepLabV3 instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize DeepLabV3 instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize DeepLabV3 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for DeepLabV3.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize DeepLabV3 instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for DeepLabV3.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct DeepLabV3 instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid DeepLabV3 instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(DeepLabV3 * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct DeepLabV3 instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid DeepLabV3 instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(DeepLabV3 * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            DeepLabV3 *typedModel = [[DeepLabV3 alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable DeepLabV3Output *)predictionFromFeatures:(DeepLabV3Input *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable DeepLabV3Output *)predictionFromFeatures:(DeepLabV3Input *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [self.model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[DeepLabV3Output alloc] initWithSemanticPredictions:(MLMultiArray *)[outFeatures featureValueForName:@"semanticPredictions"].multiArrayValue];
}

- (void)predictionFromFeatures:(DeepLabV3Input *)input completionHandler:(void (^)(DeepLabV3Output * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (!prediction) {
            completionHandler(nil, predictionError);
        } else {
            DeepLabV3Output *output = [[DeepLabV3Output alloc] initWithSemanticPredictions:(MLMultiArray *)[prediction featureValueForName:@"semanticPredictions"].multiArrayValue];
            completionHandler(output, predictionError);
        }
    }];
}

- (void)predictionFromFeatures:(DeepLabV3Input *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(DeepLabV3Output * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input options:options completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (!prediction) {
            completionHandler(nil, predictionError);
        } else {
            DeepLabV3Output *output = [[DeepLabV3Output alloc] initWithSemanticPredictions:(MLMultiArray *)[prediction featureValueForName:@"semanticPredictions"].multiArrayValue];
            completionHandler(output, predictionError);
        }
    }];
}

- (nullable DeepLabV3Output *)predictionFromImage:(CVPixelBufferRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    DeepLabV3Input *input_ = [[DeepLabV3Input alloc] initWithImage:image];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<DeepLabV3Output *> *)predictionsFromInputs:(NSArray<DeepLabV3Input*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [self.model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<DeepLabV3Output*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        DeepLabV3Output * result = [[DeepLabV3Output alloc] initWithSemanticPredictions:(MLMultiArray *)[resultProvider featureValueForName:@"semanticPredictions"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
