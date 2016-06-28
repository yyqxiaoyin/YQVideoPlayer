//
//  YQPlayerBottomToolView.m
//  test
//
//  Created by 尹永奇 on 16/6/27.
//  Copyright © 2016年 尹永奇. All rights reserved.
//

#import "YQPlayerBottomToolView.h"
#import <Masonry.h>

#define default_margin 5

@interface YQPlayerBottomToolView ()

@property (nonatomic ,copy)PlayBtnClick playBtnHandle;

@property (nonatomic ,copy)FullScreenBtnClick fullScreenBtnHandle;

@property (nonatomic ,copy)ProgressViewTap progressViewTap;

@property (nonatomic ,copy)DragSilderBlock dragSilderBlock;

@end

@implementation YQPlayerBottomToolView

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.7;
        [self setupViews];
    }
    return self;
}

-(void)setupViews{

    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"YQVideoPlayer.bundle/play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"YQVideoPlayer.bundle/pause"] forState:UIControlStateSelected];
    [self addSubview:self.playBtn];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"YQVideoPlayer.bundle/movie_fullscreen"] forState:UIControlStateNormal];
    [self addSubview:self.fullScreenBtn];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentTimeLabel = [UILabel new];
    self.currentTimeLabel.text = self.currentTimeString == nil? @"00:00:00" :self.currentTimeString;
    self.currentTimeLabel.font = [UIFont systemFontOfSize:13];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.currentTimeLabel];
    
    self.totalTimeLabel = [UILabel new];
    self.totalTimeLabel.text = self.totalTimeString ==nil?@"00:00:00":self.totalTimeString;
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.totalTimeLabel];
    
    self.progressView  = [[UIProgressView alloc]init];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.progress = self.bufferProgress;
    self.progressView.userInteractionEnabled = YES;

    [self addSubview:self.progressView];
    
    self.videoSlider = [[UISlider alloc]init];
    [self addSubview:self.videoSlider];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"YQVideoPlayer.bundle/slider"] forState:UIControlStateNormal];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"YQVideoPlayer.bundle/slider"] forState:UIControlStateHighlighted];
    self.videoSlider.maximumTrackTintColor = [UIColor clearColor];
    self.videoSlider.minimumTrackTintColor = [UIColor clearColor];
    self.videoSlider.value = self.progress;
    [self.videoSlider addTarget:self action:@selector(didDragSlider) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressTapAct:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.videoSlider addGestureRecognizer:tap];
    
    [self layoutViews];
}

-(void)layoutViews{
    
    __weak typeof(self)weakSelf = self;
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.left.mas_equalTo(weakSelf.mas_left).offset(default_margin);
        make.height.mas_equalTo(weakSelf.mas_height).multipliedBy(0.8);
        make.width.mas_equalTo(weakSelf.playBtn.mas_height).multipliedBy(1);

    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.playBtn.mas_right).offset(default_margin);
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.right.mas_equalTo(weakSelf.videoSlider.mas_left).offset(-default_margin);
        make.height.mas_equalTo(weakSelf.mas_height).multipliedBy(0.8);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(weakSelf.currentTimeLabel.mas_right).offset(default_margin);
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.right.mas_equalTo(weakSelf.totalTimeLabel.mas_left).offset(-default_margin);
        make.height.mas_equalTo(weakSelf.mas_height).multipliedBy(0.8);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(weakSelf.videoSlider.mas_right).offset(default_margin);
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.right.mas_equalTo(weakSelf.fullScreenBtn.mas_left).offset(-default_margin);
        make.height.mas_equalTo(weakSelf.mas_height).multipliedBy(0.8);

    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.height.mas_equalTo(weakSelf.mas_height).multipliedBy(0.8);
        make.width.mas_equalTo(weakSelf.playBtn.mas_height).multipliedBy(1);
        make.right.mas_equalTo(weakSelf.mas_right).offset(-default_margin);
        
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.videoSlider.mas_left);
        make.centerY.mas_equalTo(weakSelf.videoSlider.mas_centerY);
        make.right.mas_equalTo(weakSelf.videoSlider.mas_right);
        make.height.mas_equalTo(@5);
    }];

}

#pragma mark - 拖动滑块
-(void)didDragSlider{
    if (self.dragSilderBlock){
        self.dragSilderBlock(self.videoSlider.value);
    }
}

-(void)progressTapAct:(UITapGestureRecognizer *)tap{
    if (self.progressViewTap) {
        CGPoint location = [tap locationInView:self.videoSlider];
        float value = location.x/self.videoSlider.bounds.size.width * self.videoSlider.maximumValue;
        self.progressViewTap(value);
    }
}


-(void)playBtnClick:(UIButton *)sender{
    if (self.playBtnHandle) {
        sender.selected = !sender.selected;
        self.playBtnHandle(sender);
    }
}

-(void)fullScreenBtnClick:(UIButton *)sender{
    if (self.fullScreenBtnHandle) {
        self.fullScreenBtnHandle(sender);
    }
}

-(void)didClickPlayBtn:(PlayBtnClick)playBtnHandle{

    self.playBtnHandle = [playBtnHandle copy];

}

-(void)didDragSilder:(DragSilderBlock)dragSilderHandle{
    self.dragSilderBlock = [dragSilderHandle copy];
}

-(void)didClickFullScreenBtn:(FullScreenBtnClick)fullScreenBtnHandle{

    self.fullScreenBtnHandle = [fullScreenBtnHandle copy];
}

-(void)didClickProgressView:(ProgressViewTap)progressViewTap{
    
    self.progressViewTap = [progressViewTap copy];
}

-(void)setTotalTimeString:(NSString *)totalTimeString{

    _totalTimeString = totalTimeString;
    self.totalTimeLabel.text = _totalTimeString;
}

-(void)setMaximumValue:(CGFloat )maximumValue{
    _maximumValue = maximumValue;
    self.videoSlider.maximumValue = _maximumValue;
}

-(void)setCurrentTimeString:(NSString *)currentTimeString{

    _currentTimeString = currentTimeString;
    self.currentTimeLabel.text = currentTimeString;
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    _videoSlider.value = _progress;
}

-(void)setBufferProgress:(CGFloat)bufferProgress{
    
    _bufferProgress = bufferProgress;
    _progressView.progress = _bufferProgress;
}

-(void)dealloc{
    self.playBtnHandle = nil;
    self.fullScreenBtnHandle = nil;
    self.progressViewTap = nil;
    self.dragSilderBlock = nil;
}

@end
