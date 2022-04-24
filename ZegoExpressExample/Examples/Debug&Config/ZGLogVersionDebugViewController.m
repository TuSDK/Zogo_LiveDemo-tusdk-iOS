//
//  ZGLogVersionDebugViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/16.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGLogVersionDebugViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZGShareLogViewController.h"

@interface ZGLogVersionDebugViewController ()<ZegoEventHandler, ZegoApiCalledEventHandler>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, copy) NSString *logPath;

@property (weak, nonatomic) IBOutlet UILabel *logPathLabel;

@property (weak, nonatomic) IBOutlet UITextField *logSizeTextfield;
@property (weak, nonatomic) IBOutlet UITextField *appIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextfield;

@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;

@property (weak, nonatomic) IBOutlet UILabel *demoVersionLabel;

@end

@implementation ZGLogVersionDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0035";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0035";
    
    NSString *appLogPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/ZegoLogs"];
    self.logPath = appLogPath;
        
    [self setupUI];
    [self setupEngine];
    // Do any additional setup after loading the view.
}

- (void)setupEngine {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.scenario = ZegoScenarioGeneral;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    [ZegoExpressEngine setApiCalledCallback:self];
}

- (void)setupUI {
    self.logPathLabel.text = self.logPath;
    self.appIDTextfield.text = @([KeyCenter appID]).stringValue;
    self.userIDTextfield.text = [KeyCenter userID];
    self.tokenTextfield.text = [KeyCenter token];
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"SDK: %@", [ZegoExpressEngine getVersion]];
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    self.demoVersionLabel.text = [NSString stringWithFormat:@"Demo: %@.%@", [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:@"CFBundleVersion"]];
}

#pragma mark - Action

- (IBAction)onSetLogConfigButtonTapped:(id)sender {
    // [setLogConfig] must be set before calling [createEngine]
    // Once you have created Engine yet, you should destroy it before setLogConfig and setup Again
    [ZegoExpressEngine destroyEngine:nil];
    
    ZegoLogConfig *logConfig = [[ZegoLogConfig alloc] init];
    logConfig.logPath = self.logPath;
    logConfig.logSize = self.logSizeTextfield.text.longLongValue;
    [ZegoExpressEngine setLogConfig:logConfig];
    [self appendLog:[NSString stringWithFormat:@"🔨 Set Log Config, path: %@ logSize: %llu", logConfig.logPath, logConfig.logSize]];
    
    [self setupEngine];
}

- (IBAction)onShareLogConfigButtonTapped:(id)sender {
    ZGShareLogViewController *vc = [[ZGShareLogViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    [vc shareMainAppLogs];
}

- (IBAction)onSaveButtonTapped:(id)sender {
    [KeyCenter setToken: self.tokenTextfield.text];
    [KeyCenter setAppID: self.appIDTextfield.text.integerValue];
    [KeyCenter setUserID: self.userIDTextfield.text];
}

- (IBAction)onAPITestButtonTapped:(UIButton *)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Test" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"🚩 ❓ Debug Error Callback: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

- (void)onApiCalledResult:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"🚩 Api Called Result: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
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
