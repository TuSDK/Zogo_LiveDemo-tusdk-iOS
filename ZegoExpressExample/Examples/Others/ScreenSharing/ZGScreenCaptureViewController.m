//
//  ZGScreenCaptureViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/17.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGScreenCaptureViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGScreenCaptureDefines.h"
#import <ReplayKit/ReplayKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGScreenCaptureViewController ()<ZegoEventHandler>

@property (nonatomic, copy) NSString *streamID;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

/// Scenraio
@property (nonatomic, assign) ZegoScenario scenario;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UISwitch *onlyCaptureVideoSwitch;

@property (weak, nonatomic) IBOutlet UILabel *videoFpsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *videoFpsStepper;
@property (nonatomic, assign) unsigned int videoFps;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UIStepper *videoBitrateStepper;
@property (nonatomic, assign) unsigned int videoBitrateKBPS;

@property (weak, nonatomic) IBOutlet UILabel *resolutionFactorLabel;
@property (weak, nonatomic) IBOutlet UIStepper *resolutionFactorStepper;
@property (nonatomic, assign) float resolutionFactor;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation ZGScreenCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0033";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0033";
    self.scenario = ZegoScenarioGeneral;
    [self setupUI];
    [self setupEngine];

}

- (void)setupEngine {
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = self.scenario;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.token = [KeyCenter token];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID] config:config];
}

- (void)dealloc {
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupUI {
    
    self.roomIDTextField.text = self.roomID;
    self.streamIDTextField.text = self.streamID;
    self.videoFpsStepper.minimumValue = 5;
    self.videoFpsStepper.maximumValue = 30;
    self.videoFpsStepper.value = 15;
    self.videoFpsStepper.stepValue = 5;
    self.videoFps = (unsigned int)self.videoFpsStepper.value;

    self.videoBitrateStepper.minimumValue = 500;
    self.videoBitrateStepper.maximumValue = 3000;
    self.videoBitrateStepper.value = 1500;
    self.videoBitrateStepper.stepValue = 500;
    self.videoBitrateKBPS = (unsigned int)self.videoBitrateStepper.value;

    self.resolutionFactorStepper.minimumValue = 0.5;
    self.resolutionFactorStepper.maximumValue = 3;
    self.resolutionFactorStepper.value = 2.0;
    self.resolutionFactorStepper.stepValue = 0.5;
    self.resolutionFactor = (float)self.resolutionFactorStepper.value;
    self.resolutionFactorLabel.text = [NSString stringWithFormat:@"Resolution Factor: %.1f", self.resolutionFactor];
    
}

- (NSUserDefaults *)userDefaults {
    if (!_userDefaults) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    }
    return _userDefaults;
}

- (IBAction)startScreenCaptureClick:(UIButton *)sender {

    if (@available(iOS 12.0, *)) {

        [self syncParametersWithBroadcastProcess];

        // Note:
        // When screen recording is enabled, the iOS system will start an independent recording sub-process
        // and callback the methods of the [SampleHandler] class in the file [ ./ZegoExpressExample-iOS-OC-Broadcast/SampleHandler.m ]
        // This demo has encapsulated the logic of calling the ZegoExpressEngine SDK in the [ZGScreenCaptureManager] class.
        // Please refer to it to implement [SampleHandler] class in your own project
        if ([APP_GROUP length] == 0) {
            [ZegoHudManager showMessage:@"Please set up **APP_GROUP** marco in file 'ZGScreenCaptureDefines.h'"];
            return;
        }

        // Note:
        // ⚠️ There is a known issue here: RPSystemBroadcastPickerView does not work on iOS 13
        // when using UIScene lifecycle (SceneDelegate), this issue was fixed since iOS 14. If
        // you want to use it on iOS 13, you should use the UIApplication lifecycle.
        //
        // Ref:
        // https://stackoverflow.com/q/60075142/7027076
        // https://github.com/twilio/video-quickstart-ios/issues/438
        //
        RPSystemBroadcastPickerView *broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ZegoExpressExample-Broadcast" ofType:@"appex" inDirectory:@"PlugIns"];
        if (!bundlePath) {
            [ZegoHudManager showMessage:@"Can not find bundle `ZegoExpressExample-Broadcast.appex`"];
            return;
        }

        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (!bundle) {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@"Can not find bundle at path: %@", bundlePath]];
            return;
        }

        broadcastPickerView.preferredExtension = bundle.bundleIdentifier;


        // Traverse the subviews to find the button to skip the step of clicking the system view

        // This solution is not officially recommended by Apple, and may be invalid in future system updates

        // The safe solution is to directly add RPSystemBroadcastPickerView as subView to your view

        for (UIView *subView in broadcastPickerView.subviews) {
            if ([subView isMemberOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subView;
                [button sendActionsForControlEvents:UIControlEventAllEvents];
            }
        }

    } else {
        [ZegoHudManager showMessage:@"This feature only supports iOS12 or above"];
    }
}

