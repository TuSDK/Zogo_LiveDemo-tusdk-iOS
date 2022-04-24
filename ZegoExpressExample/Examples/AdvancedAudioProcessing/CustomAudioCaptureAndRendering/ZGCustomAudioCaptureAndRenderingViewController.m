//
//  ZGCustomAudioCaptureAndRenderingViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

// When the custom audio render is turned on, whether to save the audio render data to a local file while using the speaker to play the data
#define SAVE_AUDIO_RENDER_DATA_TO_FILE 1

#import "ZGCustomAudioCaptureAndRenderingViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGAudioToolPlayer.h"
#import "ZGAudioToolRecorder.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <ZegoExpressEngine/ZegoExpressEngine+AudioEffectPlayer.h>

@interface ZGCustomAudioCaptureAndRenderingViewController () <ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;

@property (nonatomic, assign) ZegoPlayerState playerState;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;


@property (nonatomic, strong) ZegoAudioFrameParam *audioCapturedFrameParam;
@property (nonatomic, strong) ZegoAudioFrameParam *audioRenderFrameParam;
@property (nonatomic, strong) ZegoAudioEffectPlayer *player;


// Audio capture timer (used by local media source)
@property (strong, nonatomic) NSTimer *audioCaptureTimer;
// Audio data to be sent (used by local media source)
@property (nonatomic, strong) NSInputStream *audioCapturedDataInputStream;
// Audio origin data position (used by local media source)
@property (nonatomic, assign) void *audioCapturedDataPosition;

#if SAVE_AUDIO_RENDER_DATA_TO_FILE
// Total custom audio render data to be save
@property (nonatomic, strong) NSMutableData *audioRenderData;
#endif

@end

@implementation ZGCustomAudioCaptureAndRenderingViewController
{
    ZGAudioToolPlayer *_audioToolPlayer;
    ZGAudioToolRecorder *_audioToolRecorder;
}

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioIO" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomAudioCaptureAndRenderingViewController class])];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.audioRenderFrameParam = [[ZegoAudioFrameParam alloc] init];
    self.audioRenderFrameParam.channel = 1;
    self.audioRenderFrameParam.sampleRate = ZegoAudioSampleRate16K;
    
    self.audioCapturedFrameParam = [[ZegoAudioFrameParam alloc] init];
    self.audioCapturedFrameParam.channel = 1;
    self.audioCapturedFrameParam.sampleRate = ZegoAudioSampleRate16K;
    
    [self createEngineAndLoginRoom];

#if SAVE_AUDIO_RENDER_DATA_TO_FILE
    self.audioRenderData = [NSMutableData data];
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.audioSourceType == ZGCustomAudioCaptureSourceTypeLocalMedia && [self.audioCaptureTimer isValid]) {
        ZGLogInfo(@"⏱ Custom audio capture timer invalidate");
        [self.audioCaptureTimer invalidate];
        self.audioCaptureTimer = nil;
    }

    [self stopPlaying:self.enableCustomAudioRender];
    
    if (self.player) {
        [self.player stop:1];
    }
    
    if (_audioToolRecorder) {
        [_audioToolRecorder stop];
    }

    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)createEngineAndLoginRoom {

    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.advancedConfig = @{@"ext_capture_and_inner_render": self.enableCustomAudioRender ? @"false" : @"true"};
    [ZegoExpressEngine setEngineConfig:engineConfig];

    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];


    if (self.enableCustomAudioRender) {
        ZegoCustomAudioConfig *audioConfig = [[ZegoCustomAudioConfig alloc] init];
        audioConfig.sourceType = ZegoAudioSourceTypeCustom;

        ZGLogInfo(@"🎶 Enable custom audio io");
        [[ZegoExpressEngine sharedEngine] enableCustomAudioIO:YES config:audioConfig];
    }

    // Enable 3A process
    [[ZegoExpressEngine sharedEngine] enableAEC:YES];
    [[ZegoExpressEngine sharedEngine] enableANS:YES];
    [[ZegoExpressEngine sharedEngine] enableAGC:YES];

    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];

    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:config];
}


