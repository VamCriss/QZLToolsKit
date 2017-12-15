//
//  LSMusicPlayer.h
//  LawSiri
//
//  Created by Criss on 2017/12/6.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSMusicContentModel;

typedef NS_ENUM(NSUInteger, LSMusicPlayerCurrentStatus) {
    LSMusicPlayerCurrentStatusNone = 0,    // 还没有初始化播放器
    LSMusicPlayerCurrentStatusReadyPlay,   // 准备播放
    LSMusicPlayerCurrentStatusPlay,        // 播放中
    LSMusicPlayerCurrentStatusPause,       // 暂停
    LSMusicPlayerCurrentStatusStop,        // 停止播放
    LSMusicPlayerCurrentStatusInterrupt    // 被打断
};

@interface LSMusicPlayer : NSObject

// 当前音乐播放完成的回调
@property (nonatomic, copy) void(^currentMusicPlayFinishedBlock)(BOOL isFinished);

@property (nonatomic, strong, readonly) LSMusicContentModel *musicModel;

// 当前音乐的播放状态
@property (nonatomic, assign, readonly) LSMusicPlayerCurrentStatus currentStatu;

// 初始化
+ (instancetype)playerWithModel:(LSMusicContentModel *)model;

+ (instancetype)shared;

- (void)nextWithUrl:(NSString *)url;

- (void)play;
// 暂停, 下次播放继续
- (void)pause;
// 停止, 下次播放从头开始
- (void)stop;

// 在播放与暂停中自动切换 - 在打断情况下无作用
- (void)playOrPause;

// 应用内语音打断的时候,手动调用,告诉系统当前是在播放语音
- (void)interrupt;
// 从被打断的状态再次恢复播放
- (void)rePlay;

@end
