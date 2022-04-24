//
//  ZGVideoRotationPlayStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGVideoRotationPlayStreamViewController.h"
#import "ZGVideoRotationViewController.h"
#import "AppDelegate.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGVideoRotationPlayStreamViewController ()<ZegoEventHandler>

@property (nonatomic, assign) RotateType rotateType;

@property (nonatomic, assign) ZegoPlayerState playerState;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UIView *playStreamView;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;

@property (weak, nonatomic) IBOutlet UILabel *rotateModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *rotateModeButton;

@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@end

@implementation ZGVideoRotationPlayStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rotateType = RotateTypeFixedPortrait;

    self.playStreamIDTextField.text = @"0006";
    self.roomIDLabel.text = @"0006";
    self.userIDLabel.text = [ZGUserIDHelper userID];

    [self setupEngineAndLogin];
    [self setupUI];

    // Support landscape
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskAllButUpsideDown];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)setupEngineAndLogin {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];

    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomIDLabel.text]];
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomIDLabel.text user:[ZegoUser userWithUserID:self.userIDLabel.text] config:config];
}

- (void)setupUI {

    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
}

- (IBAction)onStartPlayingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop playing stream. streamID: %@", self.playStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    } else {
        // Set Orientation Config Before Playing
        ZegoVideoConfig *videoConfig = [ZegoVideoConfig defaultConfig];
        if (self.rotateType == RotateTypeFixedPortrait) {
            videoConfig.encodeResolution = CGSizeMake(360, 640);
            [[ZegoExpressEngine sharedEngine] setAppOrientation:UIInterfaceOrientationPortrait];
        } else if (self.rotateType == RotateTypeFixedLandscape) {
            videoConfig.encodeResolution = CGSizeMake(640, 360);
            [[ZegoExpressEngine sharedEngine] setAppOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
        }
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];

        // Start playing
        [self appendLog:[NSString stringWithFormat:@"📤 Start playing stream. streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:[ZegoCanvas canvasWithView:self.playStreamView]];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onRotateModeButtonTapped:(id)sender {
    if (self.playerState != ZegoPlayerStateNoPlay) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please Stop Playing First" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:true completion:nil];
        return;
    }
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *fixedProtrait = [UIAlertAction actionWithTitle:@"Fixed Protrait" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.rotateModeButton setTitle:@"Fixed Protrait" forState:UIControlStateNormal];
        self.rotateType = RotateTypeFixedPortrait;
    }];
    UIAlertAction *fixedLandscape = [UIAlertAction actionWithTitle:@"Fixed Landscape" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.rotateModeButton setTitle:@"Fixed Landscape" forState:UIControlStateNormal];
        self.rotateType = RotateTypeFixedLandscape;

    }];
    UIAlertAction *autoRotate = [UIAlertAction actionWithTitle:@"AutoRotate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.rotateModeButton setTitle:@"AutoRotate" forState:UIControlStateNormal];
        self.rotateType = RotateTypeFixedAutoRotate;
    }];
    [alertController addAction:cancel];
    [alertController addAction:fixedProtrait];
    [alertController addAction:fixedLandscape];
    [alertController addAction:autoRotate];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return (UIInterfaceOrientation)self.rotateType;
}

- (void)orientationChanged:(NSNotification *)notification {
    if (self.rotateType != RotateTypeFixedAutoRotate) {
        return;
    }
    UIDevice *device = notification.object;
    ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;

    switch (device.orientation) {
        // Note that UIInterfaceOrientationLandscapeLeft is equal to UIDeviceOrientationLandscapeRight (and vice versa).
        // This is because rotating the device to the left requires rotating the content to the right.
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIInterfaceOrientationLandscapeRight;
            videoConfig.encodeResolution = CGSizeMake(640, 360);
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            videoConfig.encodeResolution = CGSizeMake(640, 360);
            break;
        case UIDeviceOrientationPortrait:
            orientation = UIInterfaceOrientationPortrait;
            videoConfig.encodeResolution = CGSizeMake(360, 640);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIInterfaceOrientationPortraitUpsideDown;
            videoConfig.encodeResolution = CGSizeMake(360, 640);
            break;
        default:
            // Unknown / FaceUp / FaceDown
            break;
    }

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];
}

#pragma mark - ZegoEventHandler

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    self.playerState = state;
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                [self appendLog:@"🚩 📥 Playing stream"];
                self.startPlayingButton.selected = YES;
                break;

            case ZegoPlayerStatePlayRequesting:
                [self appendLog:@"🚩 📥 Requesting play stream"];
                break;

            case ZegoPlayerStateNoPlay:
                [self appendLog:@"🚩 📥 No play stream"];
                self.startPlayingButton.selected = NO;
                break;
        }
    }
    self.playerState = state;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    // Reset to portrait
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];

    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomIDLabel.text];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


@end
