//
//  ZGCustomAudioCaptureAndRenderingLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomAudioCaptureAndRenderingLoginViewController.h"
#import "ZGCustomAudioCaptureAndRenderingViewController.h"

NSString* const ZGCustomAudioIORoomID = @"ZGCustomAudioIORoomID";
NSString* const ZGCustomAudioIOLocalPublishStreamID = @"ZGCustomAudioIOLocalPublishStreamID";
NSString* const ZGCustomAudioIORemotePlayStreamID = @"ZGCustomAudioIORemotePlayStreamID";

@interface ZGCustomAudioCaptureAndRenderingLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *localPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamIDTextField;
@property (weak, nonatomic) IBOutlet UISwitch *enableCustomAudioRenderSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *audioSourceSeg;

@property (weak, nonatomic) IBOutlet UILabel *audioSourceLabel;

@property (weak, nonatomic) IBOutlet UILabel *customAudioRenderLabel;


@end

@implementation ZGCustomAudioCaptureAndRenderingLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomIDTextField.text = @"0022";
    self.localPublishStreamIDTextField.text = @"0022";
    self.remotePlayStreamIDTextField.text = @"0022";
}

- (void)setupUI {
    self.audioSourceLabel.text = NSLocalizedString(@"Audio Source", nil);
    self.customAudioRenderLabel.text = NSLocalizedString(@"Custom Audio Capture And Render", nil);
}

- (IBAction)startLiveButtonClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioCaptureAndRendering" bundle:nil];
    ZGCustomAudioCaptureAndRenderingViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZGCustomAudioCaptureAndRenderingViewController"];

    vc.roomID = self.roomIDTextField.text;
    vc.localPublishStreamID = self.localPublishStreamIDTextField.text;
    vc.remotePlayStreamID = self.remotePlayStreamIDTextField.text;

    vc.audioSourceType = (ZGCustomAudioCaptureSourceType)self.audioSourceSeg.selectedSegmentIndex;
    
    vc.enableCustomAudioRender = self.enableCustomAudioRenderSwitch.on;

    [self.navigationController pushViewController:vc animated:YES];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
