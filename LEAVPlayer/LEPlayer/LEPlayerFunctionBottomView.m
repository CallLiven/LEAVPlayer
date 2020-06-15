//
//  LEPlayerFunctionBottomView.m
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEPlayerFunctionBottomView.h"
#import "LEPlayerConfig.h"

@implementation LEPlayerFunctionBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self le_addSubviews];
    }
    return self;
}


- (void)le_addSubviews {
    UIImageView *shadowImg = [[UIImageView alloc]init];
    shadowImg.image = LEImage(@"fun_shadow_bottom");
    shadowImg.contentMode = UIViewContentModeScaleToFill;
    shadowImg.userInteractionEnabled = YES;
    [self addSubview:shadowImg];
    
    /// 缓存进度条
    UIProgressView *cacheProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    cacheProgress.progressTintColor = [UIColor darkGrayColor];
    cacheProgress.trackTintColor = [UIColor clearColor];
    cacheProgress.progress = 0.0;
    [self addSubview:cacheProgress];
    
    /// 播放进度条
    UISlider *progress = [[UISlider alloc]init];
    progress.minimumValue = 0.0;
    progress.maximumValue = 1.0;
    progress.minimumTrackTintColor = [UIColor blueColor];
    progress.maximumTrackTintColor = [UIColor lightGrayColor];
    progress.value = 0.0;
    [progress addTarget:self action:@selector(progressSliderChangeBegainAction:) forControlEvents:UIControlEventTouchDown];
    [progress addTarget:self action:@selector(progressSliderChangingAction:) forControlEvents:UIControlEventValueChanged];
    [progress addTarget:self action:@selector(progressSliderChangeEndAction:) forControlEvents:UIControlEventTouchUpInside];
    [progress setThumbImage:LEImage(@"fun_progress_dot") forState:UIControlStateNormal];
    
    
    [self addSubview:progress];
    
    /// 播放时间显示
    UILabel *timelb = [[UILabel alloc]init];
    timelb.numberOfLines = 1;
    timelb.textAlignment = NSTextAlignmentCenter;
    timelb.textColor = LETimeTextColor;
    timelb.font = LETimeFont;
    timelb.text = @"00:00:00/00:00:00";
    [self addSubview:timelb];
    
    /// 播放暂停按钮
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setImage:LEImage(@"fun_pause") forState:UIControlStateNormal];
    [playBtn setImage:LEImage(@"fun_play") forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(startPlayBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    
    /// 全屏按钮
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenBtn setImage:LEImage(@"fun_fullScreen") forState:UIControlStateNormal];
    [fullScreenBtn setImage:LEImage(@"fun_no_fullScreen") forState:UIControlStateSelected];
    [fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:fullScreenBtn];
    
    self.bottomShaow  = shadowImg;
    self.progressSlider = progress;
    self.cachedProgress = cacheProgress;
    self.timelb = timelb;
    self.startPlayBtn = playBtn;
    self.fullScreenBtn = fullScreenBtn;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat totalW = self.bounds.size.width;
    CGFloat totalH = self.bounds.size.height;
    CGFloat horiSpace = 8;
    
    self.bottomShaow.frame = CGRectMake(0, 0, totalW, totalH);
    self.startPlayBtn.frame = CGRectMake(0, 0, totalH, totalH);
    self.fullScreenBtn.frame = CGRectMake(totalW - totalH, 0, totalH, totalH);
    
    [self.timelb sizeToFit];
    CGFloat timelbW = self.timelb.frame.size.width + 5;
    self.timelb.frame = CGRectMake(totalW - totalH - timelbW, 0, timelbW, totalH);
    
    CGFloat startBtnRightX = CGRectGetMaxX(self.startPlayBtn.frame);
    CGFloat timeLeftX = totalW - CGRectGetMinX(self.timelb.frame);
    
    self.cachedProgress.frame = CGRectMake(startBtnRightX, (totalH-2)/2, totalW - timeLeftX - startBtnRightX - horiSpace, 2);
    self.progressSlider.frame = self.cachedProgress.frame;
}


#pragma mark - Action
- (void)startPlayBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(bottomView:playBtnAction:)]) {
        [self.delegate bottomView:self playBtnAction:!sender.selected];
    }
}


- (void)fullScreenBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(bottomView:fullScreenBtnAction:)]) {
        [self.delegate bottomView:self fullScreenBtnAction:sender.selected];
    }
}


- (void)progressSliderAction:(UISlider *)slider state:(PlayProgressSlideState)state {
    if ([self.delegate respondsToSelector:@selector(bottomView:playProgressSliderChange:state:)]) {
        [self.delegate bottomView:self playProgressSliderChange:slider state:state];
    }
}

/// 开始滑动
/// @param slider slider
- (void)progressSliderChangeBegainAction:(UISlider *)slider {
    [self progressSliderAction:slider state:PlayProgressSlideStateBegain];
}

/// 滑动中
/// @param slider slider
- (void)progressSliderChangingAction:(UISlider *)slider {
    [self progressSliderAction:slider state:PlayProgressSlideStateChanging];
}

/// 滑动结束
/// @param slider slider
- (void)progressSliderChangeEndAction:(UISlider *)slider {
    [self progressSliderAction:slider state:PlayProgressSlideStateEnd];
}

@end
