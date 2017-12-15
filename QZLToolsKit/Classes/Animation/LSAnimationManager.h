//
//  LSAnimationManager.h
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSAnimationManager : NSObject

// 在window上添加一个波纹动画
+ (void)wavaAnimationWithFrame:(CGRect)frame;

// 设置波纹的进度
+ (void)waveProgress:(CGFloat)progress;

// 停止波纹动画
+ (void)waveStop;

// 设置wave填满时的颜色
+ (void)waveFillUpBackgroundColor:(UIColor *)color;

// 点击波浪的响应事件
+ (void)waveAddTarget:(id)target action:(SEL)aciton;

// 移除波纹动画视图
+ (void)removeWave;

@end
