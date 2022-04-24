//
//  TTImageConvert.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "TTImageConvert.h"
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import "TTRenderDef.h"

@interface TTImageConvert ()
/// 视频样本转换
@property(nonatomic, strong) TUPFPImage_CMSampleBufferCvt *bufferConvert;
/// 像素格式
@property(nonatomic, assign) TTVideoPixelFormat pixelFormat;
/// 分辨率
@property(nonatomic, assign) CGSize outputResolution;
@end

@implementation TTImageConvert
- (instancetype)init {
    self = [super init];
    if (self) {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] init];
        _pixelFormat = TTVideoPixelFormat_YUV;
        _outputResolution = CGSizeMake(1080, 1920);
    }
    return self;
}

- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat {
    if (_pixelFormat == pixelFormat) {
        return;
    }
    _pixelFormat = pixelFormat;
    if (pixelFormat == TTVideoPixelFormat_YUV) {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] init];
    } else if (pixelFormat == TTVideoPixelFormat_BGRA) {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] initWithPixelFormatType_32BGRA];
    } else {
        _bufferConvert = [[TUPFPImage_CMSampleBufferCvt alloc] initWithPixelFormatTexture2D];
    }
}

- (void)setOutputSize:(CGSize)outputSize {
    CGSize size = CGSizeMake(self.outputResolution.width * outputSize.width, self.outputResolution.height * outputSize.height);
    [self.bufferConvert setOutputSize:size];
    NSLog(@"TTImageConvert ouputSize: %@", NSStringFromCGSize(size));
}

- (TUPFPImage *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    int64_t timestamp = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    return [self.bufferConvert convert:pixelBuffer withTimestamp:timestamp];
}

- (TUPFPImage *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror {
    self.outputResolution = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    return [self.bufferConvert convert:pixelBuffer withTimestamp:timestamp orientaion:rotation flip:flip mirror:mirror];
}

- (TUPFPImage *)sendTexture2D:(GLuint)texture2D width:(int)width height:(int)height {
    int64_t timestamp = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    self.outputResolution = CGSizeMake(width, height);
    return [self.bufferConvert convert:texture2D timestamp:timestamp width:width height:height];
}

- (TUPFPImage *)imageflip:(TUPFPImage *)fpImage {
    return [self.bufferConvert convertImage:fpImage];
}

- (void)destory {
    _bufferConvert = nil;
}

@end
