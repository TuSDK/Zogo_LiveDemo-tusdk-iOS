//
//  ZGTestTopicManager.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright ÂŠ 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestTopicManager.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@interface ZGTestTopicManager () <ZegoEventHandler, ZegoRealTimeSequentialDataEventHandler>

@property (nonatomic, weak) id<ZGTestDataSource> dataSource;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ZegoRealTimeSequentialDataManager *> *rtsdManagerMap;

@end

@implementation ZGTestTopicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rtsdManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    ZGLogInfo(@"đŗī¸ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setZGTestDataSource:(id<ZGTestDataSource>)dataSource {
    self.dataSource = dataSource;
}

- (void)createEngineWithAppID:(unsigned int)appID scenario:(ZegoScenario)scenario {
    ZGLogInfo(@"đ Create ZegoExpressEngine");
    [self.dataSource onActionLog:@"đ Create ZegoExpressEngine"];
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = appID;
    profile.scenario = scenario;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (void)destroyEngine {
    ZGLogInfo(@"đŗī¸ Destroy ZegoExpressEngine");
    [self.dataSource onActionLog:@"đŗī¸ Destroy ZegoExpressEngine"];
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        ZGLogInfo(@"đŠ đŗī¸ Destroy ZegoExpressEngine complete");
    }];
}

- (NSString *)getVersion {
    NSString *version = [ZegoExpressEngine getVersion];
    ZGLogInfo(@"âšī¸ Engine Version: %@", version);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"âšī¸ Engine Version: %@", version]];
    return version;
}

- (void)uploadLog {
    [[ZegoExpressEngine sharedEngine] uploadLog];
    ZGLogInfo(@"đŦ Upload Log");
    [self.dataSource onActionLog:@"đŦ Upload Log"];
}

- (void)enableDebugAssistant:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableDebugAssistant:enable];
    ZGLogInfo(@"đ¤ Enable debug assistant: %d", enable);
}

- (void)setRoomMode:(ZegoRoomMode)mode {
    [ZegoExpressEngine setRoomMode:mode];
    ZGLogInfo(@"đĒ Set room mode: %d", (int)mode);
}

- (void)setDebugVerbose:(BOOL)enable language:(ZegoLanguage)language {
    [[ZegoExpressEngine sharedEngine] setDebugVerbose:enable language:language];
    ZGLogInfo(@"đŦ set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"ä¸­æ");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŦ set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"ä¸­æ"]];
}

- (void)setEngineConfig:(ZegoEngineConfig *)config {
    [ZegoExpressEngine setEngineConfig:config];
    NSMutableString *advancedConfig = [[NSMutableString alloc] init];
    for (NSString *key in config.advancedConfig) {
        [advancedConfig appendFormat:@"%@=%@; ", key, config.advancedConfig[key]];
    }
    ZGLogInfo(@"đŠ Set engien config, advanced config: %@", advancedConfig);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ Set engien config, advanced config: %@", advancedConfig]];
}


#pragma mark Room

- (void)loginRoom:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName token: (NSString *)token{
    ZegoRoomConfig *roomConfig = [[ZegoRoomConfig alloc] init];
    roomConfig.isUserStatusNotify = YES;
    roomConfig.token = token;
    [[ZegoExpressEngine sharedEngine] loginRoom:roomID user:[ZegoUser userWithUserID:userID userName:userName] config:roomConfig];
    ZGLogInfo(@"đĒ Login room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đĒ Login room. roomID: %@", roomID]];
}

- (void)switchRoom:(NSString *)fromRoomID toRoomID:(NSString *)toRoomID {
    [[ZegoExpressEngine sharedEngine] switchRoom:fromRoomID toRoomID:toRoomID];
    ZGLogInfo(@"đĒ Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đĒ Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID]];
}


- (void)logoutRoom:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] logoutRoom:roomID];
    ZGLogInfo(@"đĒ Logout room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đĒ Logout room. roomID: %@", roomID]];
}


#pragma mark Publish