- (IBAction)startPublishButtonClick:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {

        [self stopPublishing:self.audioSourceType];

    } else if (self.publisherState == ZegoPublisherStateNoPublish) {

        [self startPublishing:self.audioSourceType];
    }
}

- (IBAction)startPlayButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {

        [self stopPlaying:self.enableCustomAudioRender];

    } else if (self.playerState == ZegoPlayerStateNoPlay) {

        [self startPlaying:self.enableCustomAudioRender];
    }
}

- (void)startPublishing:(ZGCustomAudioCaptureSourceType)captureSourceType {

    ZGLogInfo(@"🔌 Start preview");
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.localPublishStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamID];


    if (captureSourceType == ZGCustomAudioCaptureSourceTypeLocalMedia) {
        if (!self.enableCustomAudioRender) {
            if (!self.player) {
                self.player = [[ZegoExpressEngine sharedEngine] createAudioEffectPlayer];
            }
            
            // TODO:
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"wav"];
            
            ZegoAudioEffectPlayConfig *config = [[ZegoAudioEffectPlayConfig alloc] init];
            config.playCount = 0;
            config.isPublishOut = YES;
            
            [self.player start:1 path:filePath config:config];
        } else {
            if (!self.audioCapturedDataInputStream) {
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"wav"];
                NSInputStream *inputSteam = [NSInputStream inputStreamWithURL:url];
                self.audioCapturedDataInputStream = inputSteam;
            }
            [self.audioCapturedDataInputStream open];

            // Start a timer that triggers every 20ms to send audio data
            if (!self.audioCaptureTimer) {
                self.audioCaptureTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(sendCapturedAudioFrame) userInfo:nil repeats:YES];
                [NSRunLoop.mainRunLoop addTimer:self.audioCaptureTimer forMode:NSRunLoopCommonModes];
            }
            ZGLogInfo(@"⏱ Custom audio capture timer fire");
            [self.audioCaptureTimer fire];
        }

    } else if (captureSourceType == ZGCustomAudioCaptureSourceTypeDeviceMicrophone) {

        if (!_audioToolRecorder) {
            _audioToolRecorder = [[ZGAudioToolRecorder alloc] initWithSampleRate:ZegoAudioSampleRate16K bufferSize:[self bufferSize]];
            __weak ZGCustomAudioCaptureAndRenderingViewController *weakSelf = self;
            _audioToolRecorder.bl_output = ^(ZGAudioToolRecorder *recorder,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp *inTimeStamp,
                                             UInt32 inBusNumber,
                                             UInt32 inNumberFrames,
                                             AudioBufferList *bufferList) {
                AudioBuffer buffer = bufferList->mBuffers[0];
                unsigned int length = (unsigned int)buffer.mDataByteSize;
                [[ZegoExpressEngine sharedEngine] sendCustomAudioCapturePCMData:buffer.mData dataLength:length param:weakSelf.audioCapturedFrameParam];

            };
        }
        ZGLogInfo(@"🎙 Custom audio capture microphone start record");
        [_audioToolRecorder start];
    }
}

- (void)stopPublishing:(ZGCustomAudioCaptureSourceType)captureSourceType {

    if (captureSourceType == ZGCustomAudioCaptureSourceTypeLocalMedia) {
        if (!self.enableCustomAudioRender) {
            [self.player stop:1];
        } else {
            if (self.audioCaptureTimer) {
                ZGLogInfo(@"⏱ Custom audio capture timer invalidate");
                [self.audioCaptureTimer invalidate];
                self.audioCaptureTimer = nil;
            }

            if (self.audioCapturedDataInputStream) {
                [self.audioCapturedDataInputStream close];
                self.audioCapturedDataInputStream = nil;
            }
        }

    } else if (captureSourceType == ZGCustomAudioCaptureSourceTypeDeviceMicrophone) {
        ZGLogInfo(@"🎙 Custom audio capture microphone stop record");
        [_audioToolRecorder stop];
    }

    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    ZGLogInfo(@"📤 Stop publishing stream");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}

