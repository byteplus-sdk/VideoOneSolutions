// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCInteract.h"
#import "LivePushStreamParams.h"
#import "LiveRTCInteractUtils.h"
#import "LiveRTCManager.h"
#import "RTCJoinModel.h"

@interface LiveRTCInteract () <LiveRTCManagerDelegate>

@property (nonatomic, strong) LivePushStreamParams *streamParams;

// Mix streaming status
@property (atomic, assign) RTCInteractState interactState;

@property (nonatomic, copy) NSArray<LiveUserModel *> *userList;
@property (atomic, assign) BOOL hasForwardStreamToRooms;
@property (atomic, assign) BOOL hasPublishStream;

@end

@implementation LiveRTCInteract

- (instancetype)initWithPushStreamParams:(LivePushStreamParams *)params {
    if (self = [super init]) {
        _streamParams = params;
        _interactState = RTCInteractStateInit;
        _playMode = LiveInteractivePlayModeNormal;
        _hasForwardStreamToRooms = NO;
        _hasPublishStream = NO;
        NSLog(@"aaa init teract roomid%@ %@", params.rtcRoomId, params.rtcToken);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"aaa dealloc rtcInteract");
}

- (void)updateStreamParams:(LivePushStreamParams *)params {
    _streamParams = params;
}

- (BOOL)isInteractive {
    return self.interactState == RTCInteractStateJoin || self.interactState == RTCInteractStateJoinSuccess;
}

- (BOOL)isAnchorSelf:(NSString *)uid {
    return [self p_isHost] && [self p_isCurrentUser:uid];
}

- (void)startInteractive {
    NSLog(@"aaa startInteractive rtc");
    if (![self p_isHost]) {
        [[LiveRTCManager shareRtc] switchVideoCapture:YES];
        [[LiveRTCManager shareRtc] switchAudioCapture:YES];
    }
    if (![self isInteractive]) {
        [self joinChannel];
    } else if ([self p_supportPublish]) {
        [self p_publishStream];
    }
    [LiveRTCManager shareRtc].delegate = self;
}

- (void)stopInteractive {
    NSLog(@"aaa stopInteractive");
    if ([self p_isHost]) {
        NSAssert(self.streamParams.host, @"host does not configured");
        if (self.streamParams.host) {
            [[LiveRTCManager shareRtc] updateTranscodingLayout:@[self.streamParams.host]
                                                     mixStatus:RTCMixStatusSingleLive
                                                     rtcRoomId:self.streamParams.rtcRoomId];
        }
        // Stop span the room retweet stream
        [[LiveRTCManager shareRtc] stopForwardStreamToRooms];
        self.hasPublishStream = NO;
    } else {
        [[LiveRTCManager shareRtc] switchVideoCapture:NO];
        [[LiveRTCManager shareRtc] switchAudioCapture:NO];
    }
    [[LiveRTCManager shareRtc] leaveRTCRoom];
    self.interactState = RTCInteractStateLeave;
}

- (void)joinChannel {
    [[LiveRTCManager shareRtc] joinRTCRoomByToken:self.streamParams.rtcToken
                                        rtcRoomID:self.streamParams.rtcRoomId
                                           userID:self.streamParams.currerntUserId];
    self.interactState = RTCInteractStateJoin;
}

- (void)switchPlayMode:(LiveInteractivePlayMode)playMode {
    self.playMode = playMode;
}

- (void)onUserListChanged:(NSArray<LiveUserModel *> *)userList {
    self.userList = [userList copy];
    [self updateTranscodingIfNeed];
    NSLog(@"aaa interact users %ld", userList.count);
}

- (void)startForwardStreamToRooms:(NSString *)roomId token:(NSString *)token {
    if (self.interactState == RTCInteractStateJoinSuccess) {
        [[LiveRTCManager shareRtc] startForwardStreamToRooms:roomId token:token];
        self.hasForwardStreamToRooms = YES;
    }
}

- (BOOL)isInteracting {
    return self.playMode != LiveInteractivePlayModeNormal;
}

#pragma mark--private
- (BOOL)p_supportPublish {
    return [self p_isHost] && !self.hasPublishStream;
}

- (BOOL)p_isHost {
    return self.streamParams.host.uid.length && [self.streamParams.host.uid isEqualToString:self.streamParams.currerntUserId];
}

- (BOOL)p_isCurrentUser:(NSString *)uid {
    return uid.length && [uid isEqualToString:self.streamParams.currerntUserId];
}

