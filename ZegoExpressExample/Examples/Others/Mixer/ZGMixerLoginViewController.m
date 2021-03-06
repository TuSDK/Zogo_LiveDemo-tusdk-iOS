//
//  ZGMixerLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/21.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMixerLoginViewController.h"
#import "ZGMixerPublishViewController.h"
#import "ZGMixerViewController.h"
#import "ZGAutoMixerViewController.h"

@interface ZGMixerLoginViewController ()

@end

@implementation ZGMixerLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)jumpToPublisher:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Mixer" bundle:nil];
    
    ZGMixerPublishViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMixerPublishViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)jumpToMixer:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Mixer" bundle:nil];
    
    ZGMixerViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMixerViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)jumpToAutoMixer:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Mixer" bundle:nil];
    
    ZGMixerViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAutoMixerViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
