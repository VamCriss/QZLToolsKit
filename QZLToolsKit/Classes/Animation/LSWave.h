//
//  LSWave.h
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSWave : UIView

/**
 设置进度 0~1
 */
@property (assign,nonatomic) CGFloat progress;

- (void)addTarget:(id)target action:(SEL)action;

- (void)removeAllAnimatiuonSubLayers;

- (void)stop;

@end