- (void)startPublishingStream:(NSString *)streamID roomID:(nullable NSString *)roomID {
    if (roomID) {
        ZegoPublisherConfig *config = [[ZegoPublisherConfig alloc] init];
        config.roomID = roomID;
        [[ZegoExpressEngine sharedEngine] startPublishingStream:streamID config:config channel:ZegoPublishChannelMain];
    } else {
        [[ZegoExpressEngine sharedEngine] startPublishingStream:streamID];
    }
    ZGLogInfo(@"đ¤ Start publishing stream. streamID: %@", streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ¤ Start publishing stream. streamID: %@", streamID]];
}


- (void)stopPublishingStream {
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    ZGLogInfo(@"đ¤ Stop publishing stream");
    [self.dataSource onActionLog:@"đ¤ Stop publishing stream"];
}


- (void)startPreview:(ZegoCanvas *)canvas {
    [[ZegoExpressEngine sharedEngine] startPreview:canvas];
    ZGLogInfo(@"đ Start preview");
    [self.dataSource onActionLog:@"đ Start preview"];
}


- (void)stopPreview {
    [[ZegoExpressEngine sharedEngine] stopPreview];
    ZGLogInfo(@"đ Stop preview");
    [self.dataSource onActionLog:@"đ Stop preview"];
}


- (void)setVideoConfig:(ZegoVideoConfig *)videoConfig {
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    ZGLogInfo(@"đ§ˇ Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ˇ Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps]];
}


- (void)setVideoMirrorMode:(ZegoVideoMirrorMode)mirrorMode {
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:mirrorMode];
    ZGLogInfo(@"âī¸ Set video mirror mode. Mode: %d", (int)mirrorMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"âī¸ Set video mirror mode. Mode: %d", (int)mirrorMode]];
}


- (void)setAppOrientation:(UIInterfaceOrientation)orientation {
    [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];
    ZGLogInfo(@"âī¸ Set capture orientation: %d", (int)orientation);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"âī¸ Set capture orientation: %d", (int)orientation]];
}

- (ZegoAudioConfig *)getAudioConfig {
    return [[ZegoExpressEngine sharedEngine] getAudioConfig];
}

- (void)setAudioConfig:(ZegoAudioConfig *)config {
    [[ZegoExpressEngine sharedEngine] setAudioConfig:config];
    ZGLogInfo(@"đ§ˇ Set audio config. bitrate: %d, channel: %d, codecID: %d", config.bitrate, (int)config.channel, (int)config.codecID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ˇ Set audio config. bitrate: %d, channel: %d, codecID: %d", config.bitrate, (int)config.channel, (int)config.codecID]];
}


- (void)mutePublishStreamAudio:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamAudio:mute];
    ZGLogInfo(@"đ Mute publish stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Mute publish stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePublishStreamVideo:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamVideo:mute];
    ZGLogInfo(@"đ Mute publish stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Mute publish stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)setCaptureVolume:(int)volume {
    [[ZegoExpressEngine sharedEngine] setCaptureVolume:volume];
    ZGLogInfo(@"â Set capture volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"â Set capture volume: %d", volume]];
}


- (void)addPublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] addPublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"đŠ đ Add publish cdn url result: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ Add publish cdn url result: %d", errorCode]];
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"đ Add publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Add publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)removePublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] removePublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"đŠ đ Remove publish cdn url result: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ Remove publish cdn url result: %d", errorCode]];
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"đ Remove publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Remove publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)enableHardwareEncoder:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:enable];
    ZGLogInfo(@"đ§ Enable hardware encoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable hardware encoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)setWatermark:(ZegoWatermark *)watermark isPreviewVisible:(BOOL)isPreviewVisible {
    [[ZegoExpressEngine sharedEngine] setPublishWatermark:watermark isPreviewVisible:isPreviewVisible];
    ZGLogInfo(@"đ Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO"]];
}

- (void)setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)scaleMode {
    [[ZegoExpressEngine sharedEngine] setCapturePipelineScaleMode:scaleMode];
    ZGLogInfo(@"đ§ Set capture pipeline scale mode: %d", (int)scaleMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Set capture pipeline scale mode: %d", (int)scaleMode]];
}

- (void)sendSEI:(NSData *)data {
    [[ZegoExpressEngine sharedEngine] sendSEI:data];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ZGLogInfo(@"âī¸ Send SEI: %@", str);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"âī¸ Send SEI: %@", str]];
}

- (void)setAudioCaptureStereoMode:(ZegoAudioCaptureStereoMode)mode {
    [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:mode];
    ZGLogInfo(@"đļ Set audio capture stereo mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đļ Set audio capture stereo mode: %d", (int)mode]];
}


#pragma mark Player

