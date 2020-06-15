//
//  RequestDownder.h
//  MSAVPlayer
//
//  Created by Liven on 2020/5/20.
//  Copyright © 2020 Liven. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 规则：一个LoadingRequest对应一个下载器Downloader
 
 职能：响应LoadingReqeust中range对应的数据（local或者remote）
 
 */

@import AVFoundation;
@class LERequestDowndloader;
@class LERequestCacheManager;
@protocol LERequestDownloaderDelegate;

@interface LERequestDowndloader : NSObject
@property (nonatomic,  weak ) id<LERequestDownloaderDelegate> delegate;
@property (nonatomic, strong) AVAssetResourceLoadingRequest *loadingRequest;
@property (nonatomic, strong) LERequestCacheManager *cacheManager;

/// 开始下载
/// @param loadingRequest loadingRequest
+ (instancetype)startDownLoadWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cacheFielManager:(LERequestCacheManager *)cacheManager;


/// 取消下载
- (void)cancle;

@end




@protocol LERequestDownloaderDelegate <NSObject>
@optional
/// 响应数据完成
/// @param downloader downloader
/// @param error error
- (void)requestDownloader:(LERequestDowndloader *)downloader didCompleteWithError:(NSError *)error;

@end
