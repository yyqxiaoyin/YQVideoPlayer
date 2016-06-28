//
//  ViewController.m
//  YQVideoPlayerDemo
//
//  Created by Mopon on 16/6/28.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "ViewController.h"
#import "YQVideoPlayer.h"
#import <Masonry.h>

@interface ViewController ()

@property (nonatomic ,strong)YQVideoPlayer *player;

@property (nonatomic ,assign)BOOL statusHiden;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    self.player = [YQVideoPlayer playerWithURLString:@"http://218.6.111.148/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4?wshc_tag=0&wsts_tag=576a258a&wsid_tag=e79b1da&wsiphost=ipdbm"
                                               frame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width*9/16)
                                              ];
    
    [self.view addSubview:self.player];
    
    
}

-(void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (self.player==nil||self.player.superview==nil){
        return;
    }
   [self.player rotationScreen:interfaceOrientation];
}




@end