- (void)startPlayingStream:(NSString *)streamID canvas:(ZegoCanvas *)canvas roomID:(nullable NSString *)roomID {
    if (roomID) {
        ZegoPlayerConfig *config = [[ZegoPlayerConfig alloc] init];
        config.resourceMode = ZegoStreamResourceModeOnlyRTC;
        config.roomID = roomID;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:canvas config:config];
    } else {
        [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:canvas];
    }
    ZGLogInfo(@"đĨ Start playing stream");
    [self.dataSource onActionLog:@"đĨ Start playing stream"];
}


- (void)stopPlayingStream:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:streamID];
    ZGLogInfo(@"đĨ Stop playing stream");
    [self.dataSource onActionLog:@"đĨ Stop playing stream"];
}


- (void)setPlayVolume:(int)volume stream:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] setPlayVolume:volume streamID:streamID];
    ZGLogInfo(@"â Set play volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"â Set play volume: %d", volume]];
}


- (void)mutePlayStreamAudio:(BOOL)mute streamID:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:mute streamID:streamID];
    ZGLogInfo(@"đ Mute play stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Mute play stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePlayStreamVideo:(BOOL)mute streamID:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:mute streamID:streamID];
    ZGLogInfo(@"đ Mute play stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ Mute play stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableHarewareDecoder:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:enable];
    ZGLogInfo(@"đ§ Enable hardware decoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable hardware decoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)enableCheckPoc:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableCheckPoc:enable];
    ZGLogInfo(@"đ§ Enable check poc: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable check poc: %@", enable ? @"YES" : @"NO"]];
}


#pragma mark PreProcess

- (void)enableAEC:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAEC:enable];
    ZGLogInfo(@"đ§ Enable AEC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable AEC: %@", enable ? @"YES" : @"NO"]];
}


- (void)setAECMode:(ZegoAECMode)mode {
    [[ZegoExpressEngine sharedEngine] setAECMode:mode];
    ZGLogInfo(@"â Set AEC mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"â Set AEC mode: %d", (int)mode]];
}


- (void)enableAGC:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAGC:enable];
    ZGLogInfo(@"đ§ Enable AGC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable AGC: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableANS:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableANS:enable];
    ZGLogInfo(@"đ§ Enable ANS: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable ANS: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableBeautify:(int)feature {
    [[ZegoExpressEngine sharedEngine] enableBeautify:feature];
    ZGLogInfo(@"â Enable beautify: %d", (int)feature);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"â Enable beautify: %d", (int)feature]];
}


- (void)setBeautifyOption:(ZegoBeautifyOption *)option {
    [[ZegoExpressEngine sharedEngine] setBeautifyOption:option];
    ZGLogInfo(@"đ§ Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor]];
}


#pragma mark Device

- (void)muteMicrophone:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] muteMicrophone:mute];
    ZGLogInfo(@"đ§ Mute microphone: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Mute microphone: %@", mute ? @"YES" : @"NO"]];
}


- (void)muteSpeaker:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] muteSpeaker:mute];
    ZGLogInfo(@"đ§ Mute audio output: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Mute audio output: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableCamera:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableCamera:enable];
    ZGLogInfo(@"đ§ Enable camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)useFrontCamera:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] useFrontCamera:enable];
    ZGLogInfo(@"đ§ Use front camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Use front camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableAudioCaptureDevice:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAudioCaptureDevice:enable];
    ZGLogInfo(@"đ§ Enable audio capture device: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đ§ Enable audio capture device: %@", enable ? @"YES" : @"NO"]];
}

- (void)startSoundLevelMonitor {
    [[ZegoExpressEngine sharedEngine] startSoundLevelMonitor];
    ZGLogInfo(@"đŧ Start sound level monitor");
    [self.dataSource onActionLog:@"đŧ Start sound level monitor"];
}

- (void)stopSoundLevelMonitor {
    [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    ZGLogInfo(@"đŧ Stop sound level monitor");
    [self.dataSource onActionLog:@"đŧ Stop sound level monitor"];
}

- (void)startAudioSpectrumMonitor {
    [[ZegoExpressEngine sharedEngine] startAudioSpectrumMonitor];
    ZGLogInfo(@"đŧ Start audio spectrum monitor");
    [self.dataSource onActionLog:@"đŧ Start audio spectrum monitor"];
}

- (void)stopAudioSpectrumMonitor {
    [[ZegoExpressEngine sharedEngine] stopAudioSpectrumMonitor];
    ZGLogInfo(@"đŧ Stop audio spectrum monitor");
    [self.dataSource onActionLog:@"đŧ Stop audio spectrum monitor"];
}

- (void)startPerformanceMonitor {
    [[ZegoExpressEngine sharedEngine] startPerformanceMonitor:2000];
    ZGLogInfo(@"đĨ Start performance monitor");
    [self.dataSource onActionLog:@"đĨ Start performance monitor"];
}

- (void)stopPerformanceMonitor {
    [[ZegoExpressEngine sharedEngine] stopPerformanceMonitor];
    ZGLogInfo(@"đĨ Stop performance monitor");
    [self.dataSource onActionLog:@"đĨ Stop performance monitor"];
}

#pragma mark Mixer

- (void)startMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"đ§Ŧ Start mixer task");
    [self.dataSource onActionLog:@"đ§Ŧ Start mixer task"];
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"đŠ đ§Ŧ Start mixer task result errorCode: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ§Ŧ Start mixer task result errorCode: %d", errorCode]];
    }];
}

