//
//  ZGMediaPlayerViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_MediaPlayer

#import "ZGMediaPlayerViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGMediaPlayerViewController ()<ZegoEventHandler, ZegoMediaPlayerEventHandler, ZegoMediaPlayerVideoHandler, ZegoMediaPlayerAudioHandler>

@property (nonatomic, strong) ZegoMediaPlayer *player;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, assign) ZegoPublisherState publisherState;

@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *currentProcessLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UISlider *processSlider;
@property (weak, nonatomic) IBOutlet UISwitch *enableRepeatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableAuxSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *muteLocalSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *audioTrackSeg;

@property (weak, nonatomic) IBOutlet UISlider *playVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *publishVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pitchValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;

@end

@implementation ZGMediaPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MediaPlayer";

    self.roomID = @"MediaPlayerRoom-1";
    
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
    
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomID user:[ZegoUser userWithUserID:[ZGUserIDHelper userID]]];
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", _roomID);

    // use userID as streamID
    self.streamID = [NSString stringWithFormat:@"s-%@", [ZGUserIDHelper userID]];
    
    [self startLive];
    
    [self createMediaPlayer];
}

- (void)createMediaPlayer {
    self.player = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
    if (self.player) {
        ZGLogInfo(@"💽 Create ZegoMediaPlayer");
    } else {
        ZGLogWarn(@"💽 ❌ Create ZegoMediaPlayer failed");
        return;
    }
    
    [self.player loadResource:self.mediaItem.fileURL callback:^(int errorCode) {
        ZGLogInfo(@"🚩 💽 Media Player load resource. errorCode: %d", errorCode);
        [self setupMediaPlayerUI];
    }];
    
    // set media player event handler
    [self.player setEventHandler:self];
    
    // enable audio frame callback
    [self.player setAudioHandler:self];
    
    // enable video frame callback
    [self.player setVideoHandler:self format:ZegoVideoFrameFormatNV12 type:ZegoVideoBufferTypeCVPixelBuffer];
    
    [self.player enableAux:YES];
    
    [self.player enableRepeat:YES];
    
    [self.player muteLocal:NO];
}

- (void)setupMediaPlayerUI {
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.roomIDLabel.textColor = [UIColor whiteColor];
    self.streamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.streamID];
    self.streamIDLabel.textColor = [UIColor whiteColor];

    self.totalDurationLabel.text = [NSString stringWithFormat:@"%02llu:%02llu", self.player.totalDuration / 1000 / 60, (self.player.totalDuration / 1000) % 60];
    
    self.processSlider.maximumValue = self.player.totalDuration;
    self.processSlider.minimumValue = 0.0;
    self.processSlider.value = self.player.currentProgress;
    self.processSlider.continuous = NO;
 
    [self.processSlider addTarget:self action:@selector(processSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.processSlider addTarget:self action:@selector(processSliderTouchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    self.playVolumeSlider.maximumValue = 200.0;
    self.playVolumeSlider.minimumValue = 0.0;
    self.playVolumeSlider.value = self.player.playVolume;
    self.playVolumeSlider.continuous = NO;

    self.publishVolumeSlider.maximumValue = 200.0;
    self.publishVolumeSlider.minimumValue = 0.0;
    self.publishVolumeSlider.value = self.player.publishVolume;
    self.publishVolumeSlider.continuous = NO;
    
    self.enableRepeatSwitch.on = YES;
    self.enableAuxSwitch.on = YES;
    self.muteLocalSwitch.on = NO;

    [self.audioTrackSeg removeAllSegments];
    unsigned int trackCount = self.player.audioTrackCount;
    if (trackCount > 0) {
        for (int i = 0; i < trackCount; i++) {
            [self.audioTrackSeg insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
    } else {
        [self.audioTrackSeg insertSegmentWithTitle:@"None" atIndex:0 animated:NO];
    }

    self.pitchSlider.continuous = NO;
    
    if (self.mediaItem.isVideo) {
        [self.player setPlayerCanvas:[ZegoCanvas canvasWithView:self.playerView]];
    } else {
        [self.playerView addSubview:({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height)];
            label.text = @"Audio";
            label.font = [UIFont boldSystemFontOfSize:60];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        })];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        ZGLogInfo(@"🏳️ Destroy ZegoMediaPlayer");
        [[ZegoExpressEngine sharedEngine] destroyMediaPlayer:self.player];
        
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:nil];
    }
    [super viewDidDisappear:animated];
}

#pragma mark Publisher Actions

- (IBAction)publishButton:(UIButton *)sender {
    switch (_publisherState) {
        case ZegoPublisherStateNoPublish:
            [self startLive];
            break;
        case ZegoPublisherStatePublishing: case ZegoPublisherStatePublishRequesting:
            [self stopLive];
            break;
    }
}

- (void)startLive {
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.publisherView]];
    ZGLogInfo(@"🔌 Start preview");

    [[ZegoExpressEngine sharedEngine] startPublishingStream:_streamID];
    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", [ZGUserIDHelper userID]);
}

- (void)stopLive {
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    ZGLogInfo(@"📤 Stop publishing stream");
    
    [[ZegoExpressEngine sharedEngine] stopPreview];
    ZGLogInfo(@"🔌 Stop preview");
}

#pragma mark Media Player Actions

- (IBAction)playButtonClick:(UIButton *)sender {
    [self.player start];
    ZGLogInfo(@"▶️ Media Player start");
}

- (IBAction)pauseButtonClick:(UIButton *)sender {
    [self.player pause];
    ZGLogInfo(@"⏸ Media Player pause");
}

