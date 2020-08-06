//
//  ViewController.m
//  008_ZongziAnimation
//
//  Created by zsq on 2020/8/6.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self rainZongzi];
//    [self rainHongBao];
//    [self rainJinBi];
    [self allRain];
}

- (void)rainZongzi{
    //1.设置CAEmitterLayer
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    
    //2.在背景图上添加粒子图层
    [self.view.layer addSublayer:rainLayer];
    
    //3.发射形状--线性
    rainLayer.emitterShape = kCAEmitterLayerLine;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.frame.size;
    rainLayer.emitterPosition = CGPointMake(self.view.bounds.size.width/2, -10);
    
    //4.配置cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"zongzi2.jpg"].CGImage);
    cell.birthRate = 1;
    cell.lifetime = 30;
    cell.speed = 2;
    cell.velocity = 10.0f;
    cell.velocityRange = 10.0f;
    cell.yAcceleration = 60;
    cell.scale = 0.05;
    cell.scaleRange = 0.05f;
    
    rainLayer.emitterCells = @[cell];
    
}

- (void)rainHongBao{
    //1.设置CAEmitterLayer
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    rainLayer.backgroundColor = [UIColor clearColor].CGColor;
    //2.在背景图上添加粒子图层
    [self.view.layer addSublayer:rainLayer];
    
    //3.发射形状--线性
    rainLayer.emitterShape = kCAEmitterLayerLine;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.frame.size;
    rainLayer.emitterPosition = CGPointMake(self.view.bounds.size.width/2, -10);
    
    //4.配置cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"hongbao.png"].CGImage);
    cell.birthRate = 1;
    cell.lifetime = 30;
    cell.speed = 2;
    cell.velocity = 10.0f;
    cell.velocityRange = 10.0f;
    cell.yAcceleration = 60;
    cell.scale = 0.05;
    cell.scaleRange = 0.05f;
    
    rainLayer.emitterCells = @[cell];
    
}

- (void)rainJinBi{
    //1.设置CAEmitterLayer
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    rainLayer.backgroundColor = [UIColor clearColor].CGColor;
    //2.在背景图上添加粒子图层
    [self.view.layer addSublayer:rainLayer];
    
    //3.发射形状--线性
    rainLayer.emitterShape = kCAEmitterLayerSphere;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.frame.size;
    rainLayer.emitterPosition = CGPointMake(self.view.bounds.size.width/2, -10);
    
    //4.配置cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"jinbi.png"].CGImage);
    cell.birthRate = 1;
    cell.lifetime = 30;
    cell.speed = 2;
    cell.velocity = 10.0f;
    cell.velocityRange = 10.0f;
    cell.yAcceleration = 60;
    cell.scale = 0.05;
    cell.scaleRange = 0.05f;
    
    rainLayer.emitterCells = @[cell];
    
}

- (void)allRain{
    //1.设置CAEmitterLayer
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    rainLayer.backgroundColor = [UIColor clearColor].CGColor;
    //2.在背景图上添加粒子图层
    [self.view.layer addSublayer:rainLayer];
    
    //3.发射形状--线性
    rainLayer.emitterShape = kCAEmitterLayerSphere;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterSize = self.view.frame.size;
    rainLayer.emitterPosition = CGPointMake(self.view.bounds.size.width/2, -10);
    
    //4.配置cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"jinbi.png"].CGImage);
    cell.birthRate = 1;
    cell.lifetime = 30;
    cell.speed = 2;
    cell.velocity = 10.0f;
    cell.velocityRange = 10.0f;
    cell.yAcceleration = 60;
    cell.scale = 0.05;
    cell.scaleRange = 0.05f;
    
    CAEmitterCell *cell2 = [CAEmitterCell emitterCell];
    cell2.contents = (__bridge id _Nullable)([UIImage imageNamed:@"zongzi2.jpg"].CGImage);
    cell2.birthRate = 1;
    cell2.lifetime = 30;
    cell2.speed = 2;
    cell2.velocity = 10.0f;
    cell2.velocityRange = 10.0f;
    cell2.yAcceleration = 60;
    cell2.scale = 0.05;
    cell2.scaleRange = 0.05f;
    
    
    CAEmitterCell *cell3 = [CAEmitterCell emitterCell];
    cell3.contents = (__bridge id _Nullable)([UIImage imageNamed:@"hongbao"].CGImage);
    cell3.birthRate = 1;
    cell3.lifetime = 30;
    cell3.speed = 2;
    cell3.velocity = 10.0f;
    cell3.velocityRange = 10.0f;
    cell3.yAcceleration = 60;
    cell3.scale = 0.05;
    cell3.scaleRange = 0.05f;
    
    rainLayer.emitterCells = @[cell, cell2, cell3];
}
@end
