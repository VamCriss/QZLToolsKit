//
//  LSMusicPlayer.m
//  LawSiri
//
//  Created by Criss on 2017/12/6.
//  Copyright © 2017年 iCourt. All rights reserved.
//

#import "LSMusicPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LSMusicContentModel.h"
#import <AVFoundation/AVFoundation.h>

@interface LSMusicPlayer ()

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isNeedPlay;
@property (nonatomic, strong) LSMusicContentModel *model;

//当前歌曲进度监听者
@property(nonatomic,strong) id timeObserver;

@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *currentTime;

@end

@implementation LSMusicPlayer

+ (instancetype)shared {
    static LSMusicPlayer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)playerWithModel:(LSMusicContentModel *)model {
    LSMusicPlayer *player = [self shared];
    if (![model.playUrl isEqualToString:player.url]) {
        player.isNeedPlay = NO;
        player.url = model.playUrl;
        [player customPlayer];
    }
    player.model = model;
    return player;
}

- (void)customPlayer {
    NSURL *url = [NSURL URLWithString:self.url];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    if (!self.player) {
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
        self.player = player;
    }else {
        [self removePlayStatus];
        [self removeNSNotificationForPlayMusicFinish];
        [self.player replaceCurrentItemWithPlayerItem:item];
    }
    [self addNSNotificationForPlayMusicFinish];
    [self addPlayStatus];
    [self addMusicProgressWithItem:item];
}

//通过KVO监听播放器状态
-(void)addPlayStatus {
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

//移除监听播放器状态
-(void)removePlayStatus {
    // 在停止和和播放新的音乐的时候都会去移除之前item的Observer, 当不停止当前音乐直接播放下一首音乐的时候会多次删除,可能会导致崩溃
    @try {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    @catch (NSException *exception) {
        NSLog(@"多次删除了");
    }
}

- (void)removeNSNotificationForPlayMusicFinish {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)addNSNotificationForPlayMusicFinish {
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

- (void)play {
    if (_currentStatu != LSMusicPlayerCurrentStatusInterrupt) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [self.player play];
            // 初始化锁屏界面 -- 首次播放没有播放时间
            [self setupLockScreenInfo];
            _currentStatu = LSMusicPlayerCurrentStatusPlay;
            _model.isPlay = YES;
        }else {
            //        LSHUD_SHOW;
            self.isNeedPlay = YES;
            _currentStatu = LSMusicPlayerCurrentStatusReadyPlay;
        }
    }
}

- (void)rePlay {
    if (_currentStatu == LSMusicPlayerCurrentStatusInterrupt) {
        _currentStatu = LSMusicPlayerCurrentStatusReadyPlay;
        [self play];
    }
}

- (void)pause {
    [self.player pause];
    _currentStatu = LSMusicPlayerCurrentStatusPause;
    _model.isPlay = NO;
}

- (void)interrupt {
    if (_currentStatu == LSMusicPlayerCurrentStatusPlay || _currentStatu == LSMusicPlayerCurrentStatusReadyPlay) {
        [self.player pause];
        _currentStatu = LSMusicPlayerCurrentStatusInterrupt;
    }
}

- (void)stop {
    [self.player pause];
    _model.isPlay = NO;
    [self.player seekToTime:kCMTimeZero];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    _currentStatu = LSMusicPlayerCurrentStatusStop;
    [self clearData];
}

- (void)clearData {
    _currentTime = nil;
    _duration = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay: {
                if (self.isNeedPlay) {
                    [self play];
                    NSLog(@"开始播放");
                }
                NSLog(@"KVO：准备完毕，可以播放");
            }
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");
//    self.player.currentItem.reversePlaybackEndTime = kCMTimeZero;
    [self.player.currentItem seekToTime:kCMTimeZero];
    [self pause];
    if (self.currentMusicPlayFinishedBlock) {
        self.currentMusicPlayFinishedBlock(YES);
    }
}

- (void)nextWithUrl:(NSString *)url {
    if (self.player.currentItem) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
        [self.player replaceCurrentItemWithPlayerItem:item];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - 设置锁屏信息

//音乐锁屏信息展示
- (void)setupLockScreenInfo
{
    // 1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    //初始化一个存放音乐信息的字典
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    // 2、设置歌曲名
    if (self.model.title) {
        [playingInfoDict setObject:self.model.title forKey:MPMediaItemPropertyTitle];
    }
    // 设置专辑
    if (self.model.albumTitle) {
        [playingInfoDict setObject:self.model.albumTitle forKey:MPMediaItemPropertyAlbumTitle];
    }
    
    // 设置歌手名
    if (self.model.singer) {
        [playingInfoDict setObject:self.model.singer forKey:MPMediaItemPropertyArtist];
    }
    
    //音乐的播放时间
    if (self.currentTime) {
        [playingInfoDict setObject:self.currentTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    }
    
    //音乐的播放速度
    [playingInfoDict setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    // 3设置封面的图片
    if (_model.coverimage) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:_model.coverimage];
        [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }

    // 4设置歌曲的总时长
    self.duration = @(CMTimeGetSeconds(self.player.currentItem.duration)).description;
    if (self.duration) {
        [playingInfoDict setObject:self.duration forKey:MPMediaItemPropertyPlaybackDuration];
    }
    
    //音乐信息赋值给获取锁屏中心的nowPlayingInfo属性
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
 
    NSLog(@"主屏幕的数据: %@", playingInfoCenter.nowPlayingInfo);
    
//    // 5.开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

//监听音乐播放的进度
-(void)addMusicProgressWithItem:(AVPlayerItem *)item
{
    //移除监听音乐播放进度
    [self removeTimeObserver];
    __weak typeof(self) weakSelf = self;
    self.timeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time);
        //总时间 -- 之后可能需要有音乐播放进度
//        float total = CMTimeGetSeconds(item.duration);
        if (current) {
//            float progress = current / total;
            //更新播放进度条
//            weakSelf.playSlider.value = progress;
            weakSelf.currentTime = @(current).description;
        }
    }];
    
}

- (void)setUrl:(NSString *)url {
    _url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (void)setCurrentTime:(NSString *)currentTime {
    _currentTime = currentTime;
    
    // 实时更新锁屏上的音乐显示内容(可能锁屏的时候, 时间尚未计算出来)
    NSString *time = [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo objectForKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    if (!time || time.length == 0) {
        [self setupLockScreenInfo];
    }
}

//移除监听音乐播放进度
-(void)removeTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

//转换成时分秒
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}

- (LSMusicContentModel *)musicModel {
    return _model;
}

- (void)dealloc {
    [self removePlayStatus];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
