//
//  AppDelegate.m
//  ZegoExpressAudioExample-iOS-OC
//
//  Created by zego on 2020/5/25.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZegoLog.h"
#import "ZegoTTYLogger.h"
#import "ZegoDiskLogger.h"
#import "ZegoRAMStoreLogger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configZegoLog];
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

@end
