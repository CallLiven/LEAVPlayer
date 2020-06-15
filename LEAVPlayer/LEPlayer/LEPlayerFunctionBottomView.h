//
//  LEPlayerFunctionBottomView.h
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEPlayerConfig.h"

NS_ASSUME_NONNULL_BEGIN
@protocol LEPlayerFunctionBottomViewDelegate;

@interface LEPlayerFunctionBottomView : UIView
/* 代理 **/
@property (nonatomic, weak ,  readwrite) id<LEPlayerFunctionBottomViewDelegate> delegate;
/* 播放进度条 **/
@property (nonatomic, strong, readwrite) UISlider *progressSlider;
/* 缓存进度条 **/
@property (nonatomic, strong, readwrite) UIProgressView *cachedProgress;
/* 播放时间 **/
@property (nonatomic, strong, readwrite) UILabel *timelb;
/* 播放按钮 **/
@property (nonatomic, strong, readwrite) UIButton *startPlayBtn;
/* 全屏按钮 **/
@property (nonatomic, strong, readwrite) UIButton *fullScreenBtn;
/* 底部蒙层 **/
@property (nonatomic, strong, readwrite) UIImageView *bottomShaow;

@end




@protocol LEPlayerFunctionBottomViewDelegate <NSObject>
/// 播放按钮点击
/// @param bottomView bottomView
/// @param isSelected 0:暂停  1:播放
- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView playBtnAction:(BOOL)isSelected;


/// 全屏按钮点击
/// @param bottomView bottomView
/// @param isFull 1:缩小  0:全屏
- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView fullScreenBtnAction:(BOOL)isFull;


/// 播放进度条滑动
/// @param bottomView bottomeView
/// @param progressSlider progressSlider
/// @param state 状态
- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView playProgressSliderChange:(UISlider *)progressSlider state:(PlayProgressSlideState)state;
@end

NS_ASSUME_NONNULL_END
