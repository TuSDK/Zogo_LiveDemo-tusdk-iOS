//
//  ZGAudioPreprocessLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/10/2.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioPreprocess

#import "ZGAudioPreprocessLoginViewController.h"
#import "ZGAudioPreprocessMainViewController.h"
#import "ZGUserIDHelper.h"

NSString* const ZGAudioPreprocessRoomID = @"ZGAudioPreprocessRoomID";
NSString* const ZGAudioPreprocessLocalPublishStreamID = @"ZGAudioPreprocessLocalPublishStreamID";
NSString* const ZGAudioPreprocessRemotePlayStreamID = @"ZGAudioPreprocessRemotePlayStreamID";

@interface ZGAudioPreprocessLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *localPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamIDTextField;

@end

@implementation ZGAudioPreprocessLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomIDTextField.text = [self savedValueForKey:ZGAudioPreprocessRoomID] ?: @"AudioPreprocessRoom-1";
    self.localPublishStreamIDTextField.text = [self savedValueForKey:ZGAudioPreprocessLocalPublishStreamID] ?: ZGUserIDHelper.userID;
    self.remotePlayStreamIDTextField.text = [self savedValueForKey:ZGAudioPreprocessRemotePlayStreamID] ?: ZGUserIDHelper.userID;
}

- (IBAction)startLiveButtonClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AudioPreprocess" bundle:nil];
    ZGAudioPreprocessMainViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioPreprocessMainViewController class])];

    [self saveValue:self.roomIDTextField.text forKey:ZGAudioPreprocessRoomID];
    [self saveValue:self.localPublishStreamIDTextField.text forKey:ZGAudioPreprocessLocalPublishStreamID];
    [self saveValue:self.remotePlayStreamIDTextField.text forKey:ZGAudioPreprocessRemotePlayStreamID];

    vc.roomID = self.roomIDTextField.text;
    vc.localPublishStreamID = self.localPublishStreamIDTextField.text;
    vc.remotePlayStreamID = self.remotePlayStreamIDTextField.text;

    [self.navigationController pushViewController:vc animated:YES];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

#endif
