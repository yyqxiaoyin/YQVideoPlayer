//
//  YQVideoPlayer.m
//  123
//
//  Created by 尹永奇 on 16/6/27.
//  Copyright © 2016年 尹永奇. All rights reserved.
//

#import "YQVideoPlayer.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

@interface YQVideoPlayer ()

#pragma mark - 播放器需要的
@property (nonatomic ,strong)AVPlayer *player;
@property (nonatomic ,strong)AVPlayerItem *playerItem;
@property (nonatomic ,strong)AVPlayerLayer *playerLayer;
@property (nonatomic ,strong)NSString *video_url;//视频url
@property (nonatomic ,assign)CGFloat totalTime;//总时间

@property (nonatomic ,assign)BOOL isPlaying;//是否正在播放
@property (nonatomic ,assign)CGRect oldFrame;//旧frame
@property (nonatomic ,assign)BOOL isFullScreen;//是否正在全屏

@property (nonatomic ,strong)UIActivityIndicatorView *activityIndicator;//加载中的菊花

@end

@implementation YQVideoPlayer

+(YQVideoPlayer *)playerWithURLString:(NSString *)urlString frame:(CGRect)frame inView:(UIView *)view{
    YQVideoPlayer *player = [[YQVideoPlayer alloc]initWithFrame:frame];
    player.userInteractionEnabled = YES;
    player.backgroundColor = [UIColor blackColor];
    player.video_url = urlString;
    player.oldFrame = frame;
    [player setPlayer];
    
    return player;
}

-(void)play{
    
    [self.player play];
}

+(Class)layerClass{
    
    return [AVPlayerLayer class];
}

-(void)setPlayer{
    
    __weak typeof(self)weakSelf = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.video_url]];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerLayer = (AVPlayerLayer *)self.layer;
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.player.currentItem addObserver:self forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(moviePlayDidEnd:)
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:self.playerLayer.player.currentItem];
    
    [self.playerLayer setPlayer:self.player];
    
    self.bottomToolView = [[YQPlayerBottomToolView alloc]init];
    [self addSubview:self.bottomToolView];
    self.bottomToolView.hidden = YES;//先隐藏。等视频加载好了在显示出来
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.and.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width,self.frame.size.height/6));
        
    }];
    
    [self.bottomToolView didClickPlayBtn:^(UIButton *playBtn) {
        
        NSLog(@"点击了播放按钮");
        if (weakSelf.isPlaying) {
            [weakSelf.player pause];
            weakSelf.isPlaying = NO;
        }else{
            [weakSelf.player play];
            weakSelf.isPlaying = YES;
        }
    }];
    
    [self.bottomToolView didClickProgressView:^(CGFloat value) {
       
        [weakSelf seekToTimeValue:value];
        
    }];
    [self.bottomToolView didDragSilder:^(CGFloat value) {
       
        [weakSelf seekToTimeValue:value];
    }];
    
    [self.bottomToolView didClickFullScreenBtn:^(UIButton *fullScreenBtn) {
        if (weakSelf.isFullScreen) {
            [weakSelf smallScreen];
        }else{
            [weakSelf fullScreen:M_PI/2];
        }
    }];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator startAnimating];
    [self addSubview:self.activityIndicator];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}


#pragma mark -----------------------------
#pragma mark - 视频播放相关
#pragma mark -----------------------------
#pragma mark - 视频播放完毕
-(void)moviePlayDidEnd:(NSNotification *)noti{
    
    NSLog(@"播放完毕");
    
}

#pragma mark - 处理视频加载完毕，缓冲处理还有网络不好的情况
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"status"]) {//获取加载视频的状态。
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        switch (playerItem.status) {
                
            case AVPlayerItemStatusReadyToPlay:
                [self readyToPlay:playerItem];
                break;
                
            case AVPlayerItemStatusFailed:
                [self failedToPlay:playerItem];
                break;
            case AVPlayerItemStatusUnknown:
                [self unknownErrorToPlay:playerItem];
                break;
                
            default:
                break;
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){ //当缓冲进度有变化的时候
        [self updateAvailableDuration];
    }
}

#pragma mark - 未知错误
-(void)unknownErrorToPlay:(AVPlayerItem *)playerItem{
    
    NSLog(@"未知错误");
}

