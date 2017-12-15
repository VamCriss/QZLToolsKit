//
//  LSAnimationManager.m
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "LSAnimationManager.h"
#import "LSWave.h"
#import "LSCircle.h"
#import "LSTick.h"

@interface LSAnimationManager ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) LSWave *waveView;
@property (nonatomic, weak) LSTick *tickView;

@end

@implementation LSAnimationManager

#define animationHUD [LSAnimationManager shareManager]
#define UIColorWithHex16_(ly_0Xefefef) \
[UIColor colorWithRed:((ly_0Xefefef & 0xFF0000) >> 16) / 255.0 green:((ly_0Xefefef & 0x00FF00) >> 8) / 255.0 blue:((ly_0Xefefef & 0x0000FF)) / 255.0 alpha:1]

/* 创建单例 */
+ (instancetype)shareManager {
    static LSAnimationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/* 波浪动画 */
+ (void)wavaAnimationWithFrame:(CGRect)frame {
    if (animationHUD.waveView) {
        [self removeWave];
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = UIColorWithHex16_(0xd8dde5);
    backView.layer.cornerRadius = backView.bounds.size.width/2.0f;
    backView.layer.masksToBounds = true;
    
    CGFloat waveWidth = backView.bounds.size.width * 0.8f;
    LSWave *wave = [[LSWave alloc] initWithFrame:CGRectMake(0, 0, waveWidth, waveWidth)];
    wave.center = CGPointMake(backView.bounds.size.width/2.0f, backView.bounds.size.width/2.0f);
    [backView addSubview:wave];
    
    //隐藏支付完成动画
    [LSTick hideIn:backView];
    //显示支付中动画
    [LSCircle showIn:backView];
    
    animationHUD.waveView = wave;
    animationHUD.backView = backView;
    [[self ls_window] addSubview:backView]; 
}

+ (void)removeWave {
    [animationHUD.backView removeFromSuperview];
    animationHUD.waveView = nil;
}

+ (void)waveProgress:(CGFloat)progress {
    animationHUD.waveView.progress = progress;
}

+ (void)waveStop {
    [animationHUD.waveView stop];
}

+ (void)waveFillUpBackgroundColor:(UIColor *)color {
    //隐藏支付中成动画
    [LSCircle hideIn:animationHUD.backView];
    //显示支付完成动画
    animationHUD.tickView = [LSTick showIn:animationHUD.backView];
    
    [animationHUD.waveView removeAllAnimatiuonSubLayers];
    animationHUD.waveView.layer.backgroundColor = color.CGColor;
}

+ (void)waveAddTarget:(id)target action:(SEL)aciton {
    [animationHUD.tickView addTarget:target action:aciton];
}

/* 获取window */
+ (UIWindow *)ls_window {
    return [UIApplication sharedApplication].delegate.window;
}

@end
