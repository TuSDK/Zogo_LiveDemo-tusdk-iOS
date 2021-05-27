/********************************************************
 * @file    : TuSDKManager.h
 * @project : tusdkfilterprocessormodule
 * @author  : Copyright © http://tutucloud.com/
 * @date    : 2020-08-01
 * @brief   : 
*********************************************************/
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TuSDKFramework.h"



/** 输出帧格式类型*/
//typedef NS_ENUM(NSInteger, TuSDKManagerFilterInputType)
//{
//    TuSDKManagerFilterInputType_420YpCbCr8BiPlanarFullRange = 0,   // PixelBuffer
//    TuSDKManagerFilterInputType_420YpCbCr8BiPlanarVideoRange,      // PixelBuffer
//    TuSDKManagerFilterInputType_32BGRA,                            // 32BGRA
//    TuSDKManagerFilterInputType_GLuint                             // GLuint
//};



@interface TuSDKManager : NSObject
@property (nonatomic, assign, readonly) BOOL isInitedTuSDK; // 是否初始化SDK
@property (nonatomic, assign, readonly) BOOL isInitFilterProcessor; // 是否初始化滤镜处理器
//
//@property (nonatomic, strong) NSBundle *resourceBundle; // 资源bundle --- 默认MainBundle
//
//@property (nonatomic, weak) id<TuSDKManagerDelegate> delegate;
//
//#pragma mark - 显示控制
//@property (nonatomic, assign) BOOL isShowCartoonView; //  是否显示漫画: 默认YES
//@property (nonatomic, assign) BOOL isShowDistortingMirror; // 是否显示哈哈镜: 默认NO
@property (nonatomic, assign) BOOL enableLiveSticker; // 是否开启动态贴纸 (默认: YES)
//
//@property(nonatomic, assign) AVCaptureDevicePosition cameraPosition; // 摄像头方向 --- 默认前置
//@property (nonatomic, assign) BOOL isOriginalOrientation; // 传入图像的方向是否为原始朝向，SDK 将依据该属性来调整人脸检测时图片的角度。如果没有对图片进行旋转，则为YES 默认为NO
//@property(nonatomic, assign) BOOL horizontallyMirrorFrontFacingCamera; // These properties determine whether or not the two camera orientations should be mirrored. By default, both are NO.  与外面保存一致
//@property(nonatomic, assign) BOOL horizontallyMirrorRearFacingCamera;
//@property (nonatomic, assign) BOOL adjustOutputRotation; // 是否调整输出方向，当 isOriginalOrientation 为 YES 时生效;  YES: 调整输出的buffer方向  NO：输出的buffer方向与输入保持一致  默认:NO
//
//@property (nonatomic, assign) BOOL isShowCollection; //采集是否初始化
//
//
//#pragma mark - 功能配置
//@property (nonatomic, strong) NSArray<NSString *> *filterCodes; // 滤镜
//@property (nonatomic, strong) NSArray<NSString *> *cartoonCodes; // 漫画滤镜
//@property (nonatomic, strong) NSArray<NSString *> *beautySkinCodes; // 美颜
//@property (nonatomic, strong) NSArray<NSString *> *beautyPlasticCodes; // 微整形
//@property (nonatomic, strong) NSArray<NSString *> *faceMonsterCodes; // 哈哈镜
//@property (nonatomic, strong) NSArray<NSString *> *audioCodes; // 变声
//@property (nonatomic, strong) NSArray<NSString *> *scenceCodes; // 场景特效
//@property (nonatomic, copy) NSString *propsFilePath; // 贴纸道具文件
//
//#pragma mark - 功能面板
//@property (nonatomic, strong, readonly) TuPanelView *tuPanelView; // 总面板
//@property (nonatomic, strong, readonly) TuFilterCartoonPanelView *filterCartoonPanelView; // 滤镜-漫画
//@property (nonatomic, strong, readonly) TuFilterPanelView *filterPanelView; // 滤镜
//@property (nonatomic, strong, readonly) TuFilterPanelView *cartoonPanelView; // 漫画
//@property (nonatomic, strong, readonly) TuStickerPanelView *propsPanelView; // 贴纸
//@property (nonatomic, strong, readonly) TuScencePanelView *scencePanelView; // 场景特效
//@property (nonatomic, strong, readonly) TuPlasticPanelView *tuPlasticPanelView; //微整形面板
//@property (nonatomic, strong, readonly) TuSkinPanelView *tuSkinPanelView;  //美肤面板
//@property (nonatomic, strong, readonly) TuFiltersPanelView *tuFilterPanelView; //滤镜面板
//@property (nonatomic, strong, readonly) TuMonsterPanelView *tuMonsterPanelView; //哈哈镜面板
//@property (nonatomic, strong, readonly) TuCosmeticPanelView *tuCosmeticPanelView; //美妆面板
//
//
//@property (nonatomic, copy)AudioBuffer(^outPutBlock)(AudioBuffer *outPutBuffer);



