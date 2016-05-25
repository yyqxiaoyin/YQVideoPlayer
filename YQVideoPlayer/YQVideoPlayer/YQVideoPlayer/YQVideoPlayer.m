//
//  YQVideoPlayer.m
//  YQVideoPlayer
//
//  Created by Mopon on 16/5/25.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQVideoPlayer.h"

@interface YQVideoPlayer ()

@property (nonatomic ,strong)AVPlayer *player;

@property (nonatomic ,strong)AVPlayerItem *playerItem;

@property (nonatomic ,strong)AVPlayerLayer *playerLayer;

@property (nonatomic ,strong)NSString *video_url;

@end

@implementation YQVideoPlayer

-(instancetype)initWithFrame:(CGRect)frame videoURL:(NSString *)video_url{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.video_url = video_url;
        
        [self setPlayer];
    }
    
    return self;
}


#pragma mark - 初始化播放器
-(void)setPlayer{
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.video_url]];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerLayer = (AVPlayerLayer *)self.layer;
    
    
    [self.playerLayer setPlayer:self.player];
}

+(Class)layerClass{
    
    return [AVPlayerLayer class];
}

-(void)play{
    
    [self.player play];
}



@end
