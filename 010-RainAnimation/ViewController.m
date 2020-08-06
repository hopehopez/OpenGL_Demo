//
//  ViewController.m
//  010-RainAnimation
//
//  Created by zsq on 2020/8/6.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CAEmitterLayer * rainLayer;
@property (nonatomic, weak) UIImageView * imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
       [self setupEmitter];
}

- (void)setupUI{
    
    // 背景图片
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    imageView.image = [UIImage imageNamed:@"rain"];
    
    // 下雨按钮
    UIButton * startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:startBtn];
    startBtn.frame = CGRectMake(20, self.view.bounds.size.height - 60, 80, 40);
    startBtn.backgroundColor = [UIColor whiteColor];
    [startBtn setTitle:@"雨停了" forState:UIControlStateNormal];
    [startBtn setTitle:@"下雨" forState:UIControlStateSelected];
    [startBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [startBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    // 雨量按钮
    UIButton * rainBIgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:rainBIgBtn];
    rainBIgBtn.tag = 100;
    rainBIgBtn.frame = CGRectMake(140, self.view.bounds.size.height - 60, 80, 40);
    rainBIgBtn.backgroundColor = [UIColor whiteColor];
    [rainBIgBtn setTitle:@"下大点" forState:UIControlStateNormal];
    [rainBIgBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rainBIgBtn addTarget:self action:@selector(rainButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * rainSmallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:rainSmallBtn];
    rainSmallBtn.tag = 200;
    rainSmallBtn.frame = CGRectMake(240, self.view.bounds.size.height - 60, 80, 40);
    rainSmallBtn.backgroundColor = [UIColor whiteColor];
    [rainSmallBtn setTitle:@"太大了" forState:UIControlStateNormal];
    [rainSmallBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rainSmallBtn addTarget:self action:@selector(rainButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(UIButton *)sender{
    if (!sender.isSelected) {
        sender.selected = !sender.isSelected;
        NSLog(@"下雨了");
        self.rainLayer.birthRate = 0.0f;
    } else {
        sender.selected = !sender.isSelected;
        NSLog(@"开始下雨了");
        self.rainLayer.birthRate = 1.0f;
    }
}

- (void)rainButtonClick:(UIButton *)sender{
    NSInteger rate = 1;
    CGFloat scale = 0.05;
    
    if (sender.tag == 100) {
        NSLog(@"下大了");
        if (self.rainLayer.birthRate < 30) {
            self.rainLayer.birthRate += rate;
            self.rainLayer.scale += scale;
        }
    } else {
        NSLog(@"变小了");
        if (self.rainLayer.birthRate > 1) {
            self.rainLayer.birthRate -= rate;
            self.rainLayer.scale -= scale;
        }
    }
}

- (void)setupEmitter{
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    [self.imageView.layer addSublayer:rainLayer];
    self.rainLayer = rainLayer;
    
    rainLayer.emitterShape = kCAEmitterLayerLine;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.bounds.size;
    rainLayer.emitterPosition = CGPointMake(self.view.bounds.size.width * 0.5, -10);
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (id)[UIImage imageNamed:@"rain_white"].CGImage;
    cell.birthRate = 25;
    cell.lifetime = 20;
    //speed粒子速度.图层的速率。用于将父时间缩放为本地时间，例如，如果速率是2，则本地时间的进度是父时间的两倍。默认值为1。
    cell.speed = 10.f;
    cell.velocity = 10.f;
    cell.velocityRange = 10.f;
    cell.yAcceleration = 500.f;
    cell.xAcceleration = 10.f;
    cell.scale = 0.2;
    cell.scaleRange = .0f;
    
    rainLayer.emitterCells = @[cell];
}

@end
