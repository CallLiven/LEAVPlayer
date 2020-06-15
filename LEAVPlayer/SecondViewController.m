//
//  SecondViewController.m
//  LEAVPlayer
//
//  Created by Liven on 2020/6/4.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "SecondViewController.h"
#import "LEPlayer.h"

@interface SecondViewController ()
@property (nonatomic, strong, readwrite) LEPlayer *player;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.player = [[LEPlayer alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 220)];
    self.player.autoPlay = YES;
    [self.view addSubview:self.player];
    
    self.player.playUrl = @"http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4";
}



@end