- (void)stopMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"đ§Ŧ Stop mixer task");
    [self.dataSource onActionLog:@"đ§Ŧ Stop mixer task"];
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] stopMixerTask:task callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"đŠ đ§Ŧ Stop mixer task result errorCode: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ§Ŧ Stop mixer task result errorCode: %d", errorCode]];
    }];
}

#pragma mark IM

- (void)sendBroadcastMessage:(NSString *)message roomID:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] sendBroadcastMessage:message roomID:roomID callback:^(int errorCode, unsigned long long messageID) {
        ZGLogInfo(@"đŠ âī¸ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID);
    }];
}

- (void)sendCustomCommand:(NSString *)command toUserList:(nullable NSArray<ZegoUser *> *)toUserList roomID:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] sendCustomCommand:command toUserList:nil roomID:roomID callback:^(int errorCode) {
        ZGLogInfo(@"đŠ âī¸ Send custom command (to all user) result errorCode: %d", errorCode);
    }];
}

#pragma mark RTSD

- (void)createRealTimeSequentialDataManager:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = [[ZegoExpressEngine sharedEngine] createRealTimeSequentialDataManager:roomID];
    if (manager) {
        self.rtsdManagerMap[roomID] = manager;
        ZGLogInfo(@"đž Create RTSD manager, roomID: %@, index: %d", roomID, [manager getIndex].intValue);
        [manager setEventHandler:self];
    } else {
        ZGLogError(@"đž â Create RTSD manager failed, roomID: %@", roomID);
    }
}

- (void)destroyRealTimeSequentialDataManager:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [[ZegoExpressEngine sharedEngine] destroyRealTimeSequentialDataManager:manager];
        [self.rtsdManagerMap removeObjectForKey:roomID];
        ZGLogInfo(@"đž Destroy RTSD manager, roomID: %@, index: %d", roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â Destroy RTSD manager failed, roomID: %@", roomID);
    }
}

- (void)startBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager startBroadcasting:streamID];
        ZGLogInfo(@"đž RTSD start broadcasting, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â No RTSD manager for roomID: %@", roomID);
    }
}

- (void)stopBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager stopBroadcasting:streamID];
        ZGLogInfo(@"đž RTSD stop broadcasting, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â No RTSD manager for roomID: %@", roomID);
    }
}

- (void)sendRealTimeSequentialData:(NSString *)data streamID:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager sendRealTimeSequentialData:[data dataUsingEncoding:NSUTF8StringEncoding] streamID:streamID callback:^(int errorCode) {
            ZGLogInfo(@"đŠ đž RTSD send data result, errorCode: %d", errorCode);
        }];
        ZGLogInfo(@"đž RTSD start send data: %@, streamID: %@, roomID: %@, index: %d", data, streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â No RTSD manager for roomID: %@", roomID);
    }
}

- (void)startSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager startSubscribing:streamID];
        ZGLogInfo(@"đž RTSD start subscribing, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â No RTSD manager for roomID: %@", roomID);
    }
}

- (void)stopSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager stopSubscribing:streamID];
        ZGLogInfo(@"đž RTSD stop subscribing, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"đž â No RTSD manager for roomID: %@", roomID);
    }
}

#pragma mark Utils

