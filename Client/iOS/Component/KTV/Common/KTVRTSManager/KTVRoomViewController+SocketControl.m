// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomViewController+SocketControl.h"

@implementation KTVRoomViewController (SocketControl)

- (void)addSocketListener {
    __weak __typeof(self) wself = self;
    [KTVRTSManager onAudienceJoinRoomWithBlock:^(KTVUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedJoinUser:userModel count:count];
        }
    }];
    
    
    [KTVRTSManager onAudienceLeaveRoomWithBlock:^(KTVUserModel * _Nonnull userModel, NSInteger count) {
        if (wself) {
            [wself receivedLeaveUser:userModel count:count];
        }
    }];

    
    [KTVRTSManager onFinishLiveWithBlock:^(NSString * _Nonnull rommID, NSInteger type) {
        if (wself) {
            [wself receivedFinishLive:type roomID:rommID];
        }
    }];

    
    [KTVRTSManager onJoinInteractWithBlock:^(KTVUserModel * _Nonnull userModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedJoinInteractWithUser:userModel seatID:seatID];
        }
    }];

    
    [KTVRTSManager onFinishInteractWithBlock:^(KTVUserModel * _Nonnull userModel, NSString * _Nonnull seatID, NSInteger type) {
        if (wself) {
            [wself receivedLeaveInteractWithUser:userModel seatID:seatID type:type];
        }
    }];

    
    [KTVRTSManager onSeatStatusChangeWithBlock:^(NSString * _Nonnull seatID, NSInteger type) {
        if (wself) {
            [wself receivedSeatStatusChange:seatID type:type];
        }
    }];

    
    [KTVRTSManager onMediaStatusChangeWithBlock:^(KTVUserModel * _Nonnull userModel, NSString * _Nonnull seatID, NSInteger mic) {
        if (wself) {
            [wself receivedMediaStatusChangeWithUser:userModel seatID:seatID mic:mic];
        }
    }];

    
    [KTVRTSManager onMessageWithBlock:^(KTVUserModel * _Nonnull userModel, NSString * _Nonnull message) {
        if (wself) {
            message = [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [wself receivedMessageWithUser:userModel message:message];
        }
    }];

    //Single Notification Message
    
    [KTVRTSManager onInviteInteractWithBlock:^(KTVUserModel * _Nonnull hostUserModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedInviteInteractWithUser:hostUserModel seatID:seatID];
        }
    }];
    
    [KTVRTSManager onApplyInteractWithBlock:^(KTVUserModel * _Nonnull userModel, NSString * _Nonnull seatID) {
        if (wself) {
            [wself receivedApplyInteractWithUser:userModel seatID:seatID];
        }
    }];

    [KTVRTSManager onInviteResultWithBlock:^(KTVUserModel * _Nonnull userModel, NSInteger reply) {
        if (wself) {
            [wself receivedInviteResultWithUser:userModel reply:reply];
        }
    }];
    
    [KTVRTSManager onMediaOperateWithBlock:^(NSInteger mic) {
        if (wself) {
            [wself receivedMediaOperatWithUid:mic];
        }
    }];
    
    [KTVRTSManager onClearUserWithBlock:^(NSString * _Nonnull uid) {
        if (wself) {
            [wself receivedClearUserWithUid:uid];
        }
    }];
    
    [KTVRTSManager onPickSongBlock:^(KTVSongModel * _Nonnull songModel) {
        [wself receivedPickedSong:songModel];
    }];
    
    [KTVRTSManager onStartSingSongBlock:^(KTVSongModel * _Nonnull songModel) {
        [wself receivedStartSingSong:songModel];
    }];
    
    [KTVRTSManager onFinishSingSongBlock:^(KTVSongModel * _Nonnull nextSongModel, KTVSongModel * _Nonnull curSongModel, NSInteger score) {
        [wself receivedFinishSingSong:score nextSongModel:nextSongModel curSongModel:curSongModel];
    }];
}
@end
