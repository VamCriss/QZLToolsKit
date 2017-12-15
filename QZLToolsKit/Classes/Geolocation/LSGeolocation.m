//
//  LSGeolocation.m
//  LawSiri
//
//  Created by Criss on 2017/12/14.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "LSGeolocation.h"
#import "AmendCoordinate.h"
#import <CoreLocation/CoreLocation.h>

#define LSSafaValue(_value_) _value_?:[NSNull null]

@interface LSGeolocation () <CLLocationManagerDelegate>

@end

@implementation LSGeolocation {
    CLLocationManager * _locationManager;
    NSDictionary *_locationInfo;
    
    void (^_sucBlock)(NSDictionary *loc);
    void (^_errorBlock)(NSError *error);
}

+ (instancetype)shared {
    static LSGeolocation *instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[self alloc] init];
    });
    return instace;
}

- (NSString *)cityName {
    NSString *cityName = (_locationInfo[@"city"]?:_locationInfo[@"sity"])?:@"北京市";
    // 京东招标搜索地点不能包含“市, 区，县”等后缀...
    cityName = [cityName substringToIndex:cityName.length - 1];
    return cityName;
}

// 获取当前位置信息
- (void)getCurrentAddress:(void (^)(NSMutableDictionary *))address error:(void (^)(NSError *))locError {
    //通过数据源拿到当前位置
    __weak typeof(self)weakSelf = self;
    [self getCurrentLocations:^(NSDictionary *curLoc) {
        [weakSelf getLocAddress:[curLoc objectForKey:@"lat"] withLon:[curLoc objectForKey:@"long"] address:^(NSMutableDictionary *citys) {
            address(citys);
            [self stopUpdatingLocation];
        } error:^(NSError *error) {
            locError(error);
            [self stopUpdatingLocation];
        }];
    } isIPOrientation:NO error:^(NSError *error) {
        locError(error);
    }];
}

//逆编码获取坐标信息
- (void)getLocAddress:(NSString *)lat withLon:(NSString *)lon address:(void(^)(NSMutableDictionary *citys))address error:(void(^)(NSError *error))getFail{
    //使用地理位置 逆向编码拿到位置信息
    if (lat != nil && lon != nil) {
        CLGeocoder * geocoder = [[CLGeocoder alloc]init];
        CLLocation * currentLoc = [[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
        [geocoder reverseGeocodeLocation:currentLoc completionHandler:^(NSArray *placemarks, NSError *error) {
            //逆编码完毕以后调用此block
            if (!error) {
                //获取当前地址城市名
                CLPlacemark * placeMark = placemarks[0];
                NSDictionary *locDic = placeMark.addressDictionary;
                NSDictionary *locDicationary = @{@"lat": lat,
                                                        @"lon": lon,
                                                        @"country": LSSafaValue(placeMark.country),
                                                        @"state": LSSafaValue(placeMark.locality),
                                                        @"city": LSSafaValue([locDic objectForKey:@"City"]),
                                                        @"sity": LSSafaValue(placeMark.subLocality),
                                                        @"street": LSSafaValue(placeMark.thoroughfare),
                                                        @"name": LSSafaValue(placeMark.name),
                                                        @"postalCode": LSSafaValue(placeMark.postalCode),
                                                        @"ISOcountryCode": LSSafaValue(placeMark.ISOcountryCode),
                                                        @"FormattedAddress": LSSafaValue([[locDic objectForKey:@"FormattedAddressLines"] firstObject]),
                                                        };
                _locationInfo = locDicationary;
                address(locDicationary.mutableCopy);
            }else{
                NSLog(@"逆编码失败");
            }}];
    }
}

//定位
- (void)getCurrentLocations:(void(^)(NSDictionary *curLoc))success isIPOrientation:(BOOL)orientation error:(void(^)(NSError  *error))errors
{
    _locationManager = [[CLLocationManager alloc]init];
    //定位精度(默认最好)
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (self.distance ) {
        _locationManager.desiredAccuracy = [self getDesiredAccuracy];
    }
    //定位更新频率(默认距离最大)
    [_locationManager setDistanceFilter:CLLocationDistanceMax];
    if (self.distanceFilter) {
        [_locationManager setDistanceFilter:self.distanceFilter];
    }
    
    //必须添加此判断，否则在iOS7上会crash
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
#ifdef __IPHONE_8_0
        [_locationManager requestWhenInUseAuthorization];
#endif
    }
    _locationManager.delegate = self;
    
    //成功
    _sucBlock = ^(NSDictionary *locDic){
        success(locDic);
    };
    //失败
    _errorBlock = ^(NSError *error){
        errors(error);
    };
    
    [_locationManager startUpdatingLocation];//开启定位
}

//定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation = [[CLLocation alloc]initWithLatitude:((CLLocation *)[locations firstObject]).coordinate.latitude longitude:((CLLocation *)[locations firstObject]).coordinate.longitude];
    
    if (![AmendCoordinate isLocationOutOfChina:[currLocation coordinate]]) {
        //坐标校准(根据自己所用地图而定)
        CLLocationCoordinate2D coord_gcj = [AmendCoordinate transformFromWGSToGCJ:[currLocation coordinate]];
        CLLocationCoordinate2D coord_bd9 = [AmendCoordinate transformFromGCJToBD:coord_gcj];
        
        NSDictionary *locDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",coord_bd9.latitude], @"lat", [NSString stringWithFormat:@"%f",coord_bd9.longitude], @"long", nil];
        _sucBlock(locDic);
    }else {
        NSDictionary *locDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currLocation.coordinate.latitude], @"lat", [NSString stringWithFormat:@"%f",currLocation.coordinate.longitude], @"long", nil];
        _sucBlock(locDic);
    }
}

//定位失败，回调此方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    _errorBlock(error);
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

//关闭定位
- (void)stopUpdatingLocation{
    [_locationManager stopUpdatingLocation];
}

- (CLLocationAccuracy)getDesiredAccuracy{
    CLLocationAccuracy distanceAccuracy;
    switch (self.distance) {
        case LSLocationAccuracyBest:
            distanceAccuracy = kCLLocationAccuracyBest;
            break;
        case LSLocationAccuracyHundredMeters:
            distanceAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case LSLocationAccuracyKilometer:
            distanceAccuracy = kCLLocationAccuracyKilometer;
            break;
        case LSLocationAccuracyThreeKilometers:
            distanceAccuracy = kCLLocationAccuracyThreeKilometers;
            break;
        case LSLocationAccuracyNearestTenMeters:
            distanceAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        default:
            break;
    }
    return distanceAccuracy;
}
@end
