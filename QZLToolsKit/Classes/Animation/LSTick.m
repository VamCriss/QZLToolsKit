//
//  LSTick.m
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "LSTick.h"

static CGFloat lineWidth = 4.0f;
static CGFloat circleDuriation = 0.5f;
static CGFloat checkDuration = 0.2f;

#define BlueColor [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1]
#define UIColorWithHex16_(ly_0Xefefef) \
[UIColor colorWithRed:((ly_0Xefefef & 0xFF0000) >> 16) / 255.0 green:((ly_0Xefefef & 0x00FF00) >> 8) / 255.0 blue:((ly_0Xefefef & 0x0000FF)) / 255.0 alpha:1]


@interface LSTick () <CAAnimationDelegate>

@end

@implementation LSTick {
    CALayer *_animationLayer;
    
    CAShapeLayer *_circleLayer;
    
}

//显示
+ (instancetype)showIn:(UIView*)view {
    [self hideIn:view];
    LSTick *hud = [[self alloc] initWithFrame:view.bounds];
    [hud start];
    [view addSubview:hud];
    return hud;
}

//隐藏
+ (instancetype)hideIn:(UIView *)view {
    LSTick *hud = nil;
    for (LSTick *subView in view.subviews) {
        if ([subView isKindOfClass:[LSTick class]]) {
            [subView hide];
            [subView removeFromSuperview];
            hud = subView;
        }
    }
    return hud;
}

- (void)start {
    [self circleAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * circleDuriation * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self checkAnimation];
    });
}

- (void)hide {
    for (CALayer *layer in _animationLayer.sublayers) {
        [layer removeAllAnimations];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        lineWidth = self.bounds.size.width *0.2;
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    _animationLayer = [CALayer layer];
    _animationLayer.bounds = self.bounds;
    _animationLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.layer addSublayer:_animationLayer];
}

//画圆
- (void)circleAnimation {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    _circleLayer = circleLayer;
    circleLayer.frame = _animationLayer.bounds;
    [_animationLayer addSublayer:circleLayer];
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = UIColorWithHex16_(0xa0bfe6).CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    
    
    CGFloat lineWidth = 5.0f;
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleLayer.position radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = circleDuriation;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.delegate = self;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
}

//对号
- (void)checkAnimation {
    
    CGFloat a = _animationLayer.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
    [path addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
    [path addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
    
    CAShapeLayer *checkLayer = [CAShapeLayer layer];
    checkLayer.path = path.CGPath;
    checkLayer.fillColor = [UIColor clearColor].CGColor;
    checkLayer.strokeColor = UIColorWithHex16_(0xffffff).CGColor;
    checkLayer.lineWidth = lineWidth * 0.5;
    checkLayer.lineCap = kCALineCapRound;
    checkLayer.lineJoin = kCALineJoinRound;
    [_animationLayer addSublayer:checkLayer];
    
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = checkDuration;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    checkAnimation.delegate = self;
    [checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
    [checkLayer addAnimation:checkAnimation forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(checkDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_circleLayer removeFromSuperlayer];
    });
}

- (void)boundsRadius:(CGFloat)radius {
    lineWidth = radius;
}

// touch事件
- (void)addTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tapGesture];
}

@end
