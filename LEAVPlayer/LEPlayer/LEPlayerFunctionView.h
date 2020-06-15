//
//  LEPlayerFunctionView.h
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEPlayerConfig.h"
#import "LEPlayerFunctionBottomView.h"
#import "LEPlayerFunctionNavigationView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 职能：
    1.底部工具栏：播放暂停按钮、进度条、全屏按钮（全屏不需要再设置外部VC）
    2.顶部工具栏：返回按钮、设置菜单按钮
 */


@class LEPlayerFunctionBottomView;
@class LEPlayerFunctionNavigationView;
@protocol LEPlayerFunctionDelegate;

@interface LEPlayerFunctionView : UIView
/* action 代理 **/
@property (nonatomic, weak ,  readwrite) id<LEPlayerFunctionDelegate> delegate;
/* 底部工具栏 **/
@property (nonatomic, strong, readwrite) LEPlayerFunctionBottomView *bottomBar;
/* 顶部工具栏 **/
@property (nonatomic, strong, readwrite) LEPlayerFunctionNavigationView *navigtionBar;



/// 更新时间label
/// @param currentTime 当前播放时间点
/// @param totalDuration 总时长
- (void)updatePlayProgressTime:(NSUInteger)currentTime totalDuration:(NSUInteger)totalDuration;


@end




@protocol LEPlayerFunctionDelegate <NSObject>
@optional
/// 播放按钮、暂停按钮
/// @param toPlay 1:播放 0:暂停
- (void)functionViewPlayOrPauseAction:(BOOL)toPlay;

/// 全屏按钮
/// @param isFull 1:全屏 0:缩小
- (void)functionViewFullScreenBtnAction:(BOOL)isFull;

/// 返回按钮
/// @param sender sender
- (void)functionViewTrunBackBtnAciton:(UIButton *)sender;

/// 配置按钮
/// @param sender sender
- (void)functionViewSetBtnAction:(UIButton *)sender;

/// 播放进度修改
/// @param slider slider
/// @param state state
- (void)functionViewPlayProgressSlider:(UISlider *)slider state:(PlayProgressSlideState)state;

@end


NS_ASSUME_NONNULL_END
