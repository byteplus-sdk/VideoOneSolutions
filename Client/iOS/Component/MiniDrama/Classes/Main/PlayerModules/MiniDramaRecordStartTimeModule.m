//
//  MiniDramaRecordStartTimeModule.m
//  MDPlayModule
//
//  Created by zyw on 2024/7/15.
//

#import "MiniDramaRecordStartTimeModule.h"
#import "MDPlayerContextKeyDefine.h"
#import <Masonry/Masonry.h>
#import "MDDramaFeedInfo.h"
#import "MDVideoPlayback.h"
#import "MDLRUCache.h"
#import "BTDMacros.h"

@interface MiniDramaRecordStartTimeModule ()

@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;
@property (nonatomic, weak) MDDramaFeedInfo *dramaVideoInfo;
@property (nonatomic, assign) BOOL isPlayed;

@end

@implementation MiniDramaRecordStartTimeModule

MDPlayerContextDILink(playerInterface, MDVideoPlayback, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.context addKey:MDPlayerContextKeyMiniDramaDataModelChanged withObserver:self handler:^(MDDramaFeedInfo *dramaVideoInfo, NSString *key) {
        @strongify(self);
        self.dramaVideoInfo = dramaVideoInfo;
    }];
    [self.context addKey:MDPlayerContextKeyBeforePlayAction withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key) {
        @strongify(self);
        [self setPlayerStartTime];
    }];
    [self.context addKeys:@[MDPlayerContextKeyStopAction, MDPlayerContextKeyPlaybackDidFinish, MDPlayerContextKeyPauseAction] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self recordStartTime];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
}

#pragma mark - private

- (void)recordStartTime {
    NSInteger curTime = self.playerInterface.currentPlaybackTime;
    NSInteger duration = self.playerInterface.duration;
    NSInteger startTime = 0;
    if (curTime && duration && (duration - curTime > 5)) {
        startTime = curTime;
    }
    
    // 内存级缓存，业务可以根据实际情况修改源码，例如做云端缓存等
//    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", self.dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId, @(self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
//    [[MDLRUCache shareInstance] setValue:@(startTime) forKey:cacheKey];
}

- (void)setPlayerStartTime {
    if (!self.isPlayed) {
        self.isPlayed = YES;
//        NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", self.dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId, @(self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
//        NSInteger startTime = [[[MDLRUCache shareInstance] getValueForKey:cacheKey] integerValue];
//        if (startTime > 0) {
//            self.playerInterface.startTime = startTime;
//        }
    }
}

@end
