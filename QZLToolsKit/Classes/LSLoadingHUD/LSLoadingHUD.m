//
//  LSLoadingHUD.m
//  LSLoadingHUD
//
//  Created by Criss on 2017/11/26.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import "LSLoadingHUD.h"
#import "LSRotationView.h"

NSString * const LSLoadingHUDWillShowNotification = @"LSLoadingHUDWillShowNotification";

#define LSLoadingKeyWindow [[[UIApplication sharedApplication] delegate] window]

@interface LSLoadingHUD ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSTimeInterval duration;

@end;

@implementation LSLoadingHUD

+ (instancetype)sharedView {
    static LSLoadingHUD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    });
    return instance;
}

+ (void)show {
    [[LSLoadingHUD sharedView] showHUD];
}

+ (void)showWithDuration:(NSTimeInterval)duration {
    [LSLoadingHUD sharedView].duration = duration;
    [self show];
}

+ (void)hide {
    [LSLoadingHUD sharedView].isLoading = NO;
    [LSLoadingHUD hideWithDelay:0.0];
}

+ (void)hideWithDelay:(NSTimeInterval)delay {
    if (delay < 0) {
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[LSLoadingHUD sharedView] hideHUD];
    });
}

- (void)showHUD {
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LSLoadingHUDWillShowNotification object:self];
        self.backgroundColor = [UIColor clearColor];
        [LSLoadingKeyWindow addSubview:self];
        [self defaultRotationAnimation];
        self.center = LSLoadingKeyWindow.center;
    });
}

- (void)hideHUD {
    self.isLoading = NO;
    [self removeFromSuperview];
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    if (duration > 0) {
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingViewWillShow:) name:LSLoadingHUDWillShowNotification object:self];
    }
}

// rotation animation
- (void)defaultRotationAnimation {
    LSRotationView *rotateView = [[LSRotationView alloc] initWithFrame:self.bounds];
    rotateView.speed                 = 0.95f;
    rotateView.clockWise             = YES;
    [rotateView startAnimation];
    [self addSubview:rotateView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
    imageView.bounds = CGRectMake(0, 0, self.bounds.size.width * 1, self.bounds.size.height * 1);
    imageView.center = rotateView.center;
    [rotateView addSubview:imageView];
    
    UIImageView *inImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"word"]];
    inImageView.bounds = CGRectMake(0, 0, rotateView.bounds.size.width * 0.5, rotateView.bounds.size.height * 0.5);
    inImageView.center = imageView.center;
    [self addSubview:inImageView];
}

// Notification action
- (void)loadingViewWillShow:(NSNotification *)noti {
    [[self class] hideWithDelay:_duration];
}

@end
