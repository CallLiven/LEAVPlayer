//
//  LEPlayer.h
//  LEAVPlayer
//
//  Created by Liven on 2020/6/2.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface LEPlayer : UIView
/* 是否自动播放 默认是 YES**/
@property (nonatomic, assign, readwrite) BOOL autoPlay;
/* 设置播放资源url **/
@property (nonatomic, copy, readwrite) NSString *playUrl;


/// 播放
- (void)play;


/// 暂停
- (void)pause;


/// 销毁播放器
- (void)destroyPlayer;

@end

NS_ASSUME_NONNULL_END
