//
//  LEPlayer.m
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import "LEResourceLoaderManager.h"
#import "LERotationManager.h"

#import "LEPlayerFunctionView.h"
#import "LEAVPlayerView.h"

@interface LEPlayer()<LEPlayerFunctionDelegate>
/* AVPlayer **/
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/* 横竖屏切换 **/
@property (nonatomic, strong) LERotationManager *rotationManager;
/* 边播边缓存 **/
@property (nonatomic, strong) LEResourceLoaderManager *loaderManager;
/* 功能视图 **/
@property (nonatomic, strong) LEPlayerFunctionView *functionView;

/* PlayLayerContainView **/
@property (nonatomic, strong) UIView *containView;
/* playLayer **/
@property (nonatomic, strong) LEAVPlayerView *playerLayerView;

/* 播放进度是否在拖动中 **/
@property (nonatomic, assign) BOOL  isSliding;
/* 是否全屏播放 **/
@property (nonatomic, assign) BOOL  isFullScreen;
@end

@implementation LEPlayer

- (void)dealloc {
    NSLog(@"LEPlayer被销毁");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        [self configDefaultParams];
        [self le_addSubviews];
        [self le_addObserver];
    }
    return self;
}

/// 配置默认值
- (void)configDefaultParams {
    self.isSliding = NO;
    self.isFullScreen = NO;
    self.autoPlay = YES;
}

/// 添加子视图
- (void)le_addSubviews {
    self.backgroundColor = [UIColor blackColor];
    /// 创建view容器
    [self addSubview:self.containView];
    /// 初始化缓存模块
    self.loaderManager = [[LEResourceLoaderManager alloc]init];
    /// 初始化player
    self.player = [[AVPlayer alloc]init];
    self.playerLayerView = [[LEAVPlayerView alloc]initWithFrame:self.containView.bounds];
    self.playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    /// 关键参数：能尽快的播放
    if (@available(iOS 10.0, *)) self.player.automaticallyWaitsToMinimizeStalling = NO;
    self.playerLayer = (AVPlayerLayer *)[self.playerLayerView layer];
    self.playerLayer.player = self.player;
    self.playerLayer.frame = self.containView.bounds;
    self.playerLayer.contentsGravity = kCAGravityResize;
    [self.containView addSubview:self.playerLayerView];
    
    /// 功能视图
    self.functionView.frame = self.containView.bounds;
    [self.containView addSubview:self.functionView];
    
    /// 初始化旋转模块
    self.rotationManager = [[LERotationManager alloc]init];
    /// 设置要旋转的view
    self.rotationManager.target = self.containView;
    self.rotationManager.superView = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

/// 添加播放器监听
- (void)le_addObserver {
    [self le_addPlayProgressObserver];
}

/// 添加播放进度监听
- (void)le_addPlayProgressObserver {
    __weak __typeof(self) wself = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        AVPlayerItem *currentItem =  wself.player.currentItem;
        if (currentItem.status == AVPlayerItemStatusReadyToPlay && self.isSliding == NO) {
            /// 当前播放时间
            NSUInteger currentTime = (NSUInteger)(currentItem.currentTime.value/currentItem.currentTime.timescale);
            /// 总时长
            NSUInteger totalTime = (NSUInteger)CMTimeGetSeconds(wself.player.currentItem.asset.duration);
            [wself.functionView updatePlayProgressTime:currentTime totalDuration:totalTime];
        }
    }];
}

#pragma -mark 添加播放源
- (void)setPlayUrl:(NSString *)playUrl {
    _playUrl = playUrl;
    if (playUrl) {
        [self pause];
        AVPlayerItem *playItem = [self.loaderManager playerItemWithURL:[NSURL URLWithString:playUrl]];
        [playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.player replaceCurrentItemWithPlayerItem:playItem];
    }
}

#pragma -mark 播放
- (void)play {
    [self.player play];
}

#pragma -mark 暂停
- (void)pause {
    [self.player pause];
}

#pragma -mark 销毁播放器
- (void)destroyPlayer {
    
}

#pragma mark - LEPlayerFunctionDelegate(工具栏交互回调)
/// 播放按钮、暂停按钮
/// @param toPlay 1:播放 0:暂停
- (void)functionViewPlayOrPauseAction:(BOOL)toPlay {
    toPlay?[self.player play]:[self.player pause];
}

/// 全屏按钮
/// @param isFull 1:全屏 0:缩小
- (void)functionViewFullScreenBtnAction:(BOOL)isFull {
    [self.rotationManager rotate];
}

/// 返回按钮
/// @param sender sender
- (void)functionViewTrunBackBtnAciton:(UIButton *)sender {
    
}

/// 配置按钮
/// @param sender sender
- (void)functionViewSetBtnAction:(UIButton *)sender {
    
}

/// 播放进度修改
/// @param slider slider
/// @param state state
- (void)functionViewPlayProgressSlider:(UISlider *)slider state:(PlayProgressSlideState)state {
    /// 设置slider.enabled 是为了优化按下与松手前后的晃动
    CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    CGFloat currentTime = slider.value * totalTime;
    switch (state) {
        case PlayProgressSlideStateBegain: {
            slider.enabled = NO;
            self.isSliding = YES;
        }
            break;
        case PlayProgressSlideStateChanging: {
            [self.functionView updatePlayProgressTime:currentTime totalDuration:totalTime];
        }
            break;
        case PlayProgressSlideStateEnd: {
            [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC)];
            
            slider.enabled = YES;
            self.isSliding = NO;
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *currentItem = self.player.currentItem;
        switch (currentItem.status) {
            case AVPlayerItemStatusUnknown: {
                /// 未知状态，不能播放
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay: {
                /// 准备完毕，可以播放
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                NSUInteger totalDuration = (NSUInteger)CMTimeGetSeconds(self.player.currentItem.asset.duration);
                [self.functionView updatePlayProgressTime:0 totalDuration:totalDuration];
                if (self.autoPlay) [self.player play];
                
            }
                break;
            case AVPlayerItemStatusFailed: {
                /// 加载失败，网络或者服务器出现问题
                NSLog(@"AVPlayerItemStatusFailed");
            }
                break;
            default:
                break;
        }
    }
}



#pragma mark - Helper
/// 获取当前窗口
- (UIWindow *)currentWindow {
    UIWindow *window = nil;
    NSDictionary *tempDt = [[NSBundle mainBundle].infoDictionary objectForKey:@"UIApplicationSceneManifest"];
    if (tempDt == nil) {
        window = [[UIApplication sharedApplication].windows firstObject];
    }
    else if (@available(iOS 13.0,*)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    }
    return window;
}


#pragma mark - Getter
- (LEPlayerFunctionView *)functionView {
    if (!_functionView) {
        _functionView = [[LEPlayerFunctionView alloc]init];
        _functionView.delegate = self;
        _functionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _functionView;
}


- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc]initWithFrame:self.bounds];
        _containView.backgroundColor = UIColor.blackColor;
        _containView.autoresizesSubviews = YES;
        _containView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return _containView;
}



@end
