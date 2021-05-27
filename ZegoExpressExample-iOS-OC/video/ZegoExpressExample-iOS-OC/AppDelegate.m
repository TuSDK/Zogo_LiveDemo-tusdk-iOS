//
//  AppDelegate.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/7.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZegoLog.h"
#import "ZegoTTYLogger.h"
#import "ZegoDiskLogger.h"
#import "ZegoRAMStoreLogger.h"
#import <Bugly/Bugly.h>

//TuSDK mark - 头文件
#import <TuSDKManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bugly startWithAppId:@"87434a25df"];
    [self configZegoLog];
    self.restrictRotation = UIInterfaceOrientationMaskPortrait;
    
    // 可选: 设置日志输出级别 (默认不输出)
    [TuSDKPulseCore setLogLevel:lsqLogLevelDEBUG];
    
    /**
     *  初始化SDK，应用密钥是您的应用在 TuSDK 的唯一标识符。每个应用的包名(Bundle Identifier)、密钥、资源包(滤镜、贴纸等)三者需要匹配，否则将会报错。
     *
     *  @param appkey 应用秘钥 (请前往 http://tusdk.com 申请秘钥)
     */
    [[TuSDKManager sharedManager] initSdkWithAppKey:@"01ef746101e2af04-04-ewdjn1"];
    
    [TUPEngine Init:nil];
    
    return YES;
}

- (void)configZegoLog {
    ZegoTTYLogger *ttyLogger = [ZegoTTYLogger new];
    ttyLogger.level = kZegoLogLevelDebug;
    ZegoRAMStoreLogger *ramLogger = [ZegoRAMStoreLogger new];
    ramLogger.level = kZegoLogLevelDebug;
    ZegoDiskLogger *diskLogger = [ZegoDiskLogger new];
    diskLogger.level = kZegoLogLevelDebug;
    
    [ZegoLog addLogger:ttyLogger];
    [ZegoLog addLogger:ramLogger];
    [ZegoLog addLogger:diskLogger];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return self.restrictRotation;
}

@end
