//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef LiveInteractivePushStreaming_h
#define LiveInteractivePushStreaming_h

typedef NS_ENUM(NSUInteger, LiveInteractivePlayMode) {
    // Single user
    LiveInteractivePlayModeNormal = 0,
    // two anchor pk.
    LiveInteractivePlayModePK = 1,
    // anchor and guests.
    LiveInteractivePlayModeMultiGuests = 2
};

@protocol LiveInteractiveDelegate <NSObject>

- (void)liveInteractiveOnUserPublishStream:(NSString *_Nullable)uid;

@end

@protocol LiveInteractivePushStreaming <NSObject>

- (void)startInteractive;
- (void)stopInteractive;

- (void)onUserListChanged:(NSArray<LiveUserModel *> *_Nullable)userList;

- (void)switchPlayMode:(LiveInteractivePlayMode)playMode;

- (void)startForwardStreamToRooms:(NSString *_Nonnull)roomId token:(NSString *_Nonnull)token;

- (BOOL)isInteracting;

@end

#endif /* LiveInteractivePushStreaming_h */
