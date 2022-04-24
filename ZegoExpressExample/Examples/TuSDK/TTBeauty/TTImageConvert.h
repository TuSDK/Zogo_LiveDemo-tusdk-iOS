//
//  TTImageConvert.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//  图像转换对象

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TTRenderDef.h"

NS_ASSUME_NONNULL_BEGIN

@class TUPFPImage;

@interface TTImageConvert : NSObject

/// 向 SDK 发送采集的视频数据 返回图像
/// @param pixelBuffer 视频样本
- (TUPFPImage *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (TUPFPImage *)sendPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror;

- (TUPFPImage *)sendTexture2D:(GLuint)texture2D width:(int)width height:(int)height;

/// 翻转
- (TUPFPImage *)imageflip:(TUPFPImage *)fpImage;
/// 设置视频像素格式
/// @param pixelFormat yuv bgra
- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat;

/// 设置样本输出分辨率(size 归一化)
- (void)setOutputSize:(CGSize)outputSize;

- (void)destory;
@end

NS_ASSUME_NONNULL_END
