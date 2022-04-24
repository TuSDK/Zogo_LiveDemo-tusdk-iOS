//
//  ZGEncodingDecodingViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGEncodingDecodingViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGEncodingDecodingViewController ()<ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, assign) ZegoVideoStreamType streamType;

@property (weak, nonatomic) IBOutlet UILabel *userIDRoomIDLabel;


// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UILabel *hardwareEncoderLabel;

@property (weak, nonatomic) IBOutlet UILabel *hardwareDecoderLabel;

@property (weak, nonatomic) IBOutlet UILabel *codecIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *codecIDButton;

@property (weak, nonatomic) IBOutlet UILabel *scalableVideoCodingLabel;

@property (weak, nonatomic) IBOutlet UIButton *videoLayerModeButton;
@property (weak, nonatomic) IBOutlet UISwitch *scalableVideoLayerSwitch;


@end

@implementation ZGEncodingDecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0012";
    self.streamType = ZegoVideoStreamTypeDefault;
    self.playStreamIDTextField.text = @"0012";
    self.publishStreamIDTextField.text = @"0012";
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];

    [self setupEngineAndLogin];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupEngineAndLogin {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];

    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID] config:config];
}

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];

    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    self.hardwareEncoderLabel.text = NSLocalizedString(@"HardwareEncoder", nil);
    self.hardwareDecoderLabel.text = NSLocalizedString(@"HardwareDecoder", nil);

    self.codecIDLabel.text = NSLocalizedString(@"CodecID", nil);
    self.scalableVideoCodingLabel.text = NSLocalizedString(@"ScalableVideoCoding", nil);
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text];
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] setPlayStreamVideoType:self.streamType streamID:self.playStreamIDTextField.text];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onHardwareEncoderSwitchChanged:(UISwitch *)sender {
    self.startPlayingButton.selected = NO;
    self.startPublishingButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:sender.isOn];

}

- (IBAction)onHardwareDecoderSwitchChanged:(UISwitch *)sender {
    self.startPlayingButton.selected = NO;
    self.startPublishingButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:sender.isOn];
}

- (IBAction)onCodecIDButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
        videoConfig.codecID = ZegoVideoCodecIDDefault;
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [self.codecIDButton setTitle:@"Default" forState:UIControlStateNormal];
        self.scalableVideoLayerSwitch.on = NO;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"SVC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
        videoConfig.codecID = ZegoVideoCodecIDSVC;
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [self.codecIDButton setTitle:@"SVC" forState:UIControlStateNormal];
        self.scalableVideoLayerSwitch.on = YES;
    }];

    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"VP8" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
        videoConfig.codecID = ZegoVideoCodecIDVP8;
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [self.codecIDButton setTitle:@"VP8" forState:UIControlStateNormal];

        self.scalableVideoLayerSwitch.on = NO;
    }];

    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"H265" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
        videoConfig.codecID = ZegoVideoCodecIDH265;
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [self.codecIDButton setTitle:@"H265" forState:UIControlStateNormal];

        self.scalableVideoLayerSwitch.on = NO;
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onVideoLayerButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        self.streamType = ZegoVideoStreamTypeDefault;
        [self.videoLayerModeButton setTitle:@"Default" forState:UIControlStateNormal];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        self.streamType = ZegoVideoStreamTypeSmall;
        [self.videoLayerModeButton setTitle:@"Small" forState:UIControlStateNormal];
    }];

    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Big" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self reset];
        self.streamType = ZegoVideoStreamTypeBig;
        [self.videoLayerModeButton setTitle:@"Big" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onScalableVideoCodingSwitchChanged:(UISwitch *)sender {
    [self reset];
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];

    if (sender.isOn) {
        //When you want to switch on scalableVideoCoding,you should set codecID to ZegoVideoCodecIDSVC
        videoConfig.codecID = ZegoVideoCodecIDSVC;
        [self.codecIDButton setTitle:@"SVC" forState:UIControlStateNormal];
        [self appendLog:@"🚩 📤 Enable Scalable VideoCoding"];

    } else {
        videoConfig.codecID = ZegoVideoCodecIDDefault;
        [self.codecIDButton setTitle:@"Default" forState:UIControlStateNormal];

        [self appendLog:@"🚩 📤 Disable Scalable VideoCoding"];
    }

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
}

- (void)reset {
    self.startPlayingButton.selected = NO;
    self.startPublishingButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
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
    }
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
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


@end
