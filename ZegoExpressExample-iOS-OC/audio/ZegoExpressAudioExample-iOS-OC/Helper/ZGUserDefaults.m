//
//  ZGUserDefaults.m
//  ZegoExpressAudioExample-iOS-OC
//
//  Created by zego on 2020/5/26.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGUserDefaults.h"

@implementation ZGUserDefaults

+ (NSUserDefaults *)standardUserDefaults{
    @throw ([NSException exceptionWithName:@"Not support this method. Please init `ZGUserDefaults` with `init` mothod"  reason:nil userInfo:nil]);
    return nil;
}

-(instancetype)initWithSuiteName:(NSString *)username{
    @throw ([NSException exceptionWithName:@"Not support this method. Please init `ZGUserDefaults` with `init` mothod"  reason:nil userInfo:nil]);
    return nil;
}

-(instancetype)init{
    self = [super initWithSuiteName:@"group.ZegoExpressAudioExample-iOS-OC"];
    return self;
}
@end
