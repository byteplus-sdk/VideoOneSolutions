// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "LiveInteractivePushStreaming.h"

typedef NS_ENUM(NSUInteger, RTCInteractState) {
    //{en} init state, still not join channel.
    RTCInteractStateInit = 1,
    //{en} start joining channel.
    RTCInteractStateJoin = 2,
    //{en} join channel success.
    RTCInteractStateJoinSuccess = 3,
    //{en} user leave room already.
    RTCInteractStateLeave = 4
};

@class LivePushStreamParams, LiveRTCInteract;


@protocol LiveRTCInteractDelegate <NSObject>

- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact didJoinChannel:(NSString *_Nullable)channelId withUid:(NSString *_Nullable)uid elapsed:(NSInteger)elapsed;
- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact onUserPublishStream:(NSString *_Nullable)uid;
- (void)rtcInteract:(LiveRTCInteract *_Nullable)interact onMixingStreamSuccess:(ByteRTCStreamMixingType)mixType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LiveRTCInteract : NSObject <LiveInteractivePushStreaming>



@property (nonatomic, weak) id<LiveRTCInteractDelegate> delegate;

@property (nonatomic, strong, readonly) LivePushStreamParams *streamParams;
@property (nonatomic, assign) LiveInteractivePlayMode playMode;

- (instancetype)initWithPushStreamParams:(LivePushStreamParams *)params;

- (void)updateStreamParams:(LivePushStreamParams *)params;

- (void)startInteractive;
- (void)stopInteractive;
- (BOOL)isAnchorSelf:(NSString *)uid;


- (void)onUserListChanged:(NSArray<LiveUserModel *> *_Nullable)userList;

- (void)startForwardStreamToRooms:(NSString *)roomId token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
