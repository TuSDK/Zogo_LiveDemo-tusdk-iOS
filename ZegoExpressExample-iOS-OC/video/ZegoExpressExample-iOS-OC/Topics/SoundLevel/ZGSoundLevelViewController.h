//
//  ZGSoundLevelViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Paaatrick on 2019/12/2.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_SoundLevel

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGSoundLevelViewController : UITableViewController

@property (nonatomic, assign) BOOL enableSoundLevelMonitor;
@property (nonatomic, assign) BOOL enableAudioSpectrumMonitor;
@property (nonatomic, assign) unsigned int soundLevelInterval;
@property (nonatomic, assign) unsigned int audioSpectrumInterval;

@end

NS_ASSUME_NONNULL_END

#endif
