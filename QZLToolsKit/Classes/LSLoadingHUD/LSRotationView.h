//
//  LSRotationView.h
//  LSLoadingHUD
//
//  Created by Criss on 2017/11/26.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSRotationView : UIView

/**
 *  旋转π，需要花费的时间
 */
@property (nonatomic) NSTimeInterval speed;

/**
 *  旋转方向, 默认是YES
 */
@property (nonatomic) BOOL clockWise;

/**
 *  开始的角度
 */
@property (nonatomic) CGFloat startAngle;

/**
 *  开始旋转
 */
- (void)startAnimation;

/**
 * 重置动画
 */
- (void)reset;

@end
