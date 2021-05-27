# tusdkfilterprocessormodule

第三方平台快速集成TuSDK的submodule，在更新TuSDK后，直接修改这一submodule的代码及替换最新的TuSDK库，其他第三方平台使用了此submodule的方式集成我们TuSDK的，只需要拉取最新的submodule（tusdkfilterprocessormodule）即可。即达到修改一次应用全平台的效果。


## 项目集成、配置
#### 1、项目集成
- 拉取`tusdkfilterprocessormodule`项目
将`tusdkfilterprocessormodule`项目文件放到你的项目文件夹下，这一步可以是`git`的`submodule`的方式拉取到`tusdkfilterprocessormodule`的项目代码（git的submodule形式依赖请自寻google/百度），也可以直接下载下来放到项目文件夹下。
<br/>

- 导入`tusdkfilterprocessormodule`项目
- 创建`xcworkspace`，如果已有，请看下一步
如果原项目不是`xcworkspace`的方式进行开发的，先创建一个`xcworkspace`，打开`xcworkspace`，点击左下角的`+`号，然后选择`Add file to "xxxxx(这是xcworkspace名称)"...`，接着会弹出选择项目的`finder`，先将原项目添加进行，即选择原项目`项目名称.xcodeproj`进行添加。注意，是`项目名称.xcodeproj`，不是文件夹。注意，是`项目名称.xcodeproj`，不是文件夹。注意，是`项目名称.xcodeproj`，不是文件夹。
<br/>

- 在`xcworkspace`中添加`tusdkfilterprocessormodule`
如果原项目已经是`xcworkspace`或者是上一步创建了的`workspace`，这一步是添加`tusdkfilterprocessormodule`到`xcworkspace`中。即打开`XXXX.xcworkspace`项目，点击左下角`+`，然后选择`Add file to "xxxxx(这是xcworkspace名称)"...`，接着会弹出选择项目的`finder`，找到`tusdkfilterprocessormodule`文件夹中的`tusdkfilterprocessormodule.xcodeproj`项目，添加进去，即可。
如果发现上面两步将项目导入进去后无法点开里面的文件，请将`XXXX.xcworkspace`及相关的项目关掉，然后再次打开`XXXX.xcworkspace`即可，如果还不行，退出`xcode`，然后重新打开`xcworkspace`。
<br/>

- 引入资源文件及头文件
- 引入`tusdkfilterprocessormodule`资源文件
来到项目配置的`General`下的`Linked frameworks and libraries`，点击`+`，将`libtusdkfilterprocessormodule.a`加入进来。然后再点击`+`，点击`Add Other...`，找到`tusdkfilterprocessormodule`文件夹下的`tusdkfilterprocessormodule`文件夹，再到其文件夹下的`TuSDKFramework`的文件夹，即可看到下面的资源包，全部选中，添加。
<br/>

- 引入`tusdkfilterprocessormodule`头文件
然后我们来到项目配置的`Build settings`下，先找到`Framework Search Paths`，然后打开，将上一步的`TuSDKFramework`文件夹拖入进来即可。
然后再找到下面的`Header Search Paths`，打开，将`tusdkfilterprocessormodule`文件夹下的`tusdkfilterprocessormodule`文件夹拖入其中，并设置为`recursive`，这样会递归依赖子文件夹中的头文件。
最后我们导入`tusdkfilterprocessormodule`中依赖的`framework`的头文件也导入其中，同样打开`Header Search Paths`，将`tusdkfilterprocessormodule`中的`tusdkfilterprocessormodule`文件夹拖入其中，如果有其他问题，再来进行添加。
<br/>

- 测试项目集成情况
在`AppDelegate.m`文件中，导入`import<TuSDKManager.h>`，然后编辑，查看是否报错。
<br/>

- 其他报错处理
    - **Build settings**中将**Bitcode**选项设置为**NO**（TuSDK编译平台支持的关系）
    - **Build settings**中在**other linker flags**中添加**-ObjC**
    - **Linked framworks and libs**中添加**libc++.tbd**的依赖
<br/>

