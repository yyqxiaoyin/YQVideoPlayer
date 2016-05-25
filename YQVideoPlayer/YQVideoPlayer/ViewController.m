//
//  ViewController.m
//  YQVideoPlayer
//
//  Created by Mopon on 16/5/25.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "ViewController.h"
#import "YQVideoPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YQVideoPlayer *player = [[YQVideoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200) videoURL:@"http://mopon-vr.b0.upaiyun.com/2016/05/25/upload_R0010100_er.mp4"];
    [self.view addSubview:player];
    
    [player play];
    
}


@end
