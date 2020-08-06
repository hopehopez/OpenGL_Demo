//
//  ViewController.m
//  009_BallAnimation
//
//  Created by zsq on 2020/8/6.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CAEmitterLayer * colorBallLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupEmitter];
    
}

- (void)setupEmitter{
    /*
    emitterShape: 形状:
    1. 点;kCAEmitterLayerPoint .
    2. 线;kCAEmitterLayerLine
    3. 矩形框: kCAEmitterLayerRectangle
    4. 立体矩形框: kCAEmitterLayerCuboid
    5. 圆形: kCAEmitterLayerCircle
    6. 立体圆形: kCAEmitterLayerSphere

    emitterMode:
    kCAEmitterLayerPoints
    kCAEmitterLayerOutline
    kCAEmitterLayerSurface
    kCAEmitterLayerVolume
    
    */
    
    CAEmitterLayer *colorBallLayer = [CAEmitterLayer layer];
    [self.view.layer addSublayer:colorBallLayer];
    self.colorBallLayer = colorBallLayer;
    
    colorBallLayer.emitterSize = self.view.frame.size;
    colorBallLayer.emitterShape = kCAEmitterLayerCircle;
    colorBallLayer.emitterMode = kCAEmitterLayerPoints;
    colorBallLayer.emitterPosition = CGPointMake(self.view.layer.bounds.size.width/2, 0.0f);
    
    CAEmitterCell *colorBarCell = [CAEmitterCell emitterCell];
    colorBarCell.name = @"colorBarCell";
    //每秒产生多少个
    colorBarCell.birthRate = 20.0f;
    //生命周期
    colorBarCell.lifetime = 30.0f;
    //初速度
    colorBarCell.velocity = 40.0f;
    //最大速度
    colorBarCell.velocityRange = 100.0f;
    //加速度
    colorBarCell.yAcceleration = 1.0f;
    //
    colorBarCell.emissionLongitude = M_PI_4;
    colorBarCell.emissionRange = M_PI_2;
    
    //缩放
    colorBarCell.scale = 0.2;
    colorBarCell.scaleRange = 0.1;
    colorBarCell.scaleSpeed = 0.02;
    
    colorBarCell.contents = (id)[[UIImage imageNamed:@"circle_white"]CGImage];
    colorBarCell.color = [[UIColor colorWithRed:0.5 green:0.0f blue:0.5f alpha:1.0f] CGColor];
    //随机颜色 透明度
    colorBarCell.redRange = 1.0f;
    colorBarCell.greenRange = 1.0f;
    colorBarCell.alphaRange = 0.8f;
    colorBarCell.blueSpeed = 1.0f;
    colorBarCell.alphaSpeed = -0.1f;
    
    colorBallLayer.emitterCells = @[colorBarCell];

    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self locationFromTouchEvent:event];
    [self setBallInPsition:p];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint p = [self locationFromTouchEvent:event];
    [self setBallInPsition:p];
}

/**
 * 获取手指所在点
 */
- (CGPoint)locationFromTouchEvent:(UIEvent *)event{
    UITouch * touch = [[event allTouches] anyObject];
    return [touch locationInView:self.view];
}
/**
 * 移动发射源到某个点上
 */
- (void)setBallInPsition:(CGPoint)position{
    
 
    self.colorBallLayer.emitterPosition = position;
  
}

@end
