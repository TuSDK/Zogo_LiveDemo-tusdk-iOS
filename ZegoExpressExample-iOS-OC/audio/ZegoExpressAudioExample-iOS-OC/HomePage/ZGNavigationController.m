//
//  ZGNavigationController.m
//  ZegoExpressAudioExample-iOS-OC
//
//  Created by zego on 2020/5/25.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGNavigationController.h"
#import "ZegoLogView.h"

@interface ZGNavigationController ()

@end

@implementation ZGNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.navigationBar.translucent = NO;
    }
    
    return self;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [ZegoLogView show];
}
@end