- (void)startNetworkSpeedTest {
    ZGLogInfo(@"đ Start network speed test");
    [self.dataSource onActionLog:@"đ Start network speed test"];
    ZegoNetworkSpeedTestConfig *config = [[ZegoNetworkSpeedTestConfig alloc] init];
    config.testUplink = YES;
    config.testDownlink = YES;
    config.expectedUplinkBitrate = config.expectedDownlinkBitrate = [[ZegoExpressEngine sharedEngine] getVideoConfig].bitrate;
    [[ZegoExpressEngine sharedEngine] startNetworkSpeedTest:config];

}

- (void)stopNetworkSpeedTest {
    ZGLogInfo(@"đ Stop network speed test");
    [self.dataSource onActionLog:@"đ Stop network speed test"];
    [[ZegoExpressEngine sharedEngine] stopNetworkSpeedTest];
}


#pragma mark - Callback

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"đŠ â Debug Error Callback: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

#pragma mark Room Callback

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đĒ Room State Update Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)state, (int)errorCode, roomID);
}


- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đē Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đ Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đ Room Stream Extra Info Update Callback, StreamsCount: %lu, roomID: %@", (unsigned long)streamList.count, roomID);
}

#pragma mark Publisher Callback

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ¤ Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ Publisher Quality Update Callback: FPS:%f, Bitrate:%f, streamID: %@", quality.videoSendFPS, quality.videoKBPS, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPublisherQualityUpdate:)]) {
        [self.dataSource onPublisherQualityUpdate:quality];
    }
}

- (void)onPublisherCapturedAudioFirstFrame {
    ZGLogInfo(@"đŠ â¨ Publisher Captured Audio First Frame Callback");
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    ZGLogInfo(@"đŠ â¨ Publisher Captured Audio First Frame Callback, channel: %d", (int)channel);
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    ZGLogInfo(@"đŠ đ Publisher Video Size Changed Callback: Width: %f, Height: %f, channel: %d", size.width, size.height, (int)channel);
    
    if ([self.dataSource respondsToSelector:@selector(onPublisherVideoSizeChanged:)]) {
        [self.dataSource onPublisherVideoSizeChanged:size];
    }
}

- (void)onPublisherRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)streamInfoList streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đĄ Publisher Relay CDN State Update Callback: Relaying CDN Count: %lu, streamID: %@", (unsigned long)streamInfoList.count, streamID);
    for (ZegoStreamRelayCDNInfo *info in streamInfoList) {
        ZGLogInfo(@"đŠ đĄ --- state: %d, reason: %d, url: %@", (int)info.state, (int)info.updateReason, info.url);
    }
}

#pragma mark Player Callback

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đĨ Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ Player Quality Update Callback: FPS:%f, Bitrate:%f, streamID: %@", quality.videoRecvFPS, quality.videoKBPS, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPlayerQualityUpdate:)]) {
        [self.dataSource onPlayerQualityUpdate:quality];
    }
}

- (void)onPlayerMediaEvent:(ZegoPlayerMediaEvent)event streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ Player Media Event Callback: %lu, streamID: %@", (unsigned long)event, streamID);
}

- (void)onPlayerRecvAudioFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"đŠ âĄī¸ Player Recv Audio First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerRecvVideoFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"đŠ âĄī¸ Player Recv Video First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerRenderVideoFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"đŠ âĄī¸ Player Recv Render First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ Player Video Size Changed Callback: Width: %f, Height: %f, streamID: %@", size.width, size.height, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPlayerVideoSizeChanged:)]) {
        [self.dataSource onPlayerVideoSizeChanged:size];
    }
}

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ âī¸ Player Recv SEI: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

#pragma mark Device Callback

- (void)onLocalDeviceExceptionOccurred:(ZegoDeviceExceptionType)exceptionType deviceType:(ZegoDeviceType)deviceType deviceID:(NSString *)deviceID {
    ZGLogInfo(@"đŠ đģ Local Device Exception Occurred Callback: exceptionType: %lu, deviceType: %lu, deviceID: %@", exceptionType, deviceType, deviceID);
}

- (void)onRemoteCameraStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đˇ Remote Camera State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

