//
//  LivePlayerManager.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import "TTLivePlayerManager.h"
#import "TTLivePlayerController.h"
#import "TTLiveModel.h"
#import "TTLiveRoomCellController.h"
#import <ToolKit/ToolKit.h>

@interface TTLivePlayerManager ()

@property(nonatomic, strong) NSMutableArray<TTLivePlayerController *>  *playingPlayerList;

@property(nonatomic, strong) NSMutableArray<TTLivePlayerController *>  *cachePlayerList;

@end

@implementation TTLivePlayerManager

+ (instancetype)sharedLiveManager {
    static TTLivePlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTLivePlayerManager alloc] init];
    });
    return manager;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playingPlayerList = [[NSMutableArray alloc] init];
        _cachePlayerList = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -- instance method
- (TTLivePlayerController *)createLivePlayer {
    TTLivePlayerController *  player = nil;
    if (self.reusePlayer) {
        player = self.reusePlayer;
        self.reusePlayer = nil;
    } else {
        if (self.cachePlayerList.count > 0) {
            player = self.cachePlayerList.firstObject;
            [self.cachePlayerList removeObjectAtIndex:0];
            [self.playingPlayerList addObject:player];
        } else {
            player = [[TTLivePlayerController  alloc] init];
            [self.playingPlayerList addObject:player];
        }
    }
    [player removeStreamView];
    return player;
}
- (void)recoveryPlayer:(TTLivePlayerController *)player {
    if (player) {
        [player stopPlayerStream];
        [player removeStreamView];
        [self.playingPlayerList removeObject:player];
        if (![self.cachePlayerList containsObject:player]) {
            [self.cachePlayerList addObject:player];
        }
    } else {
        VOLogE(VOTTProto, @"recovery nil");
    }
}
- (void)recoveryAllPlayerWithException:(TTLivePlayerController *)player {
    NSArray *tempPlayingList = [self.playingPlayerList copy];
    if (!player) {
        [tempPlayingList enumerateObjectsUsingBlock:^(TTLivePlayerController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self recoveryPlayer:obj];
        }];
        self.reusePlayer = nil;
    } else {
        __block TTLivePlayerController *tempPlayer;
        [tempPlayingList enumerateObjectsUsingBlock:^(TTLivePlayerController * _Nonnull obj,
                                                             NSUInteger idx,
                                                             BOOL * _Nonnull stop) {
            if (obj != player) {
                [self recoveryPlayer:obj];
            } else {
                [obj removeStreamView];
                tempPlayer = obj;
            }
        }];
        if (tempPlayer != player) {
            VOLogE(VOTTProto, @"unExpected player");
        }
        self.reusePlayer = tempPlayer;
    }
}

- (void)cleanCache {
    [self.playingPlayerList enumerateObjectsUsingBlock:^(TTLivePlayerController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj stopPlayerStream];
        [obj removeStreamView];
        [obj destroy];
    }];
    [self.cachePlayerList enumerateObjectsUsingBlock:^(TTLivePlayerController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj destroy];
    }];
    [self.playingPlayerList removeAllObjects];
    [self.cachePlayerList removeAllObjects];
    self.reusePlayer = nil;
}

@end
