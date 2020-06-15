//
//  ViewController.m
//  LEAVPlayerCache
//
//  Created by Liven on 2020/6/1.
//  Copyright © 2020 Liven. All rights reserved.
//

/**
    1. NSURLSession下载视频文件   -- OK
        不能使用downloadTask，因为需要一边下载一边获取数据传给播放器播放
        使用GET方式请求
    2.将下载的数据填充到播放器中 -- OK
    3.分片下载处理    --OK
    4.数据缓存  ---OK
    5.处理不能边播边下载的mp4文件(moov文件在mdat文件之后的视频文件)
    6.avplayer在tableView视频列表顺畅的问题
 */

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LEResourceLoaderManager.h"
#import "LEPlayer.h"


@interface ViewController ()
@property (nonatomic, strong) LEResourceLoaderManager *loaderManager;
@property (nonatomic, strong, readwrite) LEPlayer *player;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.player = [[LEPlayer alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220)];
    self.player.autoPlay = YES;
    [self.view addSubview:self.player];
    
    self.player.playUrl = @"http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4";
}


@end
