//
//  ZGSoundLevelSettingTabelViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/3.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_SoundLevel

#import <UIKit/UIKit.h>
#import "ZGSoundLevelViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGSoundLevelSettingTabelViewController : UITableViewController

+ (instancetype)instanceFromStoryboard;

@property (nonatomic, weak) ZGSoundLevelViewController *presenter;

@property (nonatomic, assign) BOOL enableSoundLevelMonitor;
@property (nonatomic, assign) BOOL enableAudioSpectrumMonitor;
@property (nonatomic, assign) unsigned int soundLevelInterval;
@property (nonatomic, assign) unsigned int audioSpectrumInterval;

@end

NS_ASSUME_NONNULL_END

#endif
