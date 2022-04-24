# 即构直播外部滤镜 TuSDK 功能操作说明

## 1.文件构成

### 1.包名

iOS 应用的包名是 Bundle Identifier，它定义在 Project Target 中的 Bundle Identifier。


### 2.秘钥（AppKey）

* 替换 TuSDK 初始化中的秘钥（AppKey），`AppDelegate.m`中引入 #import <TuSDKManager.h>
* 进行初始化 [[TuSDKManager sharedManager] initSdkWithAppKey:@"*******-04-******"];;


### 3.资源文件

* 提供的压缩包中会有 **package_XXXXXX.zip** 文件。
* 解压缩该文件后会有，滤镜、特效资源：*other*、*texture*，贴纸资源：*sticker* 文件。
* *other* 和 *texture*  这两个是必要文件，*sticker*有动态贴纸服务才会出现。

### 4.文件替换操作

* 替换 AppKey 至 TuSDK init 初始化方法中秘钥（AppKey）。
* 将解压缩后的文件替换 **TuSDKPulse.bundle**  文件中的对应文件。
* TuSDK.bundle文件介绍：

（1）model 文件，鉴权文件，必须保留。

（2）others 文件夹，包含使用到的滤镜资源文件的索引，进行滤镜资源文件操作是需要进行替换。

（3）stickers 文件夹，包含打包到本地使用的贴纸的资源文件，进行资源文件操作是需要进行替换（无贴纸功能的可删除）。

（4）textures 文件夹，包含打包到本地使用的滤镜的资源文件，进行资源文件操作是需要进行替换。

## 2.项目集成、配置

### 1.集成方式：

**项目集成、配置的两种方式：**

 一、demo提供的tusdkfilterprocessormodule集成方式。该集成方式中TuSDKManager封装了对滤镜、贴纸、美颜功能的实现，客户通过一些简单方法就可以快速实现并使用滤镜、贴纸、美颜功能。

* **具体的集成方式可以参考Demo中路径下的../tusdkfilterprocessormodule/README.md**


 二、如下的集成方式：**（客户需自定义该功能的UI、逻辑等处理时，建议使用该方式，下面的内容都是介绍该方式的）**

1、将示例工程源码中以下文件拖入到 Xcode 项目中

* `libyuv.framework` ：核心库
* `TuSDKPulse.framework`：核心库
* `TuSDKPulseCore.framework`：核心库
* `TuSDKPulseFilter.framework`：核心库
* `Localized`：`TuSDK.strings` 为项目语言文件。（如有自己的语言文件可以自行配置文案显示）
* `TuSDK.bundle` ：为项目资源文件，包含滤镜，动态贴纸等文件。
* `images`:为项目缩略图（效果图）、UI风格切图资源文件，展示UI布局切图、滤镜，场景特效的效果封面图等图片资源。
* `Assets`:`customStickerCategories.json`为贴纸资源文件的索引，无使用贴纸可忽略不添加。
* `TuSDKConstants.h`:滤镜/特效Codes文件，打开后，即可看到一系列相关`codes`的宏定义，资源包中的对应资源都是通过这里的code读取到对应的资源索引的。
* `Views`:包含TuSDK的滤镜、贴纸、微整形功能板块等视图文件 

2、勾选 **Copy items if needed**，点击 **Finish**。

### 2.项目配置

1、打开 app target，查看 **Build Settings** 中的 **Linking** - **Other Linker Flags** 选项，确保含有 `-ObjC` 一值，若没有则添加。用户使用 Cocoapods 进行了第三方依赖库管理，需要在 `-ObjC` 前添加 `$(inherited)`。`目前直播 SDK 暂不支持 Cocoapods`。

2、 - **Build settings**中将**Bitcode**选项设置为**NO**（TuSDK编译平台支持的关系）。
  
3、 - **Linked framworks and libs**中添加**libc++.tbd**的依赖。

4、 - **Linked framworks and libs**中添加**libresolv.tbd**的依赖。

5、资源文件中包含 `others` 和 `textures`，需要将这两个文件夹替换到 TuSDK.bundle 中对应位置。

6、SDK 暂时不支持 Cocoapods，进行更新操作，请重复步骤1和步骤7。

7、关于TuSDK的滤镜、贴纸、微整形功能的使用，具体可以参考demo中的TuSDKManager类中的实现。

## 3.自定义集成方式（项目集成、配置的方式二）

该方式集成：在项目中检索出 **TuSDKManager.h** 关键词，会发现Views中的视图文件有引入 **TuSDKManager.h** 头文件，需要将TuSDKManager配置滤镜code等方式进行修改；举个例子：