#pragma mark - 初始化
+ (instancetype)sharedManager;

/**
 *  初始化SDK
 *
 *  @param appKey 应用秘钥
 */
- (void)initSdkWithAppKey:(NSString *)appKey;

/**
 *  初始化SDK(多包名发布：https://tutucloud.com/docs/ios-faq/masterkey)
 *
 *  @param appKey 应用秘钥
 *  @param devType 开发模式(需要与lsq_tusdk_configs.json中masters.key匹配， 如果找不到devType将默认读取master字段)
 */
- (void)initSdkWithAppKey:(NSString *)appKey devType:(NSString *)devType;

/**
 *  布局TuSDK功能的相关视图，统一配置：滤镜+贴纸+美颜
 *  @param superView 滤镜视图需要展示的父视图，如果穿nil即不会默认添加上去，需要各自面板再添加到想要的view上
 */
- (void)configTuSDKViewWithSuperView:(UIView*)superView;

//#pragma mark - 滤镜处理器
///**
// 初始化 TuSDKFilterProcessor
// 
// @param inputType 资源输入格式 GLuint是opengl的渲染
// */
//- (void)initFilterProcessorWithInpuType:(TuSDKManagerFilterInputType)inputType;
//
/**
 *  析构方法 --- 销毁滤镜
 */
- (void)destoryFilterProcessor;


#pragma mark - 帧数据处理
/**
 Process a video sample and return result soon
 
 @param pixelBuffer pixelBuffer pixelBuffer Buffer to process
 @return Video PixelBuffer
 */
- (CVPixelBufferRef)syncProcessPixelBuffer:(CVPixelBufferRef)pixelBuffer timeStamp:(int64_t)timeStamp;

////- (void)syncProcessAudioBuffer:(AudioBuffer *)audioBuffer;
//
///**
// Process a video sample and return result soon
// 
// @param sampleBuffer SampleBuffer Buffer to process
// @return Video PixelBuffer
// */
//- (CVPixelBufferRef)syncProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//
///**
// 在OpenGL线程中调用，在这里可以进行采集图像的二次处理
// @param texture    纹理ID
// @param size      纹理尺寸
// @return           返回的纹理
// */
//- (GLuint)syncProcessTexture:(GLuint)texture textureSize:(CGSize)size;
//
//
///**
// 给filter添加size
// 
// @param outputSize outputSize
// */
//- (void)setOutputSize:(CGSize)outputSize;
//
//
//#pragma mark - TUSDKVIEWS
///**
// 布局TuSDK功能的相关视图，统一配置：滤镜+贴纸+美颜
//
// @param superView 滤镜视图需要展示的父视图，如果穿nil即不会默认添加上去，需要各自面板再添加到想要的view上
// */
//- (void)configTuSDKViewWithSuperView:(UIView*)superView;
//
///**
// 析构方法 --- 销毁TuSDK的视图
//*/
//- (void)destoryTuSDKView;
//
///**
// 配置相机滤镜和漫画滤镜面板
// 
// @param filterCodes 相机滤镜codes
// @param cartoonCodes 漫画codes
// @return 相机滤镜和漫画滤镜一起的面板
// */
//- (UIView *)createFilterPanelViewWithCodes:(NSArray *)filterCodes CartoonCodes:(NSArray *)cartoonCodes;
//
///**
// 创建滤镜面板
// 
// @param codes 相机滤镜codes
// @return 相机滤镜面板
// */
//- (UIView *)createFilterPanelViewWithCodes:(NSArray *)codes;
//
///**
// 创建动漫滤镜面板
// 
// @param codes 相机滤镜codes
// @return 动漫滤镜面板
// */
//- (UIView *)createCartoonViewWithCodes:(NSArray *)codes;
//
///**
// 创建美颜面板
//
// @param skinCodes 美颜codes
// @param plasticCodes 塑性codes
// @return 美颜塑形面板
// */
//- (UIView *)createBeautyPanelViewWithSkinCodes:(NSArray *)skinCodes plasticCodes:(NSArray *)plasticCodes;
//
///**
// 配置相机滤镜面板, 默认不添加到supview上
// 
// @param codes 相机滤镜codes
// @return 相机滤镜面板
// */
//- (UIView *)createScenceViewWithCodes:(NSArray *)codes;
//
///**
// 贴纸面板
// 这里不需要codes，直接加载json文件 --- 是否展示哈哈镜，需要对TuSDKManager进行配置
// 
// @param filePath 贴纸数据文件名
// @return 贴纸面板
// */
//- (UIView *)createPropsViewWithFilePath:(NSString *)filePath;


@end


