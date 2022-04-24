//
//  TTViewManager.m
//  PLMediaStreamingKitDemo
//
//  Created by 刘鹏程 on 2022/3/9.
//  Copyright © 2022 0dayZh. All rights reserved.
//

#import "TTViewManager.h"
#import "TTFilterPanelView.h"
#import "TTStickerPanelView.h"
#import "TTBeautyPanelView.h"
@interface TTViewManager()<TTStickerPanelViewDelegate>

@property (nonatomic, strong) UIView *superView;
/// 滤镜按钮
@property (nonatomic, strong) UIButton *filterButton;
/// 贴纸按钮
@property (nonatomic, strong) UIButton *stickerButton;
/// 美肤按钮
@property (nonatomic, strong) UIButton *beautyButton;
/// 滤镜视图
@property (nonatomic, strong) TTFilterPanelView *filterPanelView;
/// 贴纸视图
@property (nonatomic, strong) TTStickerPanelView *stickerPanelView;
/// 美肤视图
@property (nonatomic, strong) TTBeautyPanelView *beautyPanelView;

@property(nonatomic, strong) id<TTBeautyProtocol> beautyTarget;

@end

@implementation TTViewManager

static TTViewManager *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (void)setBeautyTarget:(id<TTBeautyProtocol>)beautyTarget
{
    _beautyTarget = beautyTarget;
}


// MARK : UI setter
- (void)setupSuperView:(UIView *)superView
{
    [self destory];
    
    _superView = superView;
    
    CGFloat startX = 15;
    CGFloat btnMinY = 340 - 88;
    CGFloat btnW = 46;
    
    UIColor *btnBGColor = [UIColor colorWithRed:255.f / 255 green:102.f / 255 blue:51.f / 102 alpha:1];
    //滤镜按钮
    _filterButton = [[UIButton alloc]initWithFrame:CGRectMake(startX, btnMinY, btnW, btnW)];
    _filterButton.layer.cornerRadius = 16;
    _filterButton.backgroundColor = btnBGColor;
    [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    _filterButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_filterButton addTarget:self action:@selector(clickFilterBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_superView addSubview:_filterButton];
    
    //贴纸按钮
    _stickerButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterButton.frame) + 15, btnW, btnW)];
    _stickerButton.layer.cornerRadius = 16;
    _stickerButton.backgroundColor = btnBGColor;
    [_stickerButton setTitle:@"贴纸" forState:UIControlStateNormal];
    _stickerButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_stickerButton addTarget:self action:@selector(clickStickerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_superView addSubview:_stickerButton];
    
    //美肤按钮
    _beautyButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_stickerButton.frame) + 15, btnW, btnW)];
    _beautyButton.layer.cornerRadius = 16;
    _beautyButton.backgroundColor = btnBGColor;
    [_beautyButton setTitle:@"微整形" forState:UIControlStateNormal];
    _beautyButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_beautyButton addTarget:self action:@selector(clickBeautyBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_superView addSubview:_beautyButton];
    
    CGFloat KScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat KScreenHeight = [UIScreen mainScreen].bounds.size.height;
    
    _filterPanelView = [TTFilterPanelView beautyPanelWithFrame:CGRectMake(0, KScreenHeight - 246 - 88, KScreenWidth, 246) beautyTarget:_beautyTarget];
    
    _filterPanelView.hidden = YES;
    [_superView addSubview:_filterPanelView];
    
    
    _stickerPanelView = [TTStickerPanelView beautyPanelWithFrame:CGRectMake(0, KScreenHeight - 300 - 88, KScreenWidth, 300) beautyTarget:self.beautyTarget];
    
    _stickerPanelView.hidden = YES;
    _stickerPanelView.delegate = self;
    [_superView addSubview:_stickerPanelView];
    
    //美颜视图
    _beautyPanelView = [TTBeautyPanelView beautyPanelWithFrame:CGRectMake(0, KScreenHeight - 276 - 88, KScreenWidth, 276) beautyTarget:self.beautyTarget];
//    _beautyPanelView.delegate = self;
    _beautyPanelView.hidden = YES;
    [_superView addSubview:_beautyPanelView];
}

/// 滤镜按钮点击事件
- (void)clickFilterBtnAction
{
    _filterPanelView.hidden = !_filterPanelView.hidden;
    _beautyPanelView.hidden = _stickerPanelView.hidden = YES;
}
/// 贴纸按钮点击事件
- (void)clickStickerBtnAction
{
    _stickerPanelView.hidden = !_stickerPanelView.hidden;
    _beautyPanelView.hidden = _filterPanelView.hidden = YES;
}
/// 美肤按钮点击事件
- (void)clickBeautyBtnAction
{
    _beautyPanelView.hidden = !_beautyPanelView.hidden;
    _stickerPanelView.hidden = _filterPanelView.hidden = YES;
}

- (void)destory
{
    [_filterButton removeFromSuperview];
    [_stickerButton removeFromSuperview];
    [_beautyButton removeFromSuperview];
    
    [_filterPanelView removeFromSuperview];
    [_stickerPanelView removeFromSuperview];
    [_beautyPanelView removeFromSuperview];
}

#pragma mark - TTStickerPanelViewDelegate
//选中贴纸类型为哈哈镜时，取消微整形效果
- (void)stickerPanelView:(TTStickerPanelView * _Nullable)panelView didSelectItem:(__kindof TuStickerBaseData *)categoryItem;
{
    //动态贴纸和哈哈镜不能同时存在
    if ([categoryItem isKindOfClass:[TuMonsterData class]])
    {
        // 微整形移除
        [_beautyPanelView enablePlastic:NO];
        [_beautyPanelView enableExtraPlastic:NO];
    }
}

@end
