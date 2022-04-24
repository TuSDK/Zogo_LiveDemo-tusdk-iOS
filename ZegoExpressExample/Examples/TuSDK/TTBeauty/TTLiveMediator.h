//
//  TTPipeMediator.h
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/12/27.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TuSDKPulseFilter/TuSDKPulseFilter.h>
#import "TTRenderDef.h"
#import "TTBeautyManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLiveMediator : NSObject

+ (instancetype)shareInstance;
/// 初始化SDK
+ (void)setupWithAppKey:(NSString *)appKey;
/// 绑定OpenGL上下文
+ (void)setupContext:(nullable EAGLContext *)glctx;
/// 程序终止时调用
+ (void)terminate;
// MARK: - Convert
////////////////////////////////////////////////////////////////////////////////////////////////

/// 向 SDK 发送采集的视频数据 并返回处理过图像
/// @param sampleBuffer 视频样本
- (TUPFPImage *)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (TUPFPImage *)sendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimestamp:(int64_t)timestamp rotation:(int)rotation flip:(BOOL)flip mirror:(BOOL)mirror;

- (TUPFPImage *)sendVideoTexture2D:(GLuint)texture2D width:(int)width height:(int)height;

/// 设置视频像素格式
/// @param pixelFormat yuv bgra
- (void)setPixelFormat:(TTVideoPixelFormat)pixelFormat;

/// 设置样本输出分辨率(size 归一化)
- (void)setOutputSize:(CGSize)outputSize;

// MARK: - Editor
////////////////////////////////////////////////////////////////////////////////////////////////
/// 获取美颜对象
/// 美肤、微整形、美妆、滤镜、动态贴纸、哈哈镜
- (TTBeautyManager *)getBeautyManager;

/// 销毁
- (void)destory;

@end

NS_ASSUME_NONNULL_END