#### 2、资源包配置
- 滤镜/特效Codes文件
在我们的Demo中可以看到`TuSDKConstants.h`，打开后，即可看到一系列的`codes`，这里的`codes`需要在[控制台](https://tutucloud.com)进行配置。
<br/>

- Localized本地化语言文件资源
这里的资源文件是配置本地化语言的，如果不添加，不能正常显示`滤镜`或`特效`等名称。
<br/>

- Images滤镜等文件资源
这里是`滤镜`或`特效`等效果图
<br/>

- 贴纸资源
这部分是在一个json文件中配置的，即`customStickerCategories.json`文件，内部的格式可参考demo中的此文件格式。
<br/>

- TuSDK.bundle核心资源
这一部分是最核心的，没有这一部分的资源，整个功能将实现不了。里面的资源文件可参考Demo中的，并到[控制台](https://tutucloud.com)按需配置，配置后下载资源包，替换对应的文件夹。
<br/>

如有不清楚的问题，可以查看[官方文档](https://tutucloud.com/doc)。

## 功能初始化、使用
#### 1、初始化SDK
在AppDelegate中初始化sdk，倒入**TuSDKManager.h**头文件并调用初始化方法。
这里的AppKey，是在[控制台](https://tutucloud.com)中配置后的Key。

```
[[TuSDKManager sharedManager] initSdkWithAppKey:@"4e21c893af64210f-04-ewdjn1"];
```
#### 2、初始化FilterProcessor
- 配置参数：在初始化`filterProcessor`之前
在`TuSDKManager.h`文件中暴露了配置各个美颜特效的`Codes`方法，请根据具体需求进行配置。
另外暴露了部分属性，供使用者调用，如`isOriginalOrientation`、`cameraPosition`等，这些配置会作用到后面初始化的`filterProcessor`中。其他的可参考`TuSDKManager.h`中的注释文档信息。

- 初始化`filterProcessor`
在使用到`涂图`的`美颜`、`滤镜`、`贴纸`等功能的地方进行初始化`filterProcessor`，调用以下方法即可初始化。
- 配置信息, 这里默认是直播 ----- 统一配置：美肤、微整形、滤镜、贴纸、哈哈镜。在这之前需要先设置控制选项

```
/**
@param superView 滤镜视图需要展示的父视图，如果穿nil即不会默认添加上去，需要各自面板再添加到想要的view上
@param inputType 资源输入格式 GLuint是opengl的渲染
*/
- (void)configTuSDKViewWithSuperView:(UIView*)superView;
- (void)initFilterProcessorWithInpuType:(TuSDKManagerFilterInputType)inputType;
```

#### 3、视频帧处理
最后是将filterProgressor中选择的`滤镜`、`美颜`、`贴纸`等特效应用到视频中进行处理。这里给了三个处理方法，具体见注释说明
```
/**
Process a video sample and return result soon

@param pixelBuffer pixelBuffer pixelBuffer Buffer to process
@return Video PixelBuffer
*/
- (CVPixelBufferRef)syncProcessPixelBuffer:(CVPixelBufferRef)pixelBuffer;


/**
Process a video sample and return result soon

@param sampleBuffer SampleBuffer Buffer to process
@return Video PixelBuffer
*/
- (CVPixelBufferRef)syncProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
在OpenGL线程中调用，在这里可以进行采集图像的二次处理
@param texture    纹理ID
@param size      纹理尺寸
@return           返回的纹理
*/
- (GLuint)syncProcessTexture:(GLuint)texture textureSize:(CGSize)size;
```

#### 4、FilterProcessor初始化
(1) TuFilterEngineImpl 是视频滤镜处理 API 的接口，处理的是视频 帧buffer 或 纹理texture 数据

```
- (void)initFilterProcessorWithInpuType:(TuSDKManagerFilterInputType)inputType
{
    if (_filterProcessor)
    {
        [self destoryFilterProcessor];
    }
    
    TuCoderFormat format = {TuFormatMode_Data, TuFormatRange_Video_610}; //输入图像格式
    
    TuFilterEngineImpl *engineImpl = [TuFilterEngineImpl new];
    [engineImpl requestInit:format];
    //设置输入格式
    [engineImpl.inputEngine setFormat:format];
    //设置输入方向
    [engineImpl.inputEngine setRotation:TuRotationMode_Up];
    //设置输出方向
    [engineImpl.outputEngine setRotation:TuRotationMode_Up];
    
    _filterProcessor = engineImpl;
    
    _isInitFilterProcessor = YES;
}
```

(2) 设置普通滤镜效果

```
- (SelesParameters *)tuFilterPanelView:(TuFiltersPanelView *)panelView didSelectedFilterCode:(NSString *)code
{
	//传入滤镜code
    SelesParameters *param = [[_filterProcessor mController] changeFilter:code];
    return param;
}
```

(3) 设置美肤效果
```
/**
	skinType 是枚举类型 :
	TuComboSkin_Empty = 0,  // 重置
	TuComboSkin_Sleek = 1,  // 光滑皮肤
	TuComboSkin_Vein  = 2,  // 纹理皮肤
*/
- (SelesParameters *)skinPanelView:(TuSkinPanelView *)panelView didSelectedSkinType:(TuComboSkinType)skinType
{
    SelesParameters *param = [[_filterProcessor mController] changeSkin:skinType];
    
    [self setBeautySkinDefaultParameters:param skinType:skinType];
    
    return param;
}

- (void)setBeautySkinDefaultParameters:(SelesParameters *)param skinType:(TuComboSkinType)skinType
{
    if (param)
    {
    	//设置美肤初始值
        if (_comboSkinType == TuComboSkin_Empty)
        {
            for (SelesParameterArg *arg in param.args)
            {
                NSString *parameterName = arg.key;
                
                if ([parameterName isEqualToString:@"smoothing"])
                {
                    // 磨皮
                    [param setArgWithKey:parameterName precent:0.7];
                }
                else if ([parameterName isEqualToString:@"whitening"])
                {
                    // 美白
                    [param setArgWithKey:parameterName precent:0.3];
                }
                else if ([parameterName isEqualToString:@"ruddy"])
                {
                    // 红润
                    [param setArgWithKey:parameterName precent:0.2];
                }
            }
        }
        else
        {
        	//切换效果时直接获取已经存储的值
            if (_comboSkinType != skinType)
            {
                for (SelesParameterArg *arg in param.args)
                {
                    NSString *parameterName = arg.key;

                    NSArray *changeArgs = [param changedArgs];
                    for (SelesParameterArg *existArgs in changeArgs)
                    {
                        if ([parameterName isEqualToString:existArgs.key])
                        {
                            [param setArgWithKey:parameterName precent:existArgs.value];
                        }
                    }
                }
            }
        }
        _comboSkinType = skinType;
    }
}

```
(4) 设置微整形效果
```
/**
isEnable为布尔值
NO : 重置效果
YES : 刷新效果
*/
- (SelesParameters *)plasticPanelView:(TuPlasticPanelView *)panelView didSelectedPlastic:(BOOL)isEnable
{
    SelesParameters *param = [[_filterProcessor mController] changePlastic:isEnable];
    param = [self setBeautyPlasticDefaultParameters:param plastic:isEnable];
    return param;
}
```

(5) 设置贴纸效果
```
- (void)stickerPanelView:(TuStickerPanelView *)panelView didSelectItem:(__kindof TuBaseCategoryItem *)categoryItem
{
	//贴纸和哈哈镜效果不能共存，贴纸使用时，需移除哈哈镜效果 
    [[_filterProcessor mController] changeMonster:TuFaceMonster_Empty];
    
    if (!categoryItem)
    {
        // 为nil时 移除已有贴纸组
        [[[_filterProcessor mController] sticker] setGroup:0];
        return;
    }
    TuSDKPFStickerGroup *item = (TuSDKPFStickerGroup *)categoryItem.item;
    [[[_filterProcessor mController] sticker] setGroup:item.idt];
}
```

(6) 设置哈哈镜效果
```
/*
* TuFaceMonsterType为枚举类型 :
*   TuFaceMonster_Empty       = 0,
*   TuFaceMonster_BigNose     = 1, // 大鼻子
*   TuFaceMonster_PieFace     = 2, // 大饼脸
*   TuFaceMonster_SquareFace  = 3, // 国字脸
*   TuFaceMonster_ThickLips   = 4, // 厚嘴唇
*   TuFaceMonster_SmallEyes   = 5, // 眯眯眼
*   TuFaceMonster_PapayaFace  = 6, // 木瓜脸
*   TuFaceMonster_SnakeFace   = 7, // 蛇精脸
*/
- (void)tuMirrorPanelView:(TuMonsterPanelView *)panelView didSelectedMonsterCode:(TuFaceMonsterType)monsterCode
{
	//贴纸和哈哈镜效果不能共存，哈哈镜使用时，需移除贴纸效果 
    [[[_filterProcessor mController] sticker] setGroup:0];
    
    [[_filterProcessor mController] changeMonster:monsterCode];
}
```

如有其他问题，请看[官方文档](https://tutucloud.com/doc)。
