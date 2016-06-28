//
//  YQVideoPlayer.h
//  123
//
//  Created by 尹永奇 on 16/6/27.
//  Copyright © 2016年 尹永奇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YQPlayerBottomToolView.h"

@interface YQVideoPlayer : UIView

+(YQVideoPlayer *)playerWithURLString:(NSString *)urlString frame:(CGRect)frame;

@property (nonatomic ,strong)YQPlayerBottomToolView *bottomToolView;//底部工具条

/**
 *  开始播放
 */
-(void)play;

/**
 *  释放播放器
 */
-(void)releasePlayer;

-(void)smallScreen;

/**
 *  旋转屏幕(返回是否需要隐藏状态栏。看需要)
 */
-(void)rotationScreen:(UIInterfaceOrientation)interfaceOrientation;

@end
