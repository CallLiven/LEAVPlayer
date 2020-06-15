//
//  LEPlayerConfig.h
//  LEAVPlayer
//
//  Created by Liven on 2020/6/3.
//  Copyright © 2020 Liven. All rights reserved.
//

#ifndef LEPlayerConfig_h
#define LEPlayerConfig_h

#define LEImage(x)  [UIImage imageNamed:x]
#define LEFont(x)   [UIFont systemFontOfSize:x]
#define LEColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define LEScreenW [UIScreen mainScreen].bounds.size.width
#define LEScreenH [UIScreen mainScreen].bounds.size.height

#define LERotationW MIN(LEScreenW,LEScreenH)
#define LERotationH MAX(LEScreenW,LEScreenH)

/// 时间字体
#define LETimeFont LEFont(10)
#define LETimeTextColor [UIColor whiteColor]

/// 底部工具栏高度
#define kBottomBarHeight 49
/// 顶部工具栏高度
#define kNavigationBarHeight 49



typedef NS_ENUM(NSUInteger,PlayProgressSlideState) {
    PlayProgressSlideStateBegain = 0, // 开始滑动
    PlayProgressSlideStateChanging, // 滑动中
    PlayProgressSlideStateEnd,  // 滑动结束
};

#endif /* LEPlayerConfig_h */
