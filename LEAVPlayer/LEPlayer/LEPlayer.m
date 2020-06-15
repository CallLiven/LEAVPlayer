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
#import "LEPlayerFunctionView.h"

@interface LEPlayer()<LEPlayerFunctionDelegate>
/* AVPlayer **/
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/* 边播边缓存 **/
@property (nonatomic, strong) LEResourceLoaderManager *loaderManager;
/* 功能视图 **/
@property (nonatomic, strong) LEPlayerFunctionView *functionView;
/* 全屏容器 **/
@property (nonatomic, strong) UIView *fullScreenContainView;

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
    /// 初始化缓存模块
    self.loaderManager = [[LEResourceLoaderManager alloc]init];
    /// 初始化player
    self.player = [[AVPlayer alloc]init];
    /// 关键参数：能尽快的播放
    if (@available(iOS 10.0, *)) self.player.automaticallyWaitsToMinimizeStalling = NO;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    
    /// 功能视图
    [self addSubview:self.functionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    /// 全屏方案一
    [self le_layoutFullScreenForFirstCase];
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
    [self changeScreenOrientationIsFullScreen:isFull];
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


#pragma mark - 全屏/缩小(方案一)
/// 方案一
/// 类似于Bilibili的方式，使用前提必须打开横屏的设置，将Device Orientation中的LandscapeLeft和LandscapeRight勾上
/// 好处：全屏的时候可以显示状态栏、并且是整个界面横屏，所以推送什么消息的都是横屏的
/// 坏处：（1）在切换的时候底部会一部分黑色，用户体验稍差了一点
///      （2）其他界面不支持横屏的，需要关闭横屏功能
///       (3)  在旋屏的锁打开的状态，并且是在手机横屏的时候，打开LEPlayer父视图的VC，容易导致self.bounds的宽度是屏幕横屏的宽度，所以在变成竖屏的时候播放器的宽度还是横屏的宽度(暂时没有想到解决的方案)
/// @param isFull isFull
- (void)changeScreenOrientationIsFullScreen:(BOOL)isFull {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationUnknown) {
        [self rotateToOritation:UIDeviceOrientationLandscapeLeft];
    }
    else{
        [self rotateToOritation:UIDeviceOrientationPortrait];
    }
}


- (void)rotateToOritation:(UIDeviceOrientation)orientation {
    NSLog(@"要修改的状态 %ld",orientation);
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        /// 获取UIDevice对象的setOrientation方法，NSMethodSignature 记录中方法中返回的形象以及参数等等
        NSMethodSignature *methodSignature = [[UIDevice currentDevice] methodSignatureForSelector:@selector(setOrientation:)];
        /// NSInvocation: 用来包装方法和对应的对象，可以存储方法的名称、对应的对象、对应的参数
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        /// 设置invocatoin的执行对象，注意必须与NSMethodSingature获取的方法一致
        [invocation setTarget:[UIDevice currentDevice]];
        /// 设置invocation的方法，注意必须与NSMethodSingature获取的方法一致
        [invocation setSelector:@selector(setOrientation:)];
        /// 设置参数
        /// 第一个参数：参数值的地址
        /// 第二个参数：指定参数是方法的第几个参数传值
        /// 注意：设置参数的索引不能从0开始，只能从2开始，因为0被self占用，1被_cmd占用
        [invocation setArgument:&orientation atIndex:2];
        /// 调用NSInvocation对象的invoke方法
        [invocation invoke];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

/// 方案一
- (void)le_layoutFullScreenForFirstCase {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSLog(@"当前的状态 %ld",orientation);
    if (orientation == UIDeviceOrientationPortrait) {
        [self le_layoutSubViewWithIsFullScreen:NO];
    }
    else{
        [self le_layoutSubViewWithIsFullScreen:YES];
    }
}

/// 方案一
/// 切换全屏与缩小的布局
/// @param isFull isFull
- (void)le_layoutSubViewWithIsFullScreen:(BOOL)isFull {
    if (isFull) {
        [self.functionView removeFromSuperview];
        [self.playerLayer removeFromSuperlayer];
        [self.fullScreenContainView.layer addSublayer:self.playerLayer];
        [self.fullScreenContainView addSubview:self.functionView];
        self.functionView.frame = self.fullScreenContainView.bounds;
        self.playerLayer.frame = self.fullScreenContainView.bounds;
        
        self.functionView.bottomBar.fullScreenBtn.selected = YES;
    }
    else{
        [self.functionView removeFromSuperview];
        [self.playerLayer removeFromSuperlayer];
        [self.layer addSublayer:self.playerLayer];
        [self addSubview:self.functionView];
        
        self.functionView.frame = self.bounds;
        self.playerLayer.frame = self.bounds;
        [self.fullScreenContainView removeFromSuperview];
        self.fullScreenContainView = nil;
        
        self.functionView.bottomBar.fullScreenBtn.selected = NO;
    }
}




#pragma mark - 全屏/缩小(方案二)




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
        window = [UIApplication sharedApplication].keyWindow;
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
    }
    return _functionView;
}


- (UIView *)fullScreenContainView {
    if (!_fullScreenContainView) {
        _fullScreenContainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, LEScreenW, LEScreenH)];
        _fullScreenContainView.backgroundColor = [UIColor blackColor];
        UIWindow *window = [self currentWindow];
        [window addSubview:_fullScreenContainView];
    }
    return _fullScreenContainView;
}


@end