#pragma mark - 播放失败
-(void)failedToPlay:(AVPlayerItem *)playerItem{//加载视频失败
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    UILabel *label = [UILabel new];
    label.text = @"加载视频失败,请检查网络设置";
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo([label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)]);
        make.centerX.and.centerY.mas_equalTo(self);
    }];
    
    NSLog(@"播放失败");
}

#pragma mark - 准备好播放
-(void)readyToPlay:(AVPlayerItem *)playerItem{
    
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    self.bottomToolView.hidden = NO;
    //计算视频总时间
    CMTime totalTime = playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    self.totalTime = totalMovieDuration;
    [self.bottomToolView setTotalTimeString:[self secondToTime:totalMovieDuration]];
    [self.bottomToolView setMaximumValue:totalMovieDuration];
    
    //计算当前的时间
    __weak typeof(self)weakself = self;
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        //获取当前时间
        CMTime currentTime =weakself.player.currentItem.currentTime;
        
        CGFloat currentPlayTime = (CGFloat)currentTime.value/currentTime.timescale;
        
        [weakself.bottomToolView setCurrentTimeString:[weakself secondToTime:currentPlayTime]];
        [weakself.bottomToolView setProgress:currentPlayTime];

    }];
}

#pragma mark - 跳转到某个进度
-(void)seekToTimeValue:(CGFloat)value{
    
    [self.player pause];
    //第一个参数代表第几秒 第二个参数代表每秒的帧数
    CMTime seekTime = CMTimeMakeWithSeconds(value, (int32_t)50000);
    __weak typeof(self)weakSelf = self;
    [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
        
        weakSelf.isPlaying ==YES? [weakSelf.player play] :[weakSelf.player pause];
        
    }];
}

#pragma mark - 更新缓冲时间
-(void)updateAvailableDuration{
    NSArray * loadedTimeRanges = self.playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    [self.bottomToolView setBufferProgress:result/self.totalTime];
}

//秒转化为时间
- (NSString *)secondToTime :(int)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

-(void)fullScreen:(CGFloat )rotation{
    CGRect newFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        CATransform3D transform = CATransform3DMakeRotation(rotation, 0, 0, 1.0);
        self.layer.transform = transform;
        self.frame = newFrame;
        
        [self.bottomToolView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.bottom.mas_equalTo(self.mas_bottom).offset([UIScreen mainScreen].bounds.size.width - [UIScreen mainScreen].bounds.size.height);
            make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.height,self.frame.size.width/6));
        }];
    }];
    
    self.isFullScreen = YES;
}

-(void)rotationScreen:(UIInterfaceOrientation)interfaceOrientation{

    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            [self fullScreen:-M_PI/2];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self fullScreen:M_PI/2];
            break;
        case UIInterfaceOrientationPortrait:
            [self smallScreen];
            break;
        default:
            break;
    }
}

-(void)smallScreen{
    if (_isFullScreen) {
        [UIView animateWithDuration:0.3 animations:^{
            self.layer.transform = CATransform3DIdentity;
            self.frame = self.oldFrame;
            [self.bottomToolView mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.and.bottom.mas_equalTo(self);
                make.size.mas_equalTo(CGSizeMake(self.frame.size.width,self.oldFrame.size.height/6));
            }];
        }];
        _isFullScreen = NO;
    }
}


-(void)singleTap{
    if (self.bottomToolView.hidden) {
        [self showBottomToolView:YES];
    }else{
        [self hideBottomToolView:YES];
    }
}

#pragma mark - 隐藏底部工具栏
-(void)hideBottomToolView:(BOOL)animate{

    [UIView animateWithDuration:0.3 animations:^{
        self.bottomToolView.alpha = 0;
    } completion:^(BOOL finished) {
        self.bottomToolView.hidden = YES;
        
    }];
}

#pragma mark - 显示底部工具栏
-(void)showBottomToolView:(BOOL)animate{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomToolView.hidden = NO;
        self.bottomToolView.alpha = 0.7;
    } completion:^(BOOL finished) {
    }];
}

-(void)releasePlayer{
    [self.bottomToolView removeFromSuperview];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerLayer.player.currentItem];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playerItem = nil;
    self.bottomToolView = nil;
    self.activityIndicator = nil;
}

@end
