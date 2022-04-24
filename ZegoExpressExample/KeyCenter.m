//
//  KeyCenter.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2019/11/11.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "KeyCenter.h"

@implementation KeyCenter

// Developers can get appID from admin console.
// https://console.zego.im/dashboard
// for example: 123456789;
static unsigned int _appID = 111;

// Developers should customize a user ID.
// for example: @"zego_benjamin";
static NSString *_userID = @"111";

// Developers can get token from admin console.
// https://console.zego.im/dashboard
// Note: The user ID used to generate the token needs to be the same as the userID filled in above!
// for example: @"04AAAAAxxxxxxxxxxxxxx";
static NSString *_token = @"111";

+ (unsigned int)appID {
    return _appID;
}

+ (void)setAppID:(unsigned int)appID {
    _appID = appID;
}

+ (NSString *)userID {
    return _userID;
}

+ (void)setUserID:(NSString *)userID {
    _userID = userID;
}

+ (NSString *)token {
    return _token;
}

+ (void)setToken:(NSString *)token {
    _token = token;
}

@end
