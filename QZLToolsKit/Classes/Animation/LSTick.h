//
//  LSTick.h
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSTick : UIView

-(void)start;

-(void)hide;

- (void)boundsRadius:(CGFloat)radius;

+(instancetype)showIn:(UIView*)view;

+(instancetype)hideIn:(UIView*)view;

- (void)addTarget:(id)target action:(SEL)action;

@end
