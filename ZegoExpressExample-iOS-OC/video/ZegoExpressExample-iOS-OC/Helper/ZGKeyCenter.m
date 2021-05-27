//
//  ZGKeyCenter.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/11.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGKeyCenter.h"
#warning appID
@implementation ZGKeyCenter

// Apply AppID and AppSign from Zego
+ (unsigned int)appID {
// for example:
//     return 1234567890;
    return 3224869841;
}

// Apply AppID and AppSign from Zego
+ (NSString *)appSign {
// for example:
//     return @"abcdefghijklmnopqrstuvwzyv123456789abcdefghijklmnopqrstuvwzyz123";
    return @"9f6f048b1fc757ac7e38835b0eacd4426c7d53c77858ac1070c2050b9a47fc56";
}

@end
