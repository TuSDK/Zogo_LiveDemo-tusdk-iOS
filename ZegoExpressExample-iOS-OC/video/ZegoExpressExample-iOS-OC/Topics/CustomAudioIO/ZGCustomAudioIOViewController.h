//
//  ZGCustomAudioIOViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomAudioIO

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZGCustomAudioCaptureSourceType) {
    ZGCustomAudioCaptureSourceTypeLocalMedia = 0,
    ZGCustomAudioCaptureSourceTypeDeviceMicrophone = 1,
};

@interface ZGCustomAudioIOViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *localPublishStreamID;
@property (nonatomic, copy) NSString *remotePlayStreamID;

@property (nonatomic, assign) ZGCustomAudioCaptureSourceType audioSourceType;

@property (nonatomic, assign) BOOL enableCustomAudioRender;

@end

NS_ASSUME_NONNULL_END

#endif
