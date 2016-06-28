//
//  YQPlayerBottomToolView.h
//  test
//
//  Created by 尹永奇 on 16/6/27.
//  Copyright © 2016年 尹永奇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PlayBtnClick)(UIButton *playBtn);
typedef void(^FullScreenBtnClick)(UIButton *fullScreenBtn);
typedef void(^ProgressViewTap)(CGFloat value);
typedef void(^DragSilderBlock)(CGFloat value);


@interface YQPlayerBottomToolView : UIView

-(void)didClickPlayBtn:(PlayBtnClick)playBtnHandle;

-(void)didClickFullScreenBtn:(FullScreenBtnClick)fullScreenBtnHandle;

-(void)didClickProgressView:(ProgressViewTap)progressViewTap;

-(void)didDragSilder:(DragSilderBlock)dragSilderHandle;

#pragma mark - 控件相关的值

@property (nonatomic ,strong) NSString *currentTimeString;//当前时间字符串

@property (nonatomic ,strong) NSString *totalTimeString;//总时间字符串

@property (nonatomic ,assign) CGFloat maximumValue;//进度条的总值

@property (nonatomic, assign) CGFloat progress;//视频播放进度

@property (nonatomic, assign) CGFloat bufferProgress;//缓冲进度

#pragma mark - 控件
@property (nonatomic ,strong)UIButton *playBtn;//播放按钮
@property (nonatomic ,strong)UIButton *fullScreenBtn;//全屏按钮
@property (nonatomic ,strong)UILabel *currentTimeLabel;//当前时间
@property (nonatomic ,strong)UILabel *totalTimeLabel;//总时间
@property (nonatomic ,strong)UISlider *videoSlider;//进度条
@property (nonatomic ,strong)UIProgressView *progressView;//缓冲进度条

@end
