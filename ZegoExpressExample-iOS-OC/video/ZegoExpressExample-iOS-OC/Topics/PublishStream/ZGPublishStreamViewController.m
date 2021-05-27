//
//  ZGPublishStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/5/29.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PublishStream

#import "AppDelegate.h"
#import "ZGPublishStreamViewController.h"
#import "ZGPublishStreamSettingTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGPublishStreamTopicRoomID = @"ZGPublishStreamTopicRoomID";
NSString* const ZGPublishStreamTopicStreamID = @"ZGPublishStreamTopicStreamID";

@interface ZGPublishStreamViewController () <ZegoEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPublishConfigView;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoRoomState roomState;
@property (nonatomic) ZegoPublisherState publisherState;

@end

@implementation ZGPublishStreamViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishStreamViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self createEngine];

    self.enableCamera = YES;
    self.useFrontCamera = YES;
    self.enableHardwareEncoder = NO;
    self.captureVolume = 100;
    self.currentZoomFactor = 1.0;

    // Support landscape
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskAllButUpsideDown];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    self.currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    // Reset to portrait
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];

    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    // Stop publishing before exiting
    if (self.publisherState != ZegoPublisherStateNoPublish) {
        ZGLogInfo(@"📤 Stop publishing stream");
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    }

    // Logout room before exiting
    if (self.roomState != ZegoRoomStateDisconnected) {
        ZGLogInfo(@"🚪 Logout room");
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    }

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)setupUI {
    self.navigationItem.title = @"Publish Stream";

    self.settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingController)];

    self.navigationItem.rightBarButtonItem = self.settingButton;

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomStateLabel.textColor = [UIColor whiteColor];

    self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
    self.publisherStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publisherStateLabel.textColor = [UIColor whiteColor];

    self.publishResolutionLabel.text = @"";
    self.publishResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishResolutionLabel.textColor = [UIColor whiteColor];

    self.publishQualityLabel.text = @"";
    self.publishQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishQualityLabel.textColor = [UIColor whiteColor];

    self.stopLiveButton.alpha = 0;
    self.startPublishConfigView.alpha = 1;

    self.roomID = [self savedValueForKey:ZGPublishStreamTopicRoomID];
    self.roomIDTextField.text = self.roomID;
    self.roomIDTextField.delegate = self;

    self.streamID = [self savedValueForKey:ZGPublishStreamTopicStreamID];
    self.streamIDTextField.text = self.streamID;
    self.streamIDTextField.delegate = self;

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];
}

#pragma mark - Actions

- (void)createEngine {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
//    previewCanvas.viewMode = self.previewViewMode;
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
}

- (IBAction)startLiveButtonClick:(id)sender {
    [self startLive];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopLive];
}


- (void)startLive {
    [self appendLog:@"🚪 Start login room"];

    self.roomID = self.roomIDTextField.text;
    self.streamID = self.streamIDTextField.text;

    [self saveValue:self.roomID forKey:ZGPublishStreamTopicRoomID];
    [self saveValue:self.streamID forKey:ZGPublishStreamTopicStreamID];

    // This demonstrates simply using the device model as the userID. In actual use, you can set the business-related userID as needed.
    NSString *userID = ZGUserIDHelper.userID;
    NSString *userName = ZGUserIDHelper.userName;

    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];

    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName] config:config];

    [self appendLog:@"📤 Start publishing stream"];

    // Start publishing
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopLive {
    // Stop publishing
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:@"📤 Stop publishing stream"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    self.publishQualityLabel.text = @"";
}

#pragma mark - Helper

- (void)invalidateLiveStateUILayout {
    if (self.roomState == ZegoRoomStateConnected &&
        self.publisherState == ZegoPublisherStatePublishing) {
        [self showLiveStartedStateUI];
    } else if (self.roomState == ZegoRoomStateDisconnected &&
               self.publisherState == ZegoPublisherStateNoPublish) {
        [self showLiveStoppedStateUI];
    } else {
        [self showLiveRequestingStateUI];
    }
}

- (void)showLiveRequestingStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:NO];
}

- (void)showLiveStartedStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 0;
        self.stopLiveButton.alpha = 1;
    }];
}

- (void)showLiveStoppedStateUI {
    [self.startLiveButton setEnabled:YES];
    [self.stopLiveButton setEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 1;
        self.stopLiveButton.alpha = 0;
    }];
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

