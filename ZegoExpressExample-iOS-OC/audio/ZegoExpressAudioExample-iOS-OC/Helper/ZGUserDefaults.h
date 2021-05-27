//
//  ZGUserDefaults.h
//  ZegoExpressAudioExample-iOS-OC
//
//  Created by zego on 2020/5/26.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGUserDefaults : NSUserDefaults

+ (NSUserDefaults *)standardUserDefaults NS_UNAVAILABLE;

-(instancetype)initWithSuiteName:(nullable NSString *)suitename NS_UNAVAILABLE;

-(instancetype)init;

@end

NS_ASSUME_NONNULL_END
