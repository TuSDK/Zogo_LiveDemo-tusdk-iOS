//
//  ZGAudioPreprocessMainViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/10/2.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioPreprocess

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGAudioPreprocessMainViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *localPublishStreamID;
@property (nonatomic, copy) NSString *remotePlayStreamID;


@end

NS_ASSUME_NONNULL_END

#endif
