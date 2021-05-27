//
//  ZGAudioEffectPlayerLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/22.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioEffectPlayer

#import "ZGAudioEffectPlayerLoginViewController.h"
#import "ZGAudioEffectPlayerViewController.h"

NSString* const ZGAudioEffectPlayerTopicRoomID = @"ZGAudioEffectPlayerTopicRoomID";
NSString* const ZGAudioEffectPlayerTopicStreamID = @"ZGAudioEffectPlayerTopicStreamID";

@interface ZGAudioEffectPlayerLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@end

@implementation ZGAudioEffectPlayerLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomIDTextField.text = [self savedValueForKey:ZGAudioEffectPlayerTopicRoomID];
    self.streamIDTextField.text = [self savedValueForKey:ZGAudioEffectPlayerTopicStreamID];
}

- (IBAction)onPressedEnter:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AudioEffectPlayer" bundle:nil];

    ZGAudioEffectPlayerViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioEffectPlayerViewController class])];

    vc.roomID = self.roomIDTextField.text;
    vc.streamID = self.streamIDTextField.text;

    [self saveValue:self.roomIDTextField.text forKey:ZGAudioEffectPlayerTopicRoomID];
    [self saveValue:self.streamIDTextField.text forKey:ZGAudioEffectPlayerTopicStreamID];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

#endif