- (IBAction)stopScreenCaptureClick:(UIButton *)sender {
    // Send notification to broadcast upload extension process
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         (CFStringRef)@"ZG_BROADCAST_FINISH_NOTIFICATION", NULL, nil, YES);
}

- (IBAction)videoFpsStepperValueChanged:(UIStepper *)sender {
    self.videoFps = (unsigned int)sender.value;
    self.videoFpsLabel.text = [NSString stringWithFormat:@"Video FPS: %d", self.videoFps];
}

- (IBAction)videoBitrateStepperValueChanged:(UIStepper *)sender {
    self.videoBitrateKBPS = (unsigned int)sender.value;
    self.videoBitrateLabel.text = [NSString stringWithFormat:@"Video Bitrate: %d (KBPS)", self.videoBitrateKBPS];
}

- (IBAction)resolutionFactorStepperValueChanged:(UIStepper *)sender {
    self.resolutionFactor = sender.value;
    self.resolutionFactorLabel.text = [NSString stringWithFormat:@"Resolution Factor: %.1f", self.resolutionFactor];
}

- (void)syncParametersWithBroadcastProcess {
    // Use app group to sync parameters with broadcast extension process

    // Sync parameters for [createEngine]
    [self.userDefaults setObject:@([KeyCenter appID]) forKey:@"ZG_SCREEN_CAPTURE_APP_ID"];
    [self.userDefaults setObject:@(self.scenario) forKey:@"ZG_SCREEN_CAPTURE_SCENARIO"];

    // Sync parameters for [loginRoom]
    [self.userDefaults setObject:ZGUserIDHelper.userID forKey:@"ZG_SCREEN_CAPTURE_USER_ID"];
    [self.userDefaults setObject:ZGUserIDHelper.userName forKey:@"ZG_SCREEN_CAPTURE_USER_NAME"];
    [self.userDefaults setObject:self.roomID forKey:@"ZG_SCREEN_CAPTURE_ROOM_ID"];
    [self.userDefaults setObject:KeyCenter.token forKey:@"ZG_SCREEN_CAPTURE_ROOM_TOKEN"];

    // Sync parameters for [setVideoConfig]
    [self.userDefaults setObject:@(self.videoBitrateKBPS) forKey:@"ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_BITRATE_KBPS"];
    [self.userDefaults setObject:@(self.videoFps) forKey:@"ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_FPS"];

    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    [self.userDefaults setObject:@(MIN(screenWidth, screenHeight) * self.resolutionFactor) forKey:@"ZG_SCREEN_CAPTURE_VIDEO_SIZE_WIDTH"];
    [self.userDefaults setObject:@(MAX(screenWidth, screenHeight) * self.resolutionFactor) forKey:@"ZG_SCREEN_CAPTURE_VIDEO_SIZE_HEIGHT"];

    // Sync parameters for [startPublishingStream]
    [self.userDefaults setObject:self.streamIDTextField.text forKey:@"ZG_SCREEN_CAPTURE_STREAM_ID"];

    // Sync parameters for this demo's config
    [self.userDefaults setObject:@(self.onlyCaptureVideoSwitch.on) forKey:@"ZG_SCREEN_CAPTURE_ONLY_CAPTURE_VIDEO"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
