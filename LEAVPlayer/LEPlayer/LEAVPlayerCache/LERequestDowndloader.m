//
//  RequestDownder.m
//  MSAVPlayer
//
//  Created by Liven on 2020/5/20.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LERequestDowndloader.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "LERequestCacheManager.h"
#import "LERequestFragment.h"

@interface LERequestDowndloader()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableArray *fragments;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, assign) long long  currentOffset;
@end


@implementation LERequestDowndloader

- (void)dealloc {
    NSLog(@"销毁了LERequestDownloader");
}

/// 开始下载
/// @param loadingRequest loadingRequest
+ (instancetype)startDownLoadWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cacheFielManager:(LERequestCacheManager *)cacheManager {
    LERequestDowndloader *downer = [[LERequestDowndloader alloc]initWithLoadingRequest:loadingRequest cacheFielManager:cacheManager];
    return downer;
}


- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cacheFielManager:(LERequestCacheManager *)cacheManager {
    self = [super init];
    if (self) {
        self.loadingRequest = loadingRequest;
        self.cacheManager = cacheManager;
        [self configRequest];
    }
    return self;
}


/// 取消下载
- (void)cancle {
//    NSLog(@"取消正在下载cancle");
    // 1.0 取消本地数据的拼接
    [self.fragments removeAllObjects];
    // 2.0 取消网络请求
    [self.task cancel];
    [self.session invalidateAndCancel];
}


/// 发起请求
- (void)configRequest {
    // 获取请求范围
    AVAssetResourceLoadingDataRequest *dataRequest = self.loadingRequest.dataRequest;
    long long offset = dataRequest.requestedOffset;
    long long length = dataRequest.requestedLength;
    if (dataRequest.currentOffset != 0) {
        offset = dataRequest.currentOffset;
    }
    
    if (dataRequest.requestsAllDataToEndOfResource) {
        length = self.cacheManager.contentInfo.contentLength - offset;
    }
    
    // 根据range与本地缓存对比切分为若干个local和remote
    self.fragments = [[self.cacheManager calculateRangeForRange:NSMakeRange((NSUInteger)offset, (NSUInteger)length)] mutableCopy];
    // 原来的请求
    self.requestURL = self.cacheManager.url;
    // 处理fragments
    [self processFragments];
}


/// 处理请求片段fragments
- (void)processFragments {
    if (self.fragments.count > 0) {
        if (self.cacheManager.contentInfo && self.cacheManager.contentInfo.contentLength>0) {
            self.loadingRequest.contentInformationRequest.contentLength = self.cacheManager.contentInfo.contentLength;
            self.loadingRequest.contentInformationRequest.contentType = self.cacheManager.contentInfo.contentType;
            self.loadingRequest.contentInformationRequest.byteRangeAccessSupported = self.cacheManager.contentInfo.byteRangeAccessSupported;
        }
        
        LERequestFragment *fragment = self.fragments.firstObject;
        if (fragment.modelType == RangeFragmentTypeLocal) {
//            NSLog(@"本地数据的 %@",NSStringFromRange(fragment.range));
            // 本地缓存数据
            NSData *cacheData = [self.cacheManager cacheDataForRange:fragment.range error:nil];
            self.currentOffset = fragment.range.location + fragment.range.length;
            [self.loadingRequest.dataRequest respondWithData:cacheData];
            [self.fragments removeObject:fragment];
            [self processFragments];
        }
        else{
            NSRange fragmentRange = fragment.range;
            long long offset = fragmentRange.location;
            long long endOffset = fragmentRange.location + fragmentRange.length - 1;
            // 发起请求
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
            request.HTTPMethod = @"GET";
            NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld",offset,endOffset];
            [request setValue:range forHTTPHeaderField:@"Range"];
            self.currentOffset = offset;
            [self.fragments removeObject:fragment];
//            NSLog(@"要下载的 %@",range);
            
            // 开始下载
            self.task = [self.session dataTaskWithRequest:request];
            [self.task resume];
        }
        
    }else{
        [self finishLoadingWithError:nil];
    }
}


/// 结束/完成请求
/// @param error error
- (void)finishLoadingWithError:(NSError *)error {
    NSLog(@"结束下载 %@",error);
    if (error) {
        [self.loadingRequest finishLoadingWithError:error];
    }else{
        [self.loadingRequest finishLoading];
    }
    if ([self.delegate respondsToSelector:@selector(requestDownloader:didCompleteWithError:)]) {
        [self.delegate requestDownloader:self didCompleteWithError:error];
    }
}


#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    BOOL byteRangeAccessSupported = NO;
    long long contentLength = 0;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *acceptRange = httpResponse.allHeaderFields[@"Accept-Ranges"];
        byteRangeAccessSupported = [acceptRange isEqualToString:@"bytes"];
        contentLength = [[[httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    NSString *mimeType = [response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    if (contentType && contentLength>0) {
        self.loadingRequest.contentInformationRequest.contentLength = contentLength;
        self.loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
        self.loadingRequest.contentInformationRequest.byteRangeAccessSupported = byteRangeAccessSupported;
    }
    if (self.cacheManager && self.cacheManager.contentInfo.contentLength == 0) {
        self.cacheManager.contentInfo.contentType = CFBridgingRelease(contentType);
        self.cacheManager.contentInfo.contentLength = contentLength;
        self.cacheManager.contentInfo.byteRangeAccessSupported = byteRangeAccessSupported;
    }
    
//    NSLog(@"资源总大小 ： %f M",contentLength/1024.0/1024.0);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.loadingRequest.dataRequest respondWithData:data];
    [self.cacheManager writeData:data range:NSMakeRange((NSUInteger)self.currentOffset,(NSUInteger)data.length) error:nil];
    self.currentOffset += data.length;
//    NSLog(@"已经下载 ： %f M",self.currentOffset/1024.0/1024.0);
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"发生了错误：%@",error.description);
        [self finishLoadingWithError:error];
    }else{
        [self processFragments];
    }
}


#pragma mark - Getter
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

@end