- (IBAction)resumeButtonClick:(UIButton *)sender {
    [self.player resume];
    ZGLogInfo(@"⏯ Media Player resume");
}

- (IBAction)stopButtonClick:(UIButton *)sender {
    [self.player stop];
    ZGLogInfo(@"⏹ Media Player stop");
}

- (IBAction)enableRepeatSwitchAction:(UISwitch *)sender {
    [self.player enableRepeat:sender.on];
    ZGLogInfo(@"%@ Media Player enable repeat: %@", sender.on ? @"🔂" : @"↩️", sender.on ? @"YES" : @"NO");
}

- (IBAction)enableAuxSwitchAction:(UISwitch *)sender {
    [self.player enableAux:sender.on];
    ZGLogInfo(@"⏺ Media Player enable aux: %@", sender.on ? @"YES" : @"NO");
}

- (IBAction)muteLocalSwitchAction:(UISwitch *)sender {
    [self.player muteLocal:sender.on];
    ZGLogInfo(@"%@ Media Player mute local: %@", sender.on ? @"🔇" : @"🔈", sender.on ? @"YES" : @"NO");
}

- (IBAction)audioTrackSegValueChanged:(UISegmentedControl *)sender {
    unsigned int index = (unsigned int)self.audioTrackSeg.selectedSegmentIndex;
    [self.player setAudioTrackIndex:index];
    ZGLogInfo(@"🎵 Media Player set audio track index: %d", index);
}

#pragma mark Media Player Slider Actions

- (IBAction)playVolumeSliderValueChanged:(UISlider *)sender {
    [self.player setPlayVolume:(int)sender.value];
    ZGLogInfo(@"🔊 Media Player set play volume: %d", (int)sender.value);
}

- (IBAction)publishVolumeSliderValueChanged:(UISlider *)sender {
    [self.player setPublishVolume:(int)sender.value];
    ZGLogInfo(@"🔊 Media Player set publish volume: %d", (int)sender.value);
}

- (IBAction)processSliderValueChanged:(UISlider *)sender {
    [self.player seekTo:(unsigned long long)sender.value callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🔍 Media Player seek to callback. errorCode: %d", errorCode);
    }];
    ZGLogInfo(@"🔍 Media Player seek to: %llu", (unsigned long long)sender.value);
}

- (void)processSliderTouchDown {
    [self.player pause];
}

- (void)processSliderTouchUp {
    [self.player resume];
}

- (IBAction)pitchSliderValueChanged:(UISlider *)sender {
    ZegoVoiceChangerParam *param = [[ZegoVoiceChangerParam alloc] init];
    param.pitch = self.pitchSlider.value;
    [self.player setVoiceChangerParam:param audioChannel:ZegoMediaPlayerAudioChannelAll];
    self.pitchValueLabel.text = [NSString stringWithFormat:@"Pitch: %.2f", param.pitch];
    ZGLogInfo(@"🗣 Media Player set voice changer pitch: %.2f", param.pitch);
}

#pragma mark Publisher Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    
    _publisherState = state;
    
    switch (state) {
        case ZegoPublisherStateNoPublish:
            [self.publishButton setTitle:@"StartPublish" forState:UIControlStateNormal];
            break;
        case ZegoPublisherStatePublishing: case ZegoPublisherStatePublishRequesting:
            [self.publishButton setTitle:@"StopPublish" forState:UIControlStateNormal];
            break;
    }
}


#pragma mark - Media Player Event Handler

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer stateUpdate:(ZegoMediaPlayerState)state errorCode:(int)errorCode {
    ZGLogInfo(@"🚩 📻 Media Player State Update: %d, errorCode: %d", (int)state, errorCode);
    switch (state) {
        case ZegoMediaPlayerStateNoPlay:
            // Stop
            break;
        case ZegoMediaPlayerStatePlaying:
            // Playing
            break;
        case ZegoMediaPlayerStatePausing:
            // Pausing
            break;
        case ZegoMediaPlayerStatePlayEnded:
            // Play ended, developer can play next song, etc.
            break;
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer networkEvent:(ZegoMediaPlayerNetworkEvent)networkEvent {
    ZGLogInfo(@"🚩 ⏳ Media Player Network Event: %d", (int)networkEvent);
    if (networkEvent == ZegoMediaPlayerNetworkEventBufferBegin) {
        // Show loading UI, etc.
    } else if (networkEvent == ZegoMediaPlayerNetworkEventBufferEnded) {
        // End loading UI, etc.
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer playingProgress:(unsigned long long)millisecond {
    // Update progress bar, etc.
    self.currentProcessLabel.text = [NSString stringWithFormat:@"%02llu:%02llu", millisecond / 1000 / 60, (millisecond / 1000) % 60];
    [self.processSlider setValue:millisecond animated:YES];
}

#pragma mark - Media Player Audio Handler

/// @note Need to switch threads before processing audio frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer audioFrameData:(const unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoAudioFrameParam *)param {
//    NSLog(@"audio frame callback. bufferLength:%d, sampleRate:%d, channels:%d", param.bufferLength, param.sampleRate, param.channels);
}

#pragma mark - Media Player Video Handler

/// When video frame type is set to `ZegoVideoFrameTypeCVPixelBuffer`, video frame CVPixelBuffer data will be called back from this function
/// @note Need to switch threads before processing video frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer videoFramePixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param {
//    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
}

/// When video frame type is set to `ZegoVideoFrameTypeRawdata`, video frame raw data will be called back from this function
/// @note Need to switch threads before processing video frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer videoFrameRawData:(const unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param {
//    NSLog(@"raw data video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
}

@end

#endif
