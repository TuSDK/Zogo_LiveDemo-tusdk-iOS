//
//  ZGCustomVideoRenderViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/5/7.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCustomVideoRenderViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@interface ZGCustomVideoRenderViewController ()<ZegoEventHandler, ZegoCustomVideoRenderHandler>
// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewView;

@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playView;

@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@end

@implementation ZGCustomVideoRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createEngine];
}

- (void)createEngine {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];

    // Init render config
    ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
    renderConfig.bufferType = self.bufferType;
    renderConfig.frameFormatSeries = self.frameFormatSeries;

    // Enable custom video render
    [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];

    // Set custom video render handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
    
    // Login Room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:config];
    
    [self setupUI];
}

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", [ZGUserIDHelper userID]];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:^{
            // This callback is only used to notify the completion of the release of internal resources of the engine.
            // Developers cannot release resources related to the engine within this callback.
            //
            // In general, developers do not need to listen to this callback.
            ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
        }];
    }
    [super viewDidDisappear:animated];
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    } else {
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] startPreview:nil];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
    }
    sender.selected = !sender.isSelected;
    
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    } else {

        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:nil];
    }
    sender.selected = !sender.isSelected;
    
}

#pragma mark - ZegoEventHandler
/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        // Add a flag to the button for successful operation
        self.startPublishingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
        self.startPublishingButton.selected = false;
    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@"🚩 📥 Playing stream success"];
        // Add a flag to the button for successful operation
        self.startPlayingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📥 Playing stream fail"];
        self.startPlayingButton.selected = false;
    }
}

#pragma mark - ZegoCustomVideoRenderHandler - Local Capture

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onCapturedVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel {
    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f, isNeedFlip:%d", (int)param.format, param.size.width, param.size.height, (int)flipMode);
    [self renderWithCVPixelBuffer:buffer isPreview:YES];
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onCapturedVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel {
    NSLog(@"raw data video frame callback. format:%d, width:%f, height:%f, isNeedFlip:%d", (int)param.format, param.size.width, param.size.height, (int)flipMode);
    
    if (param.format == ZegoVideoFrameFormatBGRA32) {
        // Reverse color
        unsigned char *bgra32 = data[0];
        for (int i = 0; i < dataLength[0]; i += 4) {
            unsigned char b = bgra32[i];
            unsigned char g = bgra32[i + 1];
            unsigned char r = bgra32[i + 2];
            bgra32[i] = 255 - b;
            bgra32[i + 1] = 255 - g;
            bgra32[i + 2] = 255 - r;
        }
    } else if (param.format == ZegoVideoFrameFormatI420) {
        // Grayscale
        unsigned char *uPlanar = data[1];
        unsigned char *vPlanar = data[2];
        memset(uPlanar, 0x80, sizeof(unsigned char) * dataLength[1]);
        memset(vPlanar, 0x80, sizeof(unsigned char) * dataLength[2]);
    }
}

- (void)onCapturedVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond channel:(ZegoPublishChannel)channel {
    
}

#pragma mark - ZegoCustomVideoRenderHandler - Remote Stream


/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onRemoteVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
//    if (streamID != self.streamID) return;
    NSLog(@"raw data video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
    
    if (param.format == ZegoVideoFrameFormatBGRA32) {
        // Reverse color
        unsigned char *bgra32 = data[0];
        for (int i = 0; i < dataLength[0]; i += 4) {
            unsigned char b = bgra32[i];
            unsigned char g = bgra32[i + 1];
            unsigned char r = bgra32[i + 2];
            bgra32[i] = 255 - b;
            bgra32[i + 1] = 255 - g;
            bgra32[i + 2] = 255 - r;
        }
    } else if (param.format == ZegoVideoFrameFormatI420) {
        // Grayscale
        unsigned char *uPlanar = data[1];
        unsigned char *vPlanar = data[1];
        memset(uPlanar, 0x80, sizeof(char) * dataLength[1]);
        memset(vPlanar, 0x80, sizeof(char) * dataLength[2]);
    }
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
//    if (streamID != self.streamID) return;
    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
    [self renderWithCVPixelBuffer:buffer isPreview:NO];
}

- (void)onRemoteVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond streamID:(NSString *)streamID {
    NSLog(@"EEEncodedData Remote video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);

    
}

#pragma mark - Custom Render Method

- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)buffer isPreview:(BOOL)isPreview {
    CIImage *image = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isPreview) {
            self.previewView.image = [UIImage imageWithCIImage:image];
        } else {
            self.playView.image = [UIImage imageWithCIImage:image];
        }
    });
}

#pragma mark - Others

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
    ZGLogInfo(@"%@", tipText);
    
    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];
    
    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

#pragma mark - Exit

- (void)dealloc {

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}
@end
