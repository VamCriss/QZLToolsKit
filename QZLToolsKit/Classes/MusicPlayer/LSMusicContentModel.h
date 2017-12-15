//
//  LSMusicContentModel.h
//  LawSiri
//
//  Created by 兰洋 on 2017/12/5.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LSMusicSingerModel : NSObject
// 歌手名称
@property (nonatomic, strong) NSString * name;
// 歌手Id
@property (nonatomic, strong) NSString * id;
@end

@interface LSMusicDownMusicModel : NSObject
// 歌曲URL
@property (nonatomic, strong) NSString * url;
// 歌曲时间
@property (nonatomic, strong) NSString * sizeM;
@end


@interface LSMusicContentModel : NSObject <NSCopying>
// 歌曲名称
@property (nonatomic, strong) NSString * title;
// 下载地址数组
@property (nonatomic, strong) NSArray <LSMusicDownMusicModel *>* fileOptions;
// 专辑名称
@property (nonatomic, copy) NSString *albumTitle;
// 歌手
@property (nonatomic, strong) NSArray <LSMusicSingerModel *>* singers;
// 副标题
@property (nonatomic, strong) NSString * subtitle;
// 音乐的封面图url
@property (nonatomic, strong) NSString * coverUrl;
// 音乐的封面图image
@property (nonatomic, strong) UIImage *coverimage;
// 根据title和subtitle合成的名称, 赋值给cell后才会生成
@property (nonatomic, copy) NSString *musicName;
// 音乐播放地址， 获取fileOptions的第一条数据
@property (nonatomic, copy, readonly) NSString *playUrl;
// 歌手拼接
@property (nonatomic, copy, readonly) NSString *singer;
// 是否正在播放
@property (nonatomic, assign) BOOL isPlay;

@end