- (void)p_publishStream {
    NSLog(@"aaa p_publishStream");
    NSAssert(self.streamParams.pushUrl, @"rtc push url is nil");
    NSString *rtmpUrl = [LiveRTCInteractUtils setPriorityForUrl:self.streamParams.pushUrl];
    [[LiveRTCManager shareRtc]
        startMixStreamRetweetWithPushUrl:rtmpUrl
                                hostUser:self.streamParams.host
                               rtcRoomId:self.streamParams.rtcRoomId];
    self.hasPublishStream = YES;
}

- (void)updateTranscodingIfNeed {
    if (self.userList.count && [self p_isHost] &&
        (self.interactState == RTCInteractStateJoin || self.interactState == RTCInteractStateJoinSuccess)) {
        WeakSelf;
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            StrongSelf;
            if (self.playMode == LiveInteractivePlayModePK) {
                // Update confluence retweet
                [[LiveRTCManager shareRtc] updateTranscodingLayout:self.userList
                                                         mixStatus:RTCMixStatusPK
                                                         rtcRoomId:sself.streamParams.rtcRoomId];
            } else {
                RTCMixStatus mixStatus = RTCMixStatusSingleLive;
                switch (self.playMode) {
                    case LiveInteractivePlayModeNormal:
                        mixStatus = RTCMixStatusSingleLive;
                        break;
                    case LiveInteractivePlayModePK:
                        mixStatus = RTCMixStatusPK;
                        break;
                    case LiveInteractivePlayModeMultiGuests:
                        mixStatus = self.userList.count == 2 ? RTCMixStatusAddGuestsTwo : RTCMixStatusAddGuestsMulti;
                        break;
                }
                NSLog(@"aaa updatetranscoding %ld type %ld", self.userList.count, mixStatus);
                [[LiveRTCManager shareRtc] updateTranscodingLayout:sself.userList
                                                         mixStatus:mixStatus
                                                         rtcRoomId:sself.streamParams.rtcRoomId];
            }
        });
    }
}

#pragma mark--LiveRTCManagerDelegate

- (void)liveRTCManager:(LiveRTCManager *)manager
    onRoomStateChanged:(RTCJoinModel *)joinModel
                   uid:(nonnull NSString *)uid {
    if (joinModel.joinType == 0) {
        if ([self p_isCurrentUser:uid]) {
            self.interactState = RTCInteractStateJoinSuccess;
            NSLog(@"aaa joinsuccess %@ hostId: %@", uid, self.streamParams.host.uid);
            if ([self p_supportPublish] && !self.hasPublishStream) {
                [self p_publishStream];
            }
        }
        if ([self.delegate respondsToSelector:@selector(rtcInteract:didJoinChannel:withUid:elapsed:)]) {
            [self.delegate rtcInteract:self didJoinChannel:joinModel.roomId withUid:uid elapsed:joinModel.elapsed];
        }
    } else {
        NSLog(@"aaa jointype = %ld", joinModel.joinType);
    }
}

- (BOOL)liveRTCManager:(LiveRTCManager *)manager onUserJoined:(NSString *)uid {
    BOOL contain = NO;
    for (LiveUserModel *user in self.userList) {
        if ([user.uid isEqualToString:uid]) {
            contain = YES;
            break;
        }
    }
    return contain;
}

- (void)liveRTCManager:(LiveRTCManager *)manager onJoinRoomResult:(NSString *)roomId withUid:(NSString *)uid joinType:(NSInteger)joinType elapsed:(NSInteger)elapsed {
}

- (void)liveRTCManager:(LiveRTCManager *)manager onUserPublishStream:(NSString *)uid {
    NSLog(@"aaa user publish %@", uid);
    if ([self.delegate respondsToSelector:@selector(rtcInteract:onUserPublishStream:)]) {
        [self.delegate rtcInteract:self onUserPublishStream:uid];
    }
    //    if ([self isAnchorSelf:uid] && self.playMode == LiveInteractivePlayModePK) {
    //    } else {
    [self updateTranscodingIfNeed];
    //    }
}

- (void)liveRTCManager:(LiveRTCManager *)manager onUserLeave:(NSString *)uid reason:(ByteRTCUserOfflineReason)reason {
}

- (void)liveRTCManager:(nonnull LiveRTCManager *)manager onStreamMixingEvent:(ByteRTCStreamMixingEvent)event taskId:(nonnull NSString *)taskId error:(ByteRtcTranscoderErrorCode)Code mixType:(ByteRTCStreamMixingType)mixType {
    NSLog(@"aaa mixing ev:%ld code %ld, type %ld", event, Code, mixType);
    if (event == ByteRTCStreamMixingEventStartSuccess && Code == ByteRtcTranscoderErrorCodeOK) {
        if ([self.delegate respondsToSelector:@selector(rtcInteract:onMixingStreamSuccess:)]) {
            [self.delegate rtcInteract:self onMixingStreamSuccess:mixType];
        }
    }
}

@end
