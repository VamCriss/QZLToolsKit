//
//  LSCircle.h
//  LawSiri
//
//  Created by Criss on 2017/11/23.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSCircle : UIView

- (void)start;

- (void)hide;

+ (LSCircle*)showIn:(UIView*)view;

+ (LSCircle*)hideIn:(UIView*)view;

@end
