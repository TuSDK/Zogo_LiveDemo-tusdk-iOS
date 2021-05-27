//
//  ZGPlayStreamSettingTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PlayStream

#import "ZGPlayStreamSettingTableViewController.h"

@interface ZGPlayStreamSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *speakerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareDecoderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mutePlayStreamVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *mutePlayStreamAudioSwitch;
@property (weak, nonatomic) IBOutlet UISlider *playVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *playerVideoLayerValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *resourceModeValueLabel;
@property (weak, nonatomic) IBOutlet UITextView *streamExtraInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *roomExtraInfoTextView;
@property (weak, nonatomic) IBOutlet UILabel *decryptionKeyLabel;

@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *videoLayerMap;
@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *resourceModeMap;

@end

@implementation ZGPlayStreamSettingTableViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamSettingTableViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.videoLayerMap = @{
        @(ZegoPlayerVideoLayerAuto): @"Auto",
        @(ZegoPlayerVideoLayerBase): @"Base",
        @(ZegoPlayerVideoLayerBaseExtend): @"Extend"
    };

    self.resourceModeMap = @{
        @(ZegoStreamResourceModeDefault): @"Default",
        @(ZegoStreamResourceModeOnlyCDN): @"OnlyCDN",
        @(ZegoStreamResourceModeOnlyL3): @"OnlyL3",
        @(ZegoStreamResourceModeOnlyRTC): @"OnlyRTC"
    };

    [self setupUI];
}

- (void)setupUI {
    self.speakerSwitch.on = ![[ZegoExpressEngine sharedEngine] isSpeakerMuted];
    self.hardwareDecoderSwitch.on = _enableHardwareDecoder;
    self.mutePlayStreamVideoSwitch.on = _mutePlayStreamVideo;
    self.mutePlayStreamAudioSwitch.on = _mutePlayStreamAudio;
    self.playVolumeSlider.continuous = NO;
    self.playVolumeSlider.value = _playVolume;
    self.playerVideoLayerValueLabel.text = self.videoLayerMap[@(self.videoLayer)];
    self.resourceModeValueLabel.text = self.resourceModeMap[@(self.resourceMode)];
    self.streamExtraInfoTextView.text = [NSString stringWithFormat:@"StreamExtraInfo\n%@", _streamExtraInfo];
    self.roomExtraInfoTextView.text = [NSString stringWithFormat:@"RoomExtraInfo\n%@", _roomExtraInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.presenter.enableHardwareDecoder = _enableHardwareDecoder;
    self.presenter.mutePlayStreamVideo = _mutePlayStreamVideo;
    self.presenter.mutePlayStreamAudio = _mutePlayStreamAudio;
    self.presenter.playVolume = _playVolume;
    self.presenter.videoLayer = _videoLayer;
    self.presenter.resourceMode = _resourceMode;
    self.presenter.decryptionKey = _decryptionKey;
}

- (IBAction)speakerSwitchValueChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] muteSpeaker:!sender.on];

    [self.presenter appendLog:[NSString stringWithFormat:@"📣 Speaker %@", sender.on ? @"on 🟢" : @"off 🔴"]];
}

- (IBAction)hardwareDecoderSwitchValueChanged:(UISwitch *)sender {
    _enableHardwareDecoder = sender.on;
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:_enableHardwareDecoder];

    [self.presenter appendLog:[NSString stringWithFormat:@"🎛 HardwareDecoder %@", sender.on ? @"on 🟢" : @"off 🔴"]];
}

- (IBAction)mutePlayStreamVideoSwitchValueChanged:(UISwitch *)sender {
    _mutePlayStreamVideo = sender.on;
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:_mutePlayStreamVideo streamID:self.streamID];

    [self.presenter appendLog:[NSString stringWithFormat:@"🙈 Mute play stream video, %@", sender.on ? @"mute 🔴" : @"unmute 🟢"]];
}

