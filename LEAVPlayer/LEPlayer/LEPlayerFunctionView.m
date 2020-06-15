//
//  LEPlayerFunctionView.m
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEPlayerFunctionView.h"

@interface LEPlayerFunctionView()<LEPlayerFunctionBottomViewDelegate>
@end


@implementation LEPlayerFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self le_addSubViews];
    }
    return self;
}


- (void)le_addSubViews {
    [self addSubview:self.bottomBar];
    [self addSubview:self.navigtionBar];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat totalW = self.bounds.size.width;
    CGFloat totalH = self.bounds.size.height;
    self.bottomBar.frame = CGRectMake(0, totalH - kBottomBarHeight, totalW, kBottomBarHeight);
    self.navigtionBar.frame = CGRectMake(0, 0, totalW, kNavigationBarHeight);
}


/// 更新时间label
/// @param currentTime 当前播放时间点
/// @param totalDuration 总时长
- (void)updatePlayProgressTime:(NSUInteger)currentTime totalDuration:(NSUInteger)totalDuration {
    /// 更新播放时间
    BOOL isMoreThanHour = totalDuration > 3600;
    NSString *total = [self timeFormationWithDuration:totalDuration isMoreThanWithHour:isMoreThanHour];
    NSString *current = [self timeFormationWithDuration:currentTime isMoreThanWithHour:isMoreThanHour];
    self.bottomBar.timelb.text = [NSString stringWithFormat:@"%@/%@",current,total];
    if (currentTime == 0) {
        [self.bottomBar setNeedsLayout];
        [self.bottomBar layoutIfNeeded];
    }
    
    /// 更新进度条
    self.bottomBar.progressSlider.value = 1.0*currentTime/totalDuration;
}


- (NSString *)timeFormationWithDuration:(NSUInteger)duration isMoreThanWithHour:(BOOL)isMoreThan {
    NSUInteger hours = duration/3600;
    NSUInteger min = duration%3600/60;
    NSUInteger sed = duration%60;
    if (isMoreThan) {
        return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",hours,min,sed];
    }
    return [NSString stringWithFormat:@"%02lu:%02lu",min,sed];
}



#pragma mark - LEPlayerFunctionBottomViewDelegate
- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView playBtnAction:(BOOL)isSelected {
    if ([self.delegate respondsToSelector:@selector(functionViewPlayOrPauseAction:)]) {
        [self.delegate functionViewPlayOrPauseAction:isSelected];
    }
}

- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView fullScreenBtnAction:(BOOL)isFull {
    if ([self.delegate respondsToSelector:@selector(functionViewFullScreenBtnAction:)]) {
        [self.delegate functionViewFullScreenBtnAction:isFull];
    }
}

- (void)bottomView:(LEPlayerFunctionBottomView *)bottomView playProgressSliderChange:(UISlider *)progressSlider state:(PlayProgressSlideState)state {
    if ([self.delegate respondsToSelector:@selector(functionViewPlayProgressSlider:state:)]) {
        [self.delegate functionViewPlayProgressSlider:progressSlider state:state];
    }
}


#pragma mark - Getter
- (LEPlayerFunctionBottomView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[LEPlayerFunctionBottomView alloc]init];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}


- (LEPlayerFunctionNavigationView *)navigtionBar {
    if (!_navigtionBar) {
        _navigtionBar = [[LEPlayerFunctionNavigationView alloc]init];
    }
    return _navigtionBar;
}

@end