- (void)showSettingController {
    ZGPublishStreamSettingTableViewController *vc = [ZGPublishStreamSettingTableViewController instanceFromStoryboard];
    vc.preferredContentSize = CGSizeMake(250.0, 150.0);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.barButtonItem = self.settingButton;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    vc.presenter = self;
    vc.enableCamera = _enableCamera;
    vc.useFrontCamera = _useFrontCamera;
    vc.enableHardwareEncoder = _enableHardwareEncoder;
    vc.captureVolume = _captureVolume;
    vc.maxZoomFactor = _maxZoomFactor;
    vc.currentZoomFactor = _currentZoomFactor;
    vc.roomID = _roomID;
    vc.streamExtraInfo = _streamExtraInfo;
    vc.roomExtraInfoKey = _roomExtraInfoKey;
    vc.roomExtraInfoValue = _roomExtraInfoValue;
    vc.encryptionKey = _encryptionKey;

    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField == self.roomIDTextField) {
        [self.streamIDTextField becomeFirstResponder];
    } else if (textField == self.streamIDTextField) {
        [self startLive];
    }

    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (_currentOrientation != orientation) {
        _currentOrientation = orientation;
        [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];

        ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
        CGFloat longSideValue = MAX(videoConfig.encodeResolution.width, videoConfig.encodeResolution.height);
        CGFloat shortSideValue = MIN(videoConfig.encodeResolution.width, videoConfig.encodeResolution.height);

        if (UIInterfaceOrientationIsPortrait(orientation)) {
            videoConfig.encodeResolution = CGSizeMake(shortSideValue, longSideValue);
        } else if (UIInterfaceOrientationIsLandscape(orientation)) {
            videoConfig.encodeResolution = CGSizeMake(longSideValue, shortSideValue);
        }
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    }
}


#pragma mark - ZegoExpress EventHandler Room Event

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode]];
    } else {
        switch (state) {
            case ZegoRoomStateConnected:
                [self appendLog:@"🚩 🚪 Login room success"];
                self.roomStateLabel.text = @"🟢 RoomState: Connected";
                break;

            case ZegoRoomStateConnecting:
                [self appendLog:@"🚩 🚪 Requesting login room"];
                self.roomStateLabel.text = @"🟡 RoomState: Connecting";
                break;

            case ZegoRoomStateDisconnected:
                [self appendLog:@"🚩 🚪 Logout room"];
                self.roomStateLabel.text = @"🔴 RoomState: Disconnected";

                // After logout room, the preview will stop. You need to re-start preview.
                ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
                //            previewCanvas.viewMode = self.previewViewMode;
                [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
                break;
        }
    }
    self.roomState = state;
    [self invalidateLiveStateUILayout];
}

#pragma mark - ZegoExpress EventHandler Publish Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                [self appendLog:@"🚩 📤 Publishing stream"];
                self.publisherStateLabel.text = @"🟢 PublisherState: Publishing";
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                self.publisherStateLabel.text = @"🟡 PublisherState: Requesting";
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:@"🚩 📤 No publish stream"];
                self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
                break;
        }
    }
    self.publisherState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *networkQuality = @"";
    switch (quality.level) {
        case 0:
            networkQuality = @"☀️";
            break;
        case 1:
            networkQuality = @"⛅️";
            break;
        case 2:
            networkQuality = @"☁️";
            break;
        case 3:
            networkQuality = @"🌧";
            break;
        case 4:
            networkQuality = @"❌";
            break;
        default:
            break;
    }
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"VideoSendFPS: %.1f fps \n", quality.videoSendFPS];
    [text appendFormat:@"AudioSendFPS: %.1f fps \n", quality.audioSendFPS];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"AudioBitrate: %.2f kb/s \n", quality.audioKBPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"VideoCodecID: %d \n", (int)quality.videoCodecID];
    [text appendFormat:@"TotalSend: %.3f MB \n", quality.totalSendBytes / 1024 / 1024];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
}

- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:@"🚩 🎶 onPublisherCapturedAudioFirstFrame"];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"🚩 📷 onPublisherCapturedVideoFirstFrame"];
    self.maxZoomFactor = [[ZegoExpressEngine sharedEngine] getCameraMaxZoomFactor];
    [self appendLog:[NSString stringWithFormat:@"📷 cameraMaxZoomFactor: %.1f", self.maxZoomFactor]];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    if (channel == ZegoPublishChannelAux) {
        return;
    }
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}



@end

#endif
