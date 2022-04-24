//
//  TTViewManager.h
//  PLMediaStreamingKitDemo
//
//  Created by 刘鹏程 on 2022/3/9.
//  Copyright © 2022 0dayZh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTRenderDef.h"
#import "TTBeautyProxy.h"
#import "TTBeautyManager.h"
NS_ASSUME_NONNULL_BEGIN


@interface TTViewManager : NSObject

+ (instancetype)shareInstance;
/**
 * 设置承载视图
 * @param superView 目标视图
 */
- (void)setupSuperView:(UIView *)superView;

- (void)setBeautyTarget:(id<TTBeautyProtocol>)beautyTarget;

/// 销毁视图
- (void)destory;

@end

NS_ASSUME_NONNULL_END
