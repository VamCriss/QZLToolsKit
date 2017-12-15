//
//  LSLoadingHUD.h
//  LSLoadingHUD
//
//  Created by Criss on 2017/11/26.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLoadingHUD : UIView

+ (void)show;

+ (void)hide;

+ (void)showWithDuration:(NSTimeInterval)duration;

@end
