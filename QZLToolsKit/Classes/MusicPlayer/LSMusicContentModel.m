//
//  LSMusicContentModel.m
//  LawSiri
//
//  Created by 兰洋 on 2017/12/5.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "LSMusicContentModel.h"
#import <YYModel.h>

@implementation LSMusicSingerModel
- (NSString *)description
{
    return [self yy_modelDescription];
}
@end

@implementation LSMusicDownMusicModel
- (NSString *)description
{
    return [self yy_modelDescription];
}
@end

@implementation LSMusicContentModel
- (NSString *)description
{
    return [self yy_modelDescription];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"fileOptions" : [LSMusicDownMusicModel class],
             @"singers" : [LSMusicSingerModel class]
             };
}

- (void)setFileOptions:(NSArray<LSMusicDownMusicModel *> *)fileOptions {
    _fileOptions = fileOptions;
    _playUrl = fileOptions.firstObject.url;
}

- (void)setSingers:(NSArray<LSMusicSingerModel *> *)singers {
    _singers = singers;
    _singer = [[singers valueForKey:@"name"] componentsJoinedByString:@", "];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self yy_modelCopy];
}

@end