```objective-c
//滤镜视图.m文件中的头文件引入如下
#import "CameraFilterPanelView.h"
#import "CameraNormalFilterListView.h"
#import "CameraComicsFilterListView.h"
#import "PageTabbar.h"
#import "ViewSlider.h"
//#import "TuSDKManager.h"
#import "TuSDKConstants.h"

- (void)commonInit {
    __weak typeof(self) weakSelf = self;
    
    // 普通滤镜列表
    //NSArray *filterCodes = [TuSDKManager sharedManager].filterCodes;
    //将上行代码内容进行修改，不实用TuSDKManager的配置方式
    NSArray *filterCodes = @[kCameraFilterCodes];
}

```

### 1.TuSDK 的初始化

1、在`AppDelegate.m`引入头文件 `#import <TuSDK/TuSDK.h>`。

2、在 `AppDelegate.m` 的 `didFinishLaunchingWithOptions` 方法中添加初始化代码，用户如果需求同一应用不同版本发布，可以参考文档[如何使用多个masterkey](https://tutucloud.com/docs/ios-faq/masterkey)

3、为便于开发，可打开 TuSDK 的调试日志，在初始化方法的同一位置添加以下代码：`[TuSDK setLogLevel:lsqLogLevelDEBUG];`发布应用时请关闭日志。

``` objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        // 初始化SDK (请前往 http://tusdk.com 获取您的 APP 开发密钥)
        [TuSDK initSdkWithAppKey:@"828d700d182dd469-04-ewdjn1"];
        // 多包名 masterkey 方式启动方法
        // @see-https://tusdk.com/docs/ios-faq/masterkey
        // if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.XXXXXXXX.XXXX"]) {
        //  [TuSDK initSdkWithAppKey:@"714f0a1265b39708-02-xie0p1" devType:@"release"];
        //}
        // 开发时请打开调试日志输出
        [TuSDK setLogLevel:lsqLogLevelDEBUG];
    }
 ```

### 2.TuSDKFilterProcessor 的使用

TuSDKFilterProcessor 是视频滤镜处理 API 的接口，处理的是视频 帧buffer 或 纹理texture 数据

1. 在文件中引入 `#import <TuSDKVideo/TuSDKVideo.h>`
2. 遵守协议TuSDKFilterProcessorMediaEffectDelegate
3. 创建对象

```objective-c

 @property (nonatomic,strong) TuSDKFilterProcessor *filterProcessor;

```

4. 初始化对象

```objective-c

    // 传入图像的方向是否为原始朝向(相机采集的原始朝向)，SDK 将依据该属性来调整人脸检测时图片的角度。如果没有对图片进行旋转，则为 YES
    BOOL isOriginalOrientation = NO;
    
    // 初始化，输入的数据类型支持 BGRA 和 YUV 数据
    self.filterProcessor = [[TuSDKFilterProcessor alloc] initWithFormatType:kCVPixelFormatType_32BGRA isOriginalOrientation:isOriginalOrientation];
    
    // 遵守代理 TuSDKFilterProcessorDelegate
    self.filterProcessor.delegate = self;
    
    // 是否开启了镜像
    self.filterProcessor.horizontallyMirrorFrontFacingCamera = NO;
    // 告知摄像头默认位置
    self.filterProcessor.cameraPosition = AVCaptureDevicePositionFront;
    // 输出是否按照原始朝向
    self.filterProcessor.adjustOutputRotation = NO;
    // 开启动态贴纸服务（需要大眼瘦脸特效和动态贴纸的功能需要开启该选项）
    [self.filterProcessor setEnableLiveSticker:YES];
    
    // 切换滤镜（在 TuSDKFilterProcessor 初始化前需要提前配置滤镜代号，即 filterCode 的数组）
    // 默认选中的滤镜代号，这个要与 filterView 默认选择的滤镜顺序保持一致
    [self.filterProcessor addMediaEffect:[[TuSDKMediaFilterEffect alloc] initWithEffectCode:_videoFilters[1]]];

```

5. 代理方法

```objective-c

/**
 当前正在应用的特效
 
 @param processor TuSDKFilterProcessor
 @param mediaEffectData 正在预览特效
 @since 2.2.0
 */
- (void)onVideoProcessor:(TuSDKFilterProcessor *)processor didApplyingMediaEffect:(id<TuSDKMediaEffect>)mediaEffectData;
{

// 其他更多操作
    switch (mediaEffectData.effectType) {
            //赋值新滤镜 同时刷新新滤镜的参数配置；（配合滤镜栏使用）
	//如果需要滤镜栏带有参数，需要执行该代码，否则，默认是不初始化滤镜栏参数的
        case TuSDKMediaEffectDataTypeFilter: {
            [_filterView reloadFilterParamters];
            [_filterPanelView reloadFilterParamters];
            [_videoEditFilterPanelView reloadFilterParamters];
        }
            break;
//赋值微整形特效 同时刷新微整形特效的参数配置；（配合微整形特效栏使用）
	//如果需要微整形特效栏带有参数，需要执行该代码，否则，默认是不初始化滤镜栏参数的
        case TuSDKMediaEffectDataTypePlasticFace: {
            [self updatePlasticFaceDefaultParameters];
        }
            break;
//赋值美颜特效 同时刷新美颜特效的参数配置；（配合美颜栏使用）
	//如果需要美颜栏带有参数，需要执行该代码，否则，默认是不初始化美颜栏参数的
        case TuSDKMediaEffectDataTypeSkinFace: {
            [self updateSkinFaceDefaultParameters];
            break;
        }
        default:
            break;
    }
}

/**
 当某个特效被移除时，该回调就将会被调用
 
 @param processor 特效处理器
 @param mediaEffectDatas 被移除的数据
 */
- (void)onVideoProcessor:(TuSDKFilterProcessor *)processor didRemoveMediaEffects:(NSArray<id<TuSDKMediaEffect>> *)mediaEffectDatas;
{
  
}

```

6. 美颜与微整形参数配置

```objective-c
/**
 重置美颜参数默认值
 */
- (void)updateSkinFaceDefaultParameters;
{
    TuSDKMediaSkinFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
    NSArray<TuSDKFilterArg *> *args = effect.filterArgs;
    BOOL needSubmitParameter = NO;
    
    for (TuSDKFilterArg *arg in args) {
        NSString *parameterName = arg.key;
        // NSLog(@"调节的滤镜参数名称 parameterName: %@",parameterName)
        // 应用保存的参数默认值、最大值
        NSDictionary *savedDefaultDic = _filterParameterDefaultDic[parameterName];
        if (savedDefaultDic) {
            if (savedDefaultDic[kFilterParameterDefaultKey])
                arg.defaultValue = [savedDefaultDic[kFilterParameterDefaultKey] doubleValue];
            
            if (savedDefaultDic[kFilterParameterMaxKey])
                arg.maxFloatValue = [savedDefaultDic[kFilterParameterMaxKey] doubleValue];
            
            // 把当前值重置为默认值
            [arg reset];
            needSubmitParameter = YES;
            continue;
        }
        
        // TUSDK 开放了滤镜等特效的参数调节，用户可根据实际使用场景情况调节效果强度大小
        // Attention ！！
        // 特效的参数并非越大越好，请根据实际效果进行调节
        
        // 是否需要更新参数值
        BOOL updateValue = NO;
        // 默认值的百分比，用于指定滤镜初始的效果（参数默认值 = 最小值 + (最大值 - 最小值) * defaultValueFactor）
        CGFloat defaultValueFactor = 1;
        // 最大值的百分比，用于限制滤镜参数变化的幅度（参数最大值 = 最小值 + (最大值 - 最小值) * maxValueFactor）
        CGFloat maxValueFactor = 1;
        
        if ([parameterName isEqualToString:@"smoothing"]) {
            // 润滑
            maxValueFactor = 0.7;
            defaultValueFactor = 0.6;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"whitening"]) {
            // 白皙
            maxValueFactor = 0.4;
            defaultValueFactor = 0.3;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"ruddy"]) {
            // 红润
            maxValueFactor = 0.4;
            defaultValueFactor = 0.3;
            updateValue = YES;
        }
        
        if (updateValue) {
            if (defaultValueFactor != 1)
                arg.defaultValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * defaultValueFactor * maxValueFactor;
            
            if (maxValueFactor != 1)
                arg.maxFloatValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * maxValueFactor;
            // 把当前值重置为默认值
            [arg reset];
            
            // 存储值
            _filterParameterDefaultDic[parameterName] = @{kFilterParameterDefaultKey: @(arg.defaultValue), kFilterParameterMaxKey: @(arg.maxFloatValue)};
            needSubmitParameter = YES;
        }
    }
    
    // 提交修改结果
    if (needSubmitParameter)
        [effect submitParameters];
    
    [_facePanelView reloadFilterParamters];
}

/**
 重置微整形参数默认值
 */
- (void)updatePlasticFaceDefaultParameters {
    
    TuSDKMediaPlasticFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
    NSArray<TuSDKFilterArg *> *args = effect.filterArgs;
    BOOL needSubmitParameter = NO;
    
    for (TuSDKFilterArg *arg in args) {
        NSString *parameterName = arg.key;
        
        // 是否需要更新参数值
        BOOL updateValue = NO;
        // 默认值的百分比，用于指定滤镜初始的效果（参数默认值 = 最小值 + (最大值 - 最小值) * defaultValueFactor）
        CGFloat defaultValueFactor = 1;
        // 最大值的百分比，用于限制滤镜参数变化的幅度（参数最大值 = 最小值 + (最大值 - 最小值) * maxValueFactor）
        CGFloat maxValueFactor = 1;
        if ([parameterName isEqualToString:@"eyeSize"]) {
            // 大眼
            defaultValueFactor = 0.3;
            maxValueFactor = 0.85;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"chinSize"]) {
            // 瘦脸
            defaultValueFactor = 0.2;
            maxValueFactor = 0.8;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"noseSize"]) {
            // 瘦鼻
            defaultValueFactor = 0.2;
            maxValueFactor = 0.6;
            updateValue = YES;
        } else if ([parameterName isEqualToString:@"mouthWidth"]) {
            // 嘴型
        } else if ([parameterName isEqualToString:@"archEyebrow"]) {
            // 细眉
        } else if ([parameterName isEqualToString:@"jawSize"]) {
            // 下巴
        } else if ([parameterName isEqualToString:@"eyeAngle"]) {
            // 眼角
        } else if ([parameterName isEqualToString:@"eyeDis"]) {
            // 眼距
        }
        
        if (updateValue) {
            if (defaultValueFactor != 1)
                arg.defaultValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * defaultValueFactor * maxValueFactor;
            
            if (maxValueFactor != 1)
                arg.maxFloatValue = arg.minFloatValue + (arg.maxFloatValue - arg.minFloatValue) * maxValueFactor;
            // 把当前值重置为默认值
            [arg reset];
            
            needSubmitParameter = YES;
        }
    }
    
    // 提交修改结果
    if (needSubmitParameter)
        [effect submitParameters];
    
    [_facePanelView reloadFilterParamters];
    
}

```

### 3.录制视频：滤镜-漫画通用栏使用

1. 引入头文件 #import "CameraFilterPanelView.h"
2. 遵守代理 CameraFilterPanelDataSource、CameraFilterPanelDelegate
3. 创建对象

```objective-c
/**
 滤镜-漫画通用栏
 */
@property (nonatomic, strong) CameraFilterPanelView *filterView;

```

4. 初始化滤镜-漫画栏

```objective-c

    // 注：在自己的项目中可自定义UI
    // 滤镜-漫画栏视图
    _filterView = [[CameraFilterPanelView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 276, KScreenWidth, 276)];
    _filterView.delegate = (id<CameraFilterPanelDelegate>)self;
    _filterView.dataSource = (id<CameraFilterPanelDataSource>)self;
    _filterView.hidden = YES;
    [self.view addSubview:filterView];
```

5. 代理方法


* #pragma mark -- 滤镜栏数据源 CameraFilterPanelDataSource

```objective-c

/**
 滤镜/微整形 参数个数

 @return  滤镜/微整形参数数量
 */
- (NSInteger)numberOfParamter:(id<CameraFilterPanelProtocol>)filterPanel {
    // 滤镜视图面板
    switch (_filterView.selectedTabIndex) {
        case 1: // 漫画
        {
            return 0;
        }
        case 0: { // 滤镜
            TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs.count;
        }
    }

    return 0;

}

/**
 滤镜/微整形参数名称

 @param index 滤镜索引
 @return  滤镜/微整形参数名称
 */
- (NSString *)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel paramterNameAtIndex:(NSUInteger)index {

    // 滤镜视图面板
    switch (_filterView.selectedTabIndex) {
        case 1: // 漫画
        {
            return 0;
        }
        case 0:  // 滤镜
        {
            TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs[index].key;
        }
    }

    return @"";
}

/**
 滤镜/微整形参数值

 @param index  滤镜/微整形参数索引
 @return  滤镜/微整形参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel percentValueAtIndex:(NSUInteger)index {
    // 滤镜视图面板
    switch (_filterView.selectedTabIndex) {
        case 1: // 漫画
        {
            return 0;
        }
        case 0:
        {
            TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            return effect.filterArgs[index].precent;
        }
    }

    return 0;
}

```

* #pragma mark -  滤镜栏点击 CameraFilterPanelDelegate

```objective-c

/**
 滤镜面板切换标签回调

 @param filterPanel 滤镜面板
 @param tabIndex 标签索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSwitchTabIndex:(NSInteger)tabIndex {

}

/**
 滤镜面板选中回调

 @param filterPanel 滤镜面板
 @param code 滤镜码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedFilterCode:(NSString *)code {

    // 滤镜视图面板
    switch (_filterView.selectedTabIndex)
    {
        case 1: // 漫画
        {
            TuSDKMediaComicEffect *effect = [[TuSDKMediaComicEffect alloc] initWithEffectCode:code];
            [_filterProcessor addMediaEffect:effect];

            break;
        }
        case 0: { // 滤镜
            TuSDKMediaFilterEffect *effect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:code];
            [_filterProcessor addMediaEffect:effect];
            break;
        }
        default:
            break;
    }
}

/**
 滤镜面板值变更回调

 @param filterPanel 滤镜面板
 @param percentValue 滤镜参数变更数值
 @param index 滤镜参数索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didChangeValue:(double)percentValue paramterIndex:(NSUInteger)index {

    // 滤镜视图面板
    switch (_filterView.selectedTabIndex)
    {
        case 1: // 漫画
        {
            break;
        }
        case 0: {
            TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
            [effect submitParameter:index argPrecent:percentValue];
            break;
        }
    }

}

/**
 重置滤镜参数回调

 @param filterPanel 滤镜面板
 @param paramterKeys 滤镜参数
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel resetParamterKeys:(NSArray *)paramterKeys {

    [_filterProcessor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
}

```
### 3.录制视频：单独滤镜(没有漫画滤镜)的使用

1. 引入头文件 #import "FilterPanelView.h"、#import <TuSDKManager.h>
2. 遵守代理 CameraFilterPanelDataSource、CameraFilterPanelDelegate
3. 创建对象

```objective-c
/**
 滤镜-漫画通用栏
 */
@property (nonatomic, strong) FilterPanelView *filterView;

```

4. 初始化单独滤镜栏

```objective-c

// 注：在自己的项目中可自定义UI
//单独滤镜栏使用
_filterPanelView = [[FilterPanelView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 246, KScreenWidth, 246)];
_filterPanelView.dataSource = self;
_filterPanelView.delegate = self;
_filterPanelView.codes = [codes copy];
_filterPanelView.hidden = YES;
[self.view addSubview:_filterPanelView];

```

 5. 代理方法:
 
* #pragma mark - CameraFilterPanelDataSource

```objective-c

/**
 滤镜/微整形 参数个数
 
 @return  滤镜/微整形参数数量
 */
- (NSInteger)numberOfParamter:(id<CameraFilterPanelProtocol>)filterPanel {
    // 单独滤镜
    TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
    return effect.filterArgs.count;
    
    return 0;
    
}

/**
 滤镜/微整形参数名称
 
 @param index 滤镜索引
 @return  滤镜/微整形参数名称
 */
- (NSString *)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel paramterNameAtIndex:(NSUInteger)index {
    
    // 单独滤镜
    TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
    return effect.filterArgs[index].key;
}

/**
 滤镜/微整形参数值
 
 @param index  滤镜/微整形参数索引
 @return  滤镜/微整形参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel percentValueAtIndex:(NSUInteger)index {
    
    // 单独滤镜
    TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
    return effect.filterArgs[index].precent;
    
}

```

* #pragma mark - CameraFilterPanelDelegate

```objective-c

/**
 滤镜面板切换标签回调
 
 @param filterPanel 滤镜面板
 @param tabIndex 标签索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSwitchTabIndex:(NSInteger)tabIndex {
    
}

/**
 滤镜面板选中回调
 
 @param filterPanel 滤镜面板
 @param code 滤镜码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedFilterCode:(NSString *)code {
    
    // 单独滤镜
    TuSDKMediaFilterEffect *effect = [[TuSDKMediaFilterEffect alloc] initWithEffectCode:code];
    [_filterProcessor addMediaEffect:effect];
}

/**
 滤镜面板值变更回调
 
 @param filterPanel 滤镜面板
 @param percentValue 滤镜参数变更数值
 @param index 滤镜参数索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didChangeValue:(double)percentValue paramterIndex:(NSUInteger)index {
    
    // 单独滤镜
    TuSDKMediaFilterEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeFilter].firstObject;
    [effect submitParameter:index argPrecent:percentValue];
    
}

/**
 重置滤镜参数回调
 
 @param filterPanel 滤镜面板
 @param paramterKeys 滤镜参数
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel resetParamterKeys:(NSArray *)paramterKeys {
    
    // 单独滤镜
    [_filterProcessor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeFilter];
}

```
### 4.录制视频：贴纸的使用

1.引入头文件 #import "StickerPanelView.h"
2.遵守代理 StickerPanelViewDelegate
3.创建对象

```objective-c
/**
 道具栏
 */
@property (nonatomic, strong, readonly) StickerPanelView *stickerView;

```
4.初始化贴纸栏

```objective-c
 		// 初始化贴纸视图
        _stickerView = [[StickerPanelView alloc] initWithFrame:CGRectZero];
        _stickerView.delegate = (id<StickerPanelViewDelegate>)self;
        CGSize size = self.view.bounds.size;
        const CGFloat stickerPanelHeight = 200;
        _stickerView.frame = CGRectMake(0, size.height - 200, size.width, 200);
        [[UIApplication sharedApplication].keyWindow addSubview:_stickerView];
```

5. 代理方法


* #pragma mark -- 贴纸栏点击代理方法 StickerPanelViewDelegate

```objective-c

/**
 贴纸选中回调
 
 @param stickerPanel 相机贴纸协议
 @param sticker 贴纸组
 */
- (void)stickerPanel:(StickerPanelView *)stickerPanel didSelectSticker:(TuSDKPFStickerGroup *)sticker {
    
    TuSDKFilterProcessor *filterProcessor = [[ZegoDemoHelper filterFactory] currentFilter].filterProcessor;
    if (!sticker) {
        // 为nil时 移除已有贴纸组
        [filterProcessor removeMediaEffectsWithType:TuSDKMediaEffectDataTypeSticker];
        return;
    }
    // 展示对应贴纸组
    TuSDKMediaStickerEffect *stickerEffect = [[TuSDKMediaStickerEffect alloc] initWithStickerGroup:sticker];
    [filterProcessor addMediaEffect:stickerEffect];
}
```

## 5、录制视频：美颜、微整形的使用

1. 引入头文件 #import "CameraBeautyPanelView.h"、#import <TuSDKManager.h>
2. 遵守代理 CameraFilterPanelDataSource、CameraFilterPanelDelegate
3. 创建对象

```objective-c
/**
 美颜栏
 */
@property (nonatomic, strong,) CameraBeautyPanelView *facePanelView;

```


4. 初始化滤镜-漫画栏

```

    // 注：在自己的项目中可自定义UI
    // 美颜-微整形栏视图
   _facePanelView = [[CameraBeautyPanelView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 276, KScreenWidth, 276)];
    _facePanelView.delegate = (id<CameraFilterPanelDelegate>)self;
    _facePanelView.dataSource = (id<CameraFilterPanelDataSource>)self;
    _facePanelView.hidden = YES;
     [self.view addSubview:_facePanelView];

```

5. 代理方法


* #pragma mark - CameraFilterPanelDataSource

```objective-c

/**
 滤镜/微整形 参数个数
 
 @return  滤镜/微整形参数数量
 */
- (NSInteger)numberOfParamter:(id<CameraFilterPanelProtocol>)filterPanel {
    // 美颜视图面板
    switch (_facePanelView.selectedTabIndex) {
        case 0: // 美颜
        {
            return [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].count > 0 ? 1 : 0;
        }
        default:
        {
            // 微整形特效
            TuSDKMediaPlasticFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
            return effect.filterArgs.count;
        }
    }
    
    return 0;
    
}

/**
 滤镜/微整形参数名称
 
 @param index 滤镜索引
 @return  滤镜/微整形参数名称
 */
- (NSString *)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel paramterNameAtIndex:(NSUInteger)index {
    
    // 美颜视图面板
    switch (_facePanelView.selectedTabIndex) {
        case 0: // 精准美颜、极度美颜
        {
            return _facePanelView.selectedSkinKey;
        }
        default:
        {
            // 微整形
            TuSDKMediaPlasticFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
            return effect.filterArgs[index].key;
        }
    }
    
}

/**
 滤镜/微整形参数值
 
 @param index  滤镜/微整形参数索引
 @return  滤镜/微整形参数百分比
 */
- (double)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel percentValueAtIndex:(NSUInteger)index {
    
    // 美颜视图面板
    switch (_facePanelView.selectedTabIndex) {
        case 0: // 精准美颜，极度美颜
        {
            TuSDKMediaSkinFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
            return [effect argWithKey:_facePanelView.selectedSkinKey].precent;
        }
        default:
        {
            // 微整形
            TuSDKMediaPlasticFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
            return effect.filterArgs[index].precent;
        }
    }
}

```

* #pragma mark - CameraFilterPanelDelegate

```objective-c

/** 应用美颜特效 */
- (void)applySkinFaceEffect;
{
    /** 初始化美肤特效 */
    TuSDKMediaSkinFaceEffect *skinFaceEffect = [[TuSDKMediaSkinFaceEffect alloc] initUseSkinNatural:_facePanelView.useSkinNatural];
    [_filterProcessor addMediaEffect:skinFaceEffect];
    
    [self updateSkinFaceDefaultParameters];
    
}

/**
 滤镜面板切换标签回调
 
 @param filterPanel 滤镜面板
 @param tabIndex 标签索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSwitchTabIndex:(NSInteger)tabIndex {
    
}

/**
 滤镜面板选中回调
 
 @param filterPanel 滤镜面板
 @param code 滤镜码
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didSelectedFilterCode:(NSString *)code {
    
    // 美颜视图面板
    switch (_facePanelView.selectedTabIndex)
    {
        case 0: // 精准美颜、 极度美颜
        {
            // 如果是切换美颜
            if ([code isEqualToString:self.beautySkinKeys[0]])
            {
                [self applySkinFaceEffect];
                
            }else {
                
                if ([_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].count == 0)
                    [self applySkinFaceEffect];
            }
            
            break;
        }
        default:
        {
            // 微整形
            if ([_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].count == 0) {
                TuSDKMediaPlasticFaceEffect *plasticFaceEffect = [[TuSDKMediaPlasticFaceEffect alloc] init];
                [_filterProcessor addMediaEffect:plasticFaceEffect];
                [self updatePlasticFaceDefaultParameters];
                return;
            }
            break;
        }
    }
}

/**
 滤镜面板值变更回调
 
 @param filterPanel 滤镜面板
 @param percentValue 滤镜参数变更数值
 @param index 滤镜参数索引
 */
- (void)filterPanel:(id<CameraFilterPanelProtocol>)filterPanel didChangeValue:(double)percentValue paramterIndex:(NSUInteger)index {
    
    // 美颜视图面板
    switch (_facePanelView.selectedTabIndex)
    {
        case 0: // 精准美颜,极致美颜
        {
            TuSDKMediaSkinFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypeSkinFace].firstObject;
            [effect submitParameterWithKey:_facePanelView.selectedSkinKey argPrecent:percentValue];
            
            break;
        }
        default: {
            // 微整形
            TuSDKMediaPlasticFaceEffect *effect = [_filterProcessor mediaEffectsWithType:TuSDKMediaEffectDataTypePlasticFace].firstObject;
            [effect submitParameter:index argPrecent:percentValue];
            break;
        }
    }
}

```

## 6.即构直播外部滤镜处理：（详见即构外部滤镜处理链接：https://doc.zego.im/CN/273.html）

* TuSDK通过修改即构开放的视频帧数据pixelbuffer，来完成外部滤镜的渲染。
* 具体使用方式请参考demo中的**TuSDKVideoFilter**、**TuSDKVideoFilterFactory**
* 方法调用：
```objective-c
#pragma mark -- ZegoVideoFilter Delgate

// 初始化外部滤镜使用的资源
- (void)zego_allocateAndStart:(id<ZegoVideoFilterClient>) client {
    client_ = client;
    if ([client_ conformsToProtocol:@protocol(ZegoVideoBufferPool)]) {
        buffer_pool_ = (id<ZegoVideoBufferPool>)client;
    }
    
    width_ = 0;
    height_ = 0;
    stride_ = 0;
    pool_ = nil;
    buffer_count_ = 4;
    self.pendingCount = 0;
    
    queue_ = dispatch_queue_create("video.filter", nil);
    dispatch_async(queue_, ^ {
        [self initFilterProcessor];
    });
    
}

// 停止并释放外部滤镜占用的资源
- (void)zego_stopAndDeAllocate {
    dispatch_sync(queue_, ^ {
        [_filterProcessor destory];
        _filterProcessor = nil;
    });
    
    if (pool_) {
        [ZegoLiveRoomApi destroyPixelBufferPool:&pool_];
    }
    queue_ = nil;
    
    [client_ destroy];
    client_ = nil;
    buffer_pool_ = nil;
}

- (ZegoVideoBufferType)supportBufferType {
    // * 返回滤镜的类型：此滤镜为异步滤镜
    return ZegoVideoBufferTypeAsyncPixelBuffer;
}

#pragma mark -- ZegoVideoBufferPool Delegate

// SDK 回调。从 App 获取 CVPixelBufferRef 对象，用于保存视频帧数据
- (CVPixelBufferRef)dequeueInputBuffer:(int)width height:(int)height stride:(int)stride {
    // * 按需创建 CVPixelBufferPool
    if (width_ != width || height_ != height || stride_ != stride) {
        if (pool_) {
             [ZegoLiveRoomApi destroyPixelBufferPool:&pool_];
        }
        
        if ([ZegoLiveRoomApi createPixelBufferPool:&pool_ width:width height:height]) {
            width_ = width;
            height_ = height;
            stride_ = stride;
        } else {
            return nil;
        }
    }

    // * 如果处理不及时，未处理帧超过了 pool 的大小，则丢弃该帧
    if (self.pendingCount >= buffer_count_) {
        return nil;
    }

    CVPixelBufferRef pixel_buffer = nil;
    CVReturn ret = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool_, &pixel_buffer);

    if (ret != kCVReturnSuccess) {
        return nil;
    } else {
        self.pendingCount = self.pendingCount + 1;
        // * 返回一个可以用于存储采集到的图像的 CVPixelBuffer 实例
        return pixel_buffer;
    }
}

// SDK 回调。App 在此接口中获取 SDK 采集到的视频帧数据，并进行处理
- (void)queueInputBuffer:(CVPixelBufferRef)pixel_buffer timestamp:(unsigned long long)timestamp_100n {
    // * 采集到的图像数据通过这个传进来，这个点需要异步处理
    
    int imageWidth = 0;
    int imageHeight = 0;
    int imageStride = 0;
    
    if (pixel_buffer) {
        imageWidth = (int)CVPixelBufferGetWidth(pixel_buffer);
        imageHeight = (int)CVPixelBufferGetHeight(pixel_buffer);
        imageStride = (int)CVPixelBufferGetBytesPerRowOfPlane(pixel_buffer, 0);
    }

    dispatch_async(queue_, ^ {
        // * 图像滤镜处理
        CVPixelBufferRef newPixelBuffer =  [_filterProcessor syncProcessPixelBuffer:pixel_buffer];
        [self  copyPixelBufferToPool:newPixelBuffer timestamp:timestamp_100n];
        CVPixelBufferRelease(pixel_buffer);
    });
}

#pragma mark -- Private method

// App 将处理好的数据，传递回 SDK
- (void)copyPixelBufferToPool:(CVPixelBufferRef)output timestamp:(unsigned long long)timestamp_100n
{
    int imageWidth = 0;
    int imageHeight = 0;
    int imageStride = 0;

    if (output) {
        imageWidth = (int)CVPixelBufferGetWidth(output);
        imageHeight = (int)CVPixelBufferGetHeight(output);
        imageStride = (int)CVPixelBufferGetBytesPerRowOfPlane(output, 0);
    }

    // * 处理完图像，需要从 buffer pool 中取出一个 CVPixelBuffer 实例，把处理过的图像数据拷贝到该实例中
    CVPixelBufferRef dst = [buffer_pool_ dequeueInputBuffer:imageWidth height:imageHeight stride:imageStride];
    if (!dst) {
        return ;
    }

    [_filterProcessor copyPixelBuffer:output dest:dst];
    // * 把从 buffer pool 中得到的 CVPixelBuffer 实例传进来
    [buffer_pool_ queueInputBuffer:dst timestamp:timestamp_100n];
    
    self.pendingCount = self.pendingCount - 1;
}

```

* zego初始化设置，参考**ZegoAVKitManager** 

```objective-c
+ (ZegoLiveRoomApi *)api
{
	//注释掉即构的内部滤镜
	//[self setupVideoFilter];
  	// TuSDK mark : 设置使用外部滤镜
    [self setUsingExternalFilter:YES];
}


+ (void)setUsingExternalFilter:(bool)bUse
{
    if (g_useExternalFilter == bUse)
        return;
    
    [self releaseApi];
    
    g_useExternalFilter = bUse;
    if (bUse)
    {
        if (g_filterFactory == nullptr)
            g_filterFactory = [[TuSDKVideoFilterFactory alloc] init];
        
        [ZegoLiveRoomApi setVideoFilterFactory:g_filterFactory];
    }
    else
    {
        [ZegoLiveRoomApi setVideoFilterFactory:nil];
    }
}
```

## 7.FAQ

### 1.滤镜替换使用的滤镜的代号

* 替换资源文件后，查看资源文件（TuSDK.bundle/others/lsq_config.json）filterGroups中滤镜的 filerCode（filters/name），替换到项目中对应的位置。
* 替换滤镜资源后，需要根据新的 filterCode 更改对应滤镜效果缩略图文件的名称。
* 举例："name":"lsq_filter_VideoFair"，`VideoFair ` 就是该滤镜的filterCode ，在`_videoFilters = @[@"VideoFair"]`;可以进行选择使用滤镜的设置。

### 2.贴纸替换使用贴纸

* 替换资源文件后，查看资源文件（TuSDK.bundle/others/lsq_config.json） stickerGroups中贴纸的id、name，新增/替换到项目中customStickerCategories.json对应的位置。
* Assets/customStickerCategories.json/categoryName，修改/新增类别名称。
* Assets/customStickerCategories.json/categoryName/stickers，对应类别名称下的组员groups。
* Assets/customStickerCategories.json/categoryName/stickers/name，修改/新增使用贴纸的名称。
* Assets/customStickerCategories.json/categoryName/stickers/id，修改/新增使用贴纸的id。
* Assets/customStickerCategories.json/categoryName/stickers/previewImage，修改/新增使用贴纸的缩略图，只需将最后的一串数字改成id值即可。

### 3.多包名发布

* 参考[多包名发布](https://tutucloud.com/docs/ios-faq/masterkey)
