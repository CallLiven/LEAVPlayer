//
//  LEAVPlayerView.m
//  LEAVPlayer
//
//  Created by Liven on 2020/6/16.
//  Copyright © 2020 Liven. All rights reserved.
//

#import "LEAVPlayerView.h"

@import AVFoundation;

@implementation LEAVPlayerView

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

@end