- (void)startPlaying:(BOOL)enableCustomAudioRender {

    ZGLogInfo(@"📥 Start playing stream, streamID: %@", self.remotePlayStreamID);
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.remotePlayStreamID canvas:playCanvas];

    // Use custom audio render
    if (enableCustomAudioRender) {
        if (!_audioToolPlayer) {
            _audioToolPlayer = [[ZGAudioToolPlayer alloc] initWithSampleRate:ZegoAudioSampleRate16K bufferSize:[self bufferSize]];
            __weak ZGCustomAudioCaptureAndRenderingViewController *weakSelf = self;
            _audioToolPlayer.bl_input = ^(ZGAudioToolPlayer *player,
                                          AudioUnitRenderActionFlags *ioActionFlags,
                                          const AudioTimeStamp *inTimeStamp,
                                          UInt32 inBusNumber,
                                          UInt32 inNumberFrames,
                                          AudioBufferList *bufferList) {

                AudioBuffer buffer = bufferList->mBuffers[0];
                unsigned int length = (unsigned int)buffer.mDataByteSize;

                // Fetch and render audio render buffer
                [[ZegoExpressEngine sharedEngine] fetchCustomAudioRenderPCMData:buffer.mData dataLength:length param:weakSelf.audioRenderFrameParam];
                buffer.mDataByteSize = length;

#if SAVE_AUDIO_RENDER_DATA_TO_FILE
                [weakSelf.audioRenderData appendBytes:buffer.mData length:length];
#endif
            };
        }

        ZGLogInfo(@"🔉 Custom audio render speaker start play");
        [_audioToolPlayer play];
    }
}

- (void)stopPlaying:(BOOL)enableCustomAudioRender {

    ZGLogInfo(@"📥 Stop playing stream");
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];

    if (enableCustomAudioRender) {
        ZGLogInfo(@"🔉 Custom audio render speaker stop play");
        [_audioToolPlayer stop];

#if SAVE_AUDIO_RENDER_DATA_TO_FILE
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        NSString *audioRenderFilePath = [documentsPath stringByAppendingPathComponent:@"CustomAudioRender.pcm"];
        [self.audioRenderData writeToFile:audioRenderFilePath atomically:YES];
        ZGLogInfo(@"💾 Write custom audio render data to file: %@", audioRenderFilePath);
#endif
    }
}


#pragma mark - Custom audio capture send data (for local media source)

// Will be called by the NSTimer every 20ms
- (void)sendCapturedAudioFrame {

    uint8_t *audioCapturedDataPosition = (uint8_t *)malloc([self bufferSize]);
    NSInteger length = [self.audioCapturedDataInputStream read:audioCapturedDataPosition maxLength:[self bufferSize]];
    [[ZegoExpressEngine sharedEngine] sendCustomAudioCapturePCMData:audioCapturedDataPosition dataLength:(unsigned int)length param:_audioCapturedFrameParam];
}

- (unsigned int)bufferSize {
    float duration = 0.02; // 20ms
    int sampleRate = ZegoAudioSampleRate16K;
    int audioChannels = 1;
    int bytesPerSample = 2;

    unsigned int expectedDataLength = (unsigned int)(duration * sampleRate * audioChannels * bytesPerSample);
    return expectedDataLength;
}


#pragma mark - ZegoEventHandler

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode);
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                ZGLogInfo(@"🚩 📤 Publishing stream");
                [self.startPublishButton setTitle:@"Stop Publish" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStatePublishRequesting:
                ZGLogInfo(@"🚩 📤 Requesting publish stream");
                [self.startPublishButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStateNoPublish:
                ZGLogInfo(@"🚩 📤 No publish stream");
                [self.startPublishButton setTitle:@"Start Publish" forState:UIControlStateNormal];
                break;
        }
    }
    self.publisherState = state;
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode);
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                ZGLogInfo(@"🚩 📥 Playing stream");
                [self.startPlayButton setTitle:@"Stop Play" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStatePlayRequesting:
                ZGLogInfo(@"🚩 📥 Requesting play stream");
                [self.startPlayButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStateNoPlay:
                ZGLogInfo(@"🚩 📥 No play stream");
                [self.startPlayButton setTitle:@"Start Play" forState:UIControlStateNormal];
                break;
        }
    }
    self.playerState = state;
}


@end