- (IBAction)mutePlayStreamAudioSwitchValueChanged:(UISwitch *)sender {
    _mutePlayStreamAudio = sender.on;
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:_mutePlayStreamAudio streamID:self.streamID];

    [self.presenter appendLog:[NSString stringWithFormat:@"🙉 Mute play stream audio, %@", sender.on ? @"mute 🔴" : @"unmute 🟢"]];
}

- (IBAction)playVolumeSliderValueChanged:(UISlider *)sender {
    _playVolume = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setPlayVolume:_playVolume streamID:_streamID];

    [self.presenter appendLog:[NSString stringWithFormat:@"🔊 Set play volume: %d", _playVolume]];
}

- (IBAction)takePlayStreamSnapshotButtonClick:(UIButton *)sender {

    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] takePlayStreamSnapshot:self.streamID callback:^(int errorCode, UIImage * _Nullable image) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf.presenter appendLog:[NSString stringWithFormat:@"🚩 📸 Take snapshot result, errorCode: %d, w:%.f, h:%.f", errorCode, image.size.width, image.size.height]];

        if (errorCode == ZegoErrorCodeCommonSuccess && image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;

            [ZegoHudManager showCustomMessage:@"Take Snapshot" customView:imageView done:nil];
        }
    }];

    [self.presenter appendLog:[NSString stringWithFormat:@"📸 Take snapshot"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"PlayerVideoLayer"]) {
        [self presentSetPlayerVideoLayerAlertController];
    } else if ([cell.reuseIdentifier isEqualToString:@"DecryptionKey"]) {
        [self presentSetDecryptionKeyAlertController];
    } else if ([cell.reuseIdentifier isEqualToString:@"ResourceMode"]) {
        [self presentSetStreamResourceModeAlertController];
    }
}

- (void)presentSetPlayerVideoLayerAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Player Video Layer" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    __weak typeof(self) weakSelf = self;

    for (NSNumber *key in self.videoLayerMap) {
        [alertController addAction:[UIAlertAction actionWithTitle:self.videoLayerMap[key] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.playerVideoLayerValueLabel.text = strongSelf.videoLayerMap[key];
            strongSelf.videoLayer = (ZegoPlayerVideoLayer)key.intValue;

            [[ZegoExpressEngine sharedEngine] setPlayStreamVideoLayer:strongSelf.videoLayer streamID:strongSelf.streamID];
            [strongSelf.presenter appendLog:[NSString stringWithFormat:@"🏞 Set player video layer: %d", (int)strongSelf.videoLayer]];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentSetStreamResourceModeAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Stream Resource Mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    __weak typeof(self) weakSelf = self;

    for (NSNumber *key in self.resourceModeMap) {
        [alertController addAction:[UIAlertAction actionWithTitle:self.resourceModeMap[key] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(self) strongSelf = weakSelf;

            strongSelf.resourceModeValueLabel.text = strongSelf.resourceModeMap[key];
            strongSelf.resourceMode = (ZegoStreamResourceMode)key.intValue;

            [strongSelf.presenter appendLog:[NSString stringWithFormat:@"🏞 Pre-set stream resource mode: %@, will be valid in next time startPlayingStream", strongSelf.resourceModeMap[key]]];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentSetDecryptionKeyAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Decryption Key" message:@"Enter decryption key" preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        __strong typeof(self) strongSelf = weakSelf;
        textField.placeholder = @"Decryption Key";
        textField.text = strongSelf.decryptionKey;
    }];

    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(self) strongSelf = weakSelf;
        UITextField *keyTextField = [alertController.textFields firstObject];

        if (!keyTextField) return;

        strongSelf.decryptionKey = keyTextField.text;

        [strongSelf.presenter appendLog:[NSString stringWithFormat:@"🔐 Set decryption key: %@", strongSelf.decryptionKey]];
        strongSelf.decryptionKeyLabel.text = [NSString stringWithFormat:@"%@", strongSelf.decryptionKey];

        [[ZegoExpressEngine sharedEngine] setPlayStreamDecryptionKey:strongSelf.decryptionKey streamID:strongSelf.streamID];
    }];

    [alertController addAction:setAction];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

@end

#endif
