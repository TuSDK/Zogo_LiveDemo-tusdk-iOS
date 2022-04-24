//
//  ZGPlayStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGPlayStreamViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

NSString* const ZGPlayStreamTopicRoomID = @"ZGPlayStreamTopicRoomID";
NSString* const ZGPlayStreamTopicStreamID = @"ZGPlayStreamTopicStreamID";

@interface ZGPlayStreamViewController () <ZegoEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *viewModeButton;

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPlayConfigView;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *playResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *playQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoRoomState roomState;
@property (nonatomic) ZegoPlayerState playerState;

@end

@implementation ZGPlayStreamViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self createEngine];

    self.roomIDTextField.text = @"0003";
    self.streamIDTextField.text = @"0003";
    // This demonstrates simply using the device name as the userID. In actual use, you can set the business-related userID as needed.
    self.userID = [ZGUserIDHelper userID];
    
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];

    self.enableHardwareDecoder = NO;
    self.mutePlayStreamVideo = NO;
    self.mutePlayStreamAudio = NO;
    self.playVolume = 100;
    self.resourceMode = ZegoStreamResourceModeDefault;
}

- (void)dealloc {

    // Stop publishing before exiting
    if (self.playerState != ZegoPlayerStateNoPlay) {
        ZGLogInfo(@"📥 Stop playing stream");
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
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
    self.navigationItem.title = @"Play Stream";

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomStateLabel.textColor = [UIColor whiteColor];

    self.playerStateLabel.text = @"🔴 PlayerState: NoPlay";
    self.playerStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playerStateLabel.textColor = [UIColor whiteColor];

    self.playResolutionLabel.text = @"";
    self.playResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playResolutionLabel.textColor = [UIColor whiteColor];

    self.playQualityLabel.text = @"";
    self.playQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playQualityLabel.textColor = [UIColor whiteColor];

    self.stopLiveButton.alpha = 0;
    self.startPlayConfigView.alpha = 1;

    self.roomIDTextField.delegate = self;

    self.streamIDTextField.delegate = self;

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];

}

#pragma mark - Actions

- (void)createEngine {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;

    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (IBAction)startLiveButtonClick:(id)sender {
    [self startPlayingStream];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopPlayingStream];
}

- (IBAction)onViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeAspectFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeScaleToFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}


- (IBAction)onSwitchVideo:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:!sender.isOn streamID:self.streamIDTextField.text];
}

- (IBAction)onSwitchAudio:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:!sender.isOn streamID:self.streamIDTextField.text];
}


- (void)startPlayingStream {

    self.roomID = self.roomIDTextField.text;
    self.streamID = self.streamIDTextField.text;

    NSString *userID = self.userID;
    NSString *userName = userID;

    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];

    // Login room
    [self appendLog:@"🚪 Login room"];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName] config:config];

    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, resourceMode: %d", (int)self.resourceMode]];

    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];

    // Start playing
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:playCanvas];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopPlayingStream {
    // Stop playing
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    [self appendLog:@"📥 Stop playing stream"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    self.playQualityLabel.text = @"";
}


#pragma mark - Helper

- (void)invalidateLiveStateUILayout {
    if (self.roomState == ZegoRoomStateConnected &&
        self.playerState == ZegoPlayerStatePlaying) {
        [self showLiveStartedStateUI];
    } else if (self.roomState == ZegoRoomStateDisconnected &&
               self.playerState == ZegoPlayerStateNoPlay) {
        [self showLiveStoppedStateUI];
    }  else if (self.roomState == ZegoRoomStateConnected &&
                self.playerState == ZegoPlayerStateNoPlay) {
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
//        self.startPlayConfigView.alpha = 0;
        self.stopLiveButton.alpha = 1;
        self.startLiveButton.alpha = 0;
    }];
}

- (void)showLiveStoppedStateUI {
    [self.startLiveButton setEnabled:YES];
    [self.stopLiveButton setEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
//        self.startPlayConfigView.alpha = 1;
        self.stopLiveButton.alpha = 0;
        self.startLiveButton.alpha = 1;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField == self.roomIDTextField) {
        [self.streamIDTextField becomeFirstResponder];
    } else if (textField == self.streamIDTextField) {
        [self startPlayingStream];
    }

    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)updateStreamExtraInfo:(NSArray<ZegoStream *> *)streamList {
    NSMutableString *streamExtraInfoString = [NSMutableString string];
    for (ZegoStream *stream in streamList) {
        [streamExtraInfoString appendFormat:@"streamID:%@,info:%@;\n", stream.streamID, stream.extraInfo];
    }
    self.streamExtraInfo = streamExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💬 Stream extra info update: %@", streamExtraInfoString]];
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
                break;
        }
    }
    self.roomState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    [self appendLog:[NSString stringWithFormat:@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID]];
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomExtraInfoUpdate:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList roomID:(NSString *)roomID {
    NSMutableString *roomExtraInfoString = [NSMutableString string];
    for (ZegoRoomExtraInfo *info in roomExtraInfoList) {
        [roomExtraInfoString appendFormat:@"key:%@,value:%@;\n", info.key, info.value];

    }
    self.roomExtraInfo = roomExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💭 Room extra info update: %@", roomExtraInfoString]];
}

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    NSLog(@"onPlayerRecvSEI");
}

#pragma mark - ZegoExpress EventHandler Play Event

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                [self appendLog:@"🚩 📥 Playing stream"];
                self.playerStateLabel.text = @"🟢 PlayerState: Playing";
                break;

            case ZegoPlayerStatePlayRequesting:
                [self appendLog:@"🚩 📥 Requesting play stream"];
                self.playerStateLabel.text = @"🟡 PlayerState: Requesting";
                break;

            case ZegoPlayerStateNoPlay:
                [self appendLog:@"🚩 📥 No play stream"];
                self.playerStateLabel.text = @"🔴 PlayerState: NoPlay";
                break;
        }
    }
    self.playerState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    self.playResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
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
    [text appendFormat:@"VideoRecvFPS: %.1f fps \n", quality.videoRecvFPS];
    [text appendFormat:@"AudioRecvFPS: %.1f fps \n", quality.audioRecvFPS];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"AudioBitrate: %.2f kb/s \n", quality.audioKBPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"Delay: %d ms \n", quality.delay];
    [text appendFormat:@"P2P Delay: %d ms \n", quality.peerToPeerDelay];
    [text appendFormat:@"VideoCodecID: %d \n", (int)quality.videoCodecID];
    [text appendFormat:@"AV TimestampDiff: %d ms \n", quality.avTimestampDiff];
    [text appendFormat:@"TotalRecv: %.3f MB \n", quality.totalRecvBytes / 1024 / 1024];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareDecode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.playQualityLabel.text = text;
}

@end
