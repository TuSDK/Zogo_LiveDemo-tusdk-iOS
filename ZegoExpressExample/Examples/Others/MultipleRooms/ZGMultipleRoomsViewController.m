//
//  ZGMultipleRoomsViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGMultipleRoomsViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGMultipleRoomsViewController ()<ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;

@property (weak, nonatomic) IBOutlet UITextField *roomID1TextField;
@property (weak, nonatomic) IBOutlet UITextField *roomID2TextField;
@property (weak, nonatomic) IBOutlet UIButton *room1LoginButton;
@property (weak, nonatomic) IBOutlet UIButton *room2LoginButton;


// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishRoomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamRoomIDTextField;

@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@end

@implementation ZGMultipleRoomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIDTextField.text = [ZGUserIDHelper userID];
    self.playStreamIDTextField.text = @"0029";
    self.publishStreamIDTextField.text = @"0029";
    [self createEngine];
    // Do any additional setup after loading the view.
}

- (void)createEngine {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    
    [ZegoExpressEngine setRoomMode:ZegoRoomModeMultiRoom];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (IBAction)onLoginRoom1ButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // LogoutRoom1
        [self appendLog:[NSString stringWithFormat:@"📤 Logout Room roomID: %@", self.roomID1TextField.text]];
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID1TextField.text];
    } else {
        // Login Room1
        [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID1TextField.text]];

        ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
        config.token = [KeyCenter token];
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID1TextField.text user:[ZegoUser userWithUserID:self.userIDTextField.text] config:config];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onLoginRoom2ButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // LogoutRoom2
        [self appendLog:[NSString stringWithFormat:@"📤 Logout Room roomID: %@", self.roomID2TextField.text]];

        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID2TextField.text];
    } else {
        // Login Room2
        [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID2TextField.text]];

//        [[ZegoExpressEngine sharedEngine] loginMultiRoom:self.roomID2TextField.text config:[[ZegoRoomConfig alloc] init]];
        ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
        config.token = [KeyCenter token];
        
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID2TextField.text user:[ZegoUser userWithUserID:self.userIDTextField.text] config:config];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    // Start publishing
    // Use userID as streamID
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
    
    ZegoPublisherConfig *config = [[ZegoPublisherConfig alloc] init];
    config.roomID = self.publishRoomIDTextField.text;
    
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text config:config channel:ZegoPublishChannelMain];
}
- (IBAction)onStopPublishingButtonTappd:(UIButton *)sender {
    // Stop publishing
    // Use userID as streamID
    [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
}

- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    // Start playing
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];
    
    ZegoPlayerConfig *config = [[ZegoPlayerConfig alloc] init];
    config.roomID = self.playStreamRoomIDTextField.text;

    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas config:config];
}

- (IBAction)onStopPlayingButtonTappd:(UIButton *)sender {
    // Stop playing
    [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
}

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
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        [ZegoExpressEngine setRoomMode:ZegoRoomModeSingleRoom];
    }];
}


@end
