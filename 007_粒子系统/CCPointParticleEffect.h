//
//  CCPointParticleEffect.h
//  007_粒子系统
//
//  Created by zsq on 2020/8/5.
//  Copyright © 2020 zsq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////
// 默认重力加速度矢量与地球的
// {0, (-9.80665 m/s/s), 0} assuming +Y up coordinate system
extern const GLKVector3 CCDefaultGravity;

@interface CCPointParticleEffect : NSObject
//重力
@property (nonatomic, assign) GLKMatrix3 gravity;

//耗时
@property (nonatomic, assign) GLfloat elapsedSeconds;

//纹理
@property (nonatomic, strong, readonly) GLKEffectPropertyTexture *texture2d0;

//变换
@property (nonatomic, strong, readonly) GLKEffectPropertyTransform *transform;

//添加粒子
/*
 aPosition:位置
 aVelocity:速度
 aForce:重力
 aSize:大小
 aSpan:跨度
 aDuration:时长
 */
- (void)addParticleAtPosition:(GLKVector3)aPosition
                     velocity:(GLKVector3)aVelocity
                        force:(GLKVector3)aForce
                         size:(float)aSize
              lifeSpanSeconds:(NSTimeInterval)aSpan
          fadeDurationSeconds:(NSTimeInterval)aDuration;

//准备绘制
- (void)prepareToDraw;

//绘制
- (void)draw;
@end

NS_ASSUME_NONNULL_END
