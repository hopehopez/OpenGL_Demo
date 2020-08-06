//
//  LikeButton.m
//  011_LikeAnimation
//
//  Created by zsq on 2020/8/6.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "LikeButton.h"

@interface LikeButton()

@property (nonatomic, strong) CAEmitterLayer *explosionLayer;

@end


@implementation LikeButton

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setupExplosion];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupExplosion];
    }
    
    return self;
}

- (void)setupExplosion{
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name = @"explosionCell";
    cell.alphaSpeed = -1.f;
    cell.alphaRange = 0.1;
    cell.lifetime = 1;
//    cell.birthRate = 1000;
    cell.lifetimeRange = 0.1;
    cell.velocity = 40;
    cell.velocityRange = 10;
    cell.scale = 0.08;
    cell.scaleRange = 0.02;
    cell.contents = (id)[UIImage imageNamed:@"spark_red"].CGImage;
    
    CAEmitterLayer *explosionLayer = [CAEmitterLayer layer];
    [self.layer addSublayer:explosionLayer];
    self.explosionLayer = explosionLayer;
    explosionLayer.emitterSize = CGSizeMake(self.bounds.size.width + 40, self.bounds.size.height + 40);
    explosionLayer.emitterShape = kCAEmitterLayerCircle;
    explosionLayer.emitterMode = kCAEmitterLayerOutline;
    explosionLayer.renderMode = kCAEmitterLayerOldestFirst;
    
    
    explosionLayer.emitterCells = @[cell];

}

-(void)layoutSubviews{
    // 发射源位置
    self.explosionLayer.position = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    
    if (selected) {
        animation.values = @[@1.5, @2.0, @0.8, @1.0];
        animation.duration = 0.5;
        animation.calculationMode = kCAAnimationCubic;
        
        [self.layer addAnimation:animation forKey:nil];
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.25];
    } else {
        [self stopAnimation];
    }
}

- (void)startAnimation{
    
     [self.explosionLayer setValue:@1000 forKeyPath:@"emitterCells.explosionCell.birthRate"];
    self.explosionLayer.beginTime = CACurrentMediaTime();
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:0.15];
}
- (void)stopAnimation{
    
    [self.explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosionCell.birthRate"];
    [self.layer removeAllAnimations];
    
}
@end
