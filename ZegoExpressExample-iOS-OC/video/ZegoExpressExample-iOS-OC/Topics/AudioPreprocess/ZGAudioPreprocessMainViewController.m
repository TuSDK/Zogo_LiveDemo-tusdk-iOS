//
//  ZGAudioPreprocessMainViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/10/2.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioPreprocess

#import "ZGAudioPreprocessMainViewController.h"
#import "ZGAudioPreprocessConfigTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGAudioPreprocessMainViewController () <ZegoEventHandler>

@property (nonatomic, strong) UIBarButtonItem *resetButton;
@property (nonatomic, weak) ZGAudioPreprocessConfigTableViewController *configVC;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;

@property (nonatomic, assign) ZegoPlayerState playerState;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *playStreamIDLabel;

@end

@implementation ZGAudioPreprocessMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"AudioPreprocess";
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.publishStreamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.localPublishStreamID];
    self.playStreamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.remotePlayStreamID];

    self.resetButton = [[UIBarButtonItem alloc] initWithTitle:@"ResetAll" style:UIBarButtonItemStylePlain target:self.configVC action:@selector(resetAllEffect)];
    self.navigationItem.rightBarButtonItem = self.resetButton;

    [self createEngineAndLoginRoom];

    [self startPublishing];

    [self startPlaying];
}

- (void)viewDidDisappear:(BOOL)animated {
    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)createEngineAndLoginRoom {

    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // In order to make the virtual stereo effect, you need to set the audio encoding channel to stereo
    ZegoAudioConfig *audioConfig = [ZegoAudioConfig configWithPreset:ZegoAudioConfigPresetStandardQualityStereo];
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig];

    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];

    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
}


- (IBAction)startPublishButtonClick:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {
        [self stopPublishing];
    } else if (self.publisherState == ZegoPublisherStateNoPublish) {
        [self startPublishing];
    }
}

- (IBAction)startPlayButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {
        [self stopPlaying];
    } else if (self.playerState == ZegoPlayerStateNoPlay) {
        [self startPlaying];
    }
}


- (void)startPublishing {
    ZGLogInfo(@"🔌 Start preview");
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.localPublishStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamID];
}

- (void)stopPublishing {
    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    ZGLogInfo(@"📤 Stop publishing stream");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}

- (void)startPlaying {
    ZGLogInfo(@"📥 Start playing stream, streamID: %@", self.remotePlayStreamID);
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.remotePlayStreamID canvas:playCanvas];
}

- (void)stopPlaying {
    ZGLogInfo(@"📥 Stop playing stream");
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ZGAudioPreprocessConfigSegue"]) {
        self.configVC = segue.destinationViewController;
    }
}

@end

#endif
