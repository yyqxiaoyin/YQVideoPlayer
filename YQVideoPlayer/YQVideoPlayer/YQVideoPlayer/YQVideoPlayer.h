//
//  YQVideoPlayer.h
//  YQVideoPlayer
//
//  Created by Mopon on 16/5/25.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YQVideoPlayer : UIView

/**
 *  初始化方法
 *
 *  @param frame     player的frame
 *  @param video_url 视频连接
 */
-(instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)video_url;

/**
 *  开始播放
 */
-(void)play;

@end
