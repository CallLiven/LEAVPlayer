//
//  ResourceLoaderManager.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/28.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 职能：
    1. 根据URL创建AVPlayerItem ，并设置resourceLoader的delegate
 */

@import AVFoundation;
@protocol LEResourceLoaderManagerDelegate;

@interface LEResourceLoaderManager : NSObject
@property (nonatomic, weak) id<LEResourceLoaderManagerDelegate> delegate;

- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end



@protocol LEResourceLoaderManagerDelegate <NSObject>
/// 结束响应数据
/// @param loaderManager loaderManager
/// @param error error
- (void)resourceLoaderManager:(LEResourceLoaderManager *)loaderManager didCompleteWithError:(NSError *)error;


/**
 还需要补充
 返回资源信息：比如总时长、格式
 返回缓存进度
 加载中
 播放中
 */
@end

NS_ASSUME_NONNULL_END
