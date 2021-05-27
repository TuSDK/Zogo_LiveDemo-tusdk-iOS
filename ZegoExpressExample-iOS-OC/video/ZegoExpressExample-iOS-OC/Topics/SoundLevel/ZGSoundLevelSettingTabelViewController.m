//
//  ZGSoundLevelSettingTabelViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/3.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_SoundLevel

#import "ZGSoundLevelSettingTabelViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGSoundLevelSettingTabelViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *soundLevelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *audioSpectrumSwitch;

@property (weak, nonatomic) IBOutlet UISlider *soundLevelIntervalSlider;
@property (weak, nonatomic) IBOutlet UISlider *audioSpectrumIntervalSlider;

@property (weak, nonatomic) IBOutlet UILabel *soundLevelIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioSpectrumIntervalLabel;

@end

@implementation ZGSoundLevelSettingTabelViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SoundLevel" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGSoundLevelSettingTabelViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI {
    self.soundLevelSwitch.on = _enableSoundLevelMonitor;
    self.audioSpectrumSwitch.on = _enableAudioSpectrumMonitor;

    self.soundLevelIntervalSlider.value = _soundLevelInterval;
    self.audioSpectrumIntervalSlider.value = _audioSpectrumInterval;

    self.soundLevelIntervalLabel.text = [NSString stringWithFormat:@"%ums", _soundLevelInterval];
    self.audioSpectrumIntervalLabel.text = [NSString stringWithFormat:@"%ums", _audioSpectrumInterval];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.presenter.enableSoundLevelMonitor = _enableSoundLevelMonitor;
    self.presenter.enableAudioSpectrumMonitor = _enableAudioSpectrumMonitor;
    self.presenter.soundLevelInterval = _soundLevelInterval;
    self.presenter.audioSpectrumInterval = _audioSpectrumInterval;
}

- (IBAction)soundLevelSwitchValueChanged:(UISwitch *)sender {
    self.enableSoundLevelMonitor = sender.on;
    ZGLogInfo(@"🎶 %@ sound level monitor, interval: %u", _enableSoundLevelMonitor ? @"Start" : @"Stop", _soundLevelInterval);

    if (_enableSoundLevelMonitor) {
        [[ZegoExpressEngine sharedEngine] startSoundLevelMonitor:_soundLevelInterval];
    } else {
        [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    }
}

- (IBAction)soundLevelIntervalSliderValueChanged:(UISlider *)sender {
    self.soundLevelInterval = (unsigned int)sender.value;
    self.soundLevelIntervalLabel.text = [NSString stringWithFormat:@"%ums", _soundLevelInterval];
}

- (IBAction)soundLevelIntervalSliderTouchUp:(UISlider *)sender {
    ZGLogInfo(@"🎶 Sound level interval changed to %u ms", _soundLevelInterval);
    if (_enableSoundLevelMonitor) {
        ZGLogInfo(@"🎶 Restart sound level monitor");
        [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
        [[ZegoExpressEngine sharedEngine] startSoundLevelMonitor:_soundLevelInterval];
    }
}

- (IBAction)audioSpectrumSwitchValueChanged:(UISwitch *)sender {
    self.enableAudioSpectrumMonitor = sender.on;
    ZGLogInfo(@"📼 %@ audio spectrum monitor, interval: %u", _enableAudioSpectrumMonitor ? @"Start" : @"Stop", _audioSpectrumInterval);

    if (_enableAudioSpectrumMonitor) {
        [[ZegoExpressEngine sharedEngine] startAudioSpectrumMonitor:_audioSpectrumInterval];
    } else {
        [[ZegoExpressEngine sharedEngine] stopAudioSpectrumMonitor];
    }
}

- (IBAction)audioSpectrumIntervalSliderValueChanged:(UISlider *)sender {
    self.audioSpectrumInterval = (unsigned int)sender.value;
    self.audioSpectrumIntervalLabel.text = [NSString stringWithFormat:@"%ums", _audioSpectrumInterval];
}

- (IBAction)audioSpectrumIntervalSliderTouchUp:(UISlider *)sender {
    ZGLogInfo(@"📼 Audio spectrum interval changed to %u ms", _audioSpectrumInterval);
    if (_enableAudioSpectrumMonitor) {
        ZGLogInfo(@"📼 Restart audio spectrum monitor");
        [[ZegoExpressEngine sharedEngine] stopAudioSpectrumMonitor];
        [[ZegoExpressEngine sharedEngine] startAudioSpectrumMonitor:_audioSpectrumInterval];
    }
}

@end

#endif