- (void)onRemoteMicStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    ZGLogInfo(@"đŠ đ Remote Mic State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

#pragma mark Mixer Callback

- (void)onMixerRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList taskID:(NSString *)taskID {
    ZGLogInfo(@"đŠ đ§Ŧ Mixer Relay CDN State Update Callback: taskID: %@", taskID);
    for (int idx = 0; idx < infoList.count; idx ++) {
        ZegoStreamRelayCDNInfo *info = infoList[idx];
        ZGLogInfo(@"đŠ đ§Ŧ --- %d: state: %lu, URL: %@, reason: %lu", idx, (unsigned long)info.state, info.url, (unsigned long)info.updateReason);
    }
}

#pragma mark IM Callback

- (void)onIMRecvBroadcastMessage:(NSArray<ZegoBroadcastMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đŠ IM Recv Broadcast Message Callback: roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ Received Broadcast Message"]];
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBroadcastMessageInfo *info = messageList[idx];
        ZGLogInfo(@"đŠ đŠ --- %d: message: %@, fromUserID: %@, sendTime: %llu", idx, info.message, info.fromUser.userID, info.sendTime);
        [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ [%@] --- from %@, time: %llu", info.message, info.fromUser.userID, info.sendTime]];
    }
}

- (void)onIMRecvBarrageMessage:(NSArray<ZegoBarrageMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đŠ IM Recv Barrage Message Callback: roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ Received Broadcast Message"]];
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBarrageMessageInfo *info = messageList[idx];
        ZGLogInfo(@"đŠ đŠ --- %d: message: %@, fromUserID: %@, sendTime: %llu", idx, info.message, info.fromUser.userID, info.sendTime);
        [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ [%@] --- from %@, time: %llu", info.message, info.fromUser.userID, info.sendTime]];
    }
}

- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(ZegoUser *)fromUser roomID:(NSString *)roomID {
    ZGLogInfo(@"đŠ đŠ IM Recv Custom Command Callback: command: %@, fromUserID: %@, roomID: %@", command, fromUser.userID, roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ Received Custom Command"]];
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ [%@] --- from %@", command, fromUser.userID]];
}

#pragma mark Device Callback

- (void)onPerformanceStatusUpdate:(ZegoPerformanceStatus *)status {
    ZGLogInfo(@"đŠ đĨ Performance Status Update: CPU-App:%.4f, CPU-Sys:%.4f, MemApp:%.4f, MemSys:%.4f, MemUsedApp:%.1fMB", status.cpuUsageApp, status.cpuUsageSystem, status.memoryUsageApp, status.memoryUsageSystem, status.memoryUsedApp);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đĨ Performance Status Update: CPU-App:%.4f, CPU-Sys:%.4f, MemApp:%.4f, MemSys:%.1f, MemUsedApp:%.1fMB", status.cpuUsageApp, status.cpuUsageSystem, status.memoryUsageApp, status.memoryUsageSystem, status.memoryUsedApp]];
}

#pragma mark RTSD Callback

- (void)manager:(ZegoRealTimeSequentialDataManager *)manager receiveRealTimeSequentialData:(NSData *)data streamID:(NSString *)streamID {
    NSString *roomID = @"â";
    for (NSString *key in self.rtsdManagerMap) {
        int idx = [self.rtsdManagerMap[key] getIndex].intValue;
        if (idx == [manager getIndex].intValue) {
            roomID = key;
        }
    }
    ZGLogInfo(@"đŠ đž Receive RTSD data: %@, manageridx: %d, streamID: %@, roomID: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], [manager getIndex].intValue, streamID, roomID);
}

#pragma mark Utils Callback

- (void)onNetworkModeChanged:(ZegoNetworkMode)mode {
    ZGLogInfo(@"đŠ đ Network Mode Changed Callback: mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ Network Mode Changed Callback: mode: %d", (int)mode]];
}

- (void)onNetworkSpeedTestError:(int)errorCode type:(ZegoNetworkSpeedTestType)type {
    ZGLogInfo(@"đŠ đ Network Speed Test Error Callback: errorCode: %d, type: %d", errorCode, (int)type);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ Network Speed Test Error Callback: errorCode: %d, type: %d", errorCode, (int)type]];
}

- (void)onNetworkSpeedTestQualityUpdate:(ZegoNetworkSpeedTestQuality *)quality type:(ZegoNetworkSpeedTestType)type {
    ZGLogInfo(@"đŠ đ Network Speed Test Quality Update Callback: cost: %d, rtt: %d, plr: %.1f, type: %d", quality.connectCost, quality.rtt, quality.packetLostRate, (int)type);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"đŠ đ Network Speed Test Quality Update Callback: cost: %d, rtt: %d, plr: %.1f, type: %d", quality.connectCost, quality.rtt, quality.packetLostRate, (int)type]];
}

@end

#endif
