//
//  LSGeolocation.h
//  LawSiri
//
//  Created by Criss on 2017/12/14.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSGeolocation : NSObject

typedef NS_ENUM(NSUInteger, LSLocationAccuracy) {
    LSLocationAccuracyBest = 0,
    LSLocationAccuracyNearestTenMeters,
    LSLocationAccuracyHundredMeters,
    LSLocationAccuracyKilometer,
    LSLocationAccuracyThreeKilometers
};

///默认精度最好
@property (nonatomic, assign)LSLocationAccuracy distance;
///默认最大距离更新坐标
@property (nonatomic, assign)CGFloat distanceFilter;

+ (instancetype)shared;

// 获取当前的地理位置
- (void)getCurrentAddress:(void(^)(NSMutableDictionary *citys))address error:(void(^)(NSError *error))locError;

// 获取当前所在城市信息-(在getCurrentAddress定位成功后才有数据, 默认:北京)
- (NSString *)cityName;

@end
