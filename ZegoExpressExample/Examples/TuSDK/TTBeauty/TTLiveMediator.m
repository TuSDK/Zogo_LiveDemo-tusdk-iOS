//
//  TTPipeMediator.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTLiveMediator.h"
#import <TuSDKPulse/TuSDKPulse.h>
#import <TuSDKPulseCore/TuSDKPulseCore.h>
#import "TTImageConvert.h"

@interface TTLiveMediator ()
@property(nonatomic, strong) TUPDispatchQueue *queue;
@property(nonatomic, strong) TTImageConvert *imageConvert;
@property(nonatomic, strong) TTBeautyManager *beautyManager;
@property(nonatomic, strong) TUPFPImage *outputFPImage;

@end

@implementation TTLiveMediator

+ (void)setupWithAppKey:(NSString *)appKey {
    [TUCCore initSdkWithAppKey:appKey];
    [TUCCore setLogLevel:TuLogLevelDEBUG];
    [TUPEngine Init:nil];
    NSLog(@"TuSDK版本号=======%@", lsqPulseSDKVersion);
}

+ (void)setupContext:(nullable EAGLContext *)glctx {
    [TUPEngine Terminate];
    [TUPEngine Init:glctx];
}

+ (void)terminate {
    [[TTLiveMediator shareInstance] destory];
    [TUPEngine Terminate];
}

static TTLiveMediator* _instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[TUPDispatchQueue alloc] initWithName:@"TTLiveMediator_Queue"];
        _imageConvert = [[TTImageConvert alloc] init];
        _beautyManager = [[TTBeautyManager alloc] initWithQueue:_queue];
    }
    return self;
}

- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [_queue runSync:^{
        CMTime t = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        int64_t ts = t.value * 1000 / t.timescale;
        CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
        TUPFPImage *fpImage = [self.imageConvert sendPixelBuffer:pb withTimestamp:ts rotation:0 flip:NO mirror:NO];
        // 前处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:fpImage];
        self.outputFPImage = processFPImage;
    }];
    return self.outputFPImage;
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_queue runSync:^{
        TUPFPImage *fpImage = [self.imageConvert sendPixelBuffer:pixelBuffer];
        // 前处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:fpImage];
        self.outputFPImage = processFPImage;
    }];
    return self.outputFPImage;
}

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror {
    [_queue runSync:^{
        TUPFPImage *fpImage = [self.imageConvert sendPixelBuffer:pixelBuffer withTimestamp:timestamp rotation:rotation flip:flip mirror:mirror];
        // 前处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:fpImage];
        self.outputFPImage = processFPImage;
    }];
    return self.outputFPImage;
}

- (TUPFPImage *)sendVideoTexture2D:(GLuint)texture2D width:(int)width height:(int)height {
    [_queue runSync:^{
        TUPFPImage *fpImage = [self.imageConvert sendTexture2D:texture2D width:width height:height];
        // 前处理: 美颜、滤镜等
        TUPFPImage *processFPImage = [self.beautyManager sendFPImage:[self.imageConvert imageflip:fpImage]];
        self.outputFPImage = processFPImage;
    }];
    return self.outputFPImage;
}

- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat {
    [self.imageConvert setPixelFormat:pixelFormat];
}

- (void)setOutputSize:(CGSize)outputSize {
    [self.imageConvert setOutputSize:outputSize];
}

- (TTBeautyManager *)getBeautyManager {
    return self.beautyManager;
}

// MARK: - Lazy
- (TTBeautyManager *)beautyManager {
    if (!_beautyManager) {
        _beautyManager = [[TTBeautyManager alloc] initWithQueue:_queue];
    }
    return _beautyManager;
}

- (TTImageConvert *)imageConvert {
    if (!_imageConvert) {
        _imageConvert = [[TTImageConvert alloc] init];
    }
    return _imageConvert;
}

- (void)destory {
    [_beautyManager destory];
    [_imageConvert destory];
    _beautyManager = nil;
    _imageConvert = nil;
    _outputFPImage = nil;
}

@end
