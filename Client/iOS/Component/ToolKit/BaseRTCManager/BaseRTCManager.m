// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseRTCManager.h"
#import "NotificationConstans.h"
#import <ToolKit/ToolKit.h>
#import "NetworkingManager.h"

typedef NSString *RTSMessageType;
static RTSMessageType const RTSMessageTypeNotice = @"inform";

@interface BaseRTCManager ()

@property (nonatomic, strong) NSMutableDictionary *listenerDic;

@end

@implementation BaseRTCManager

#pragma mark - Publish Action

- (void)connect:(NSString *)appID
            bid:(NSString *)bid
          block:(void (^)(BOOL result))block {
    NSString *uid = [LocalUserComponent userModel].uid;
    if (IsEmptyStr(uid)) {
        if (block) {
            block(NO);
        }
        return;
    }
    if (self.rtcEngineKit) {
        [ByteRTCVideo destroyRTCVideo];
        self.rtcEngineKit = nil;
    }

    // Create an engine instance.
    self.rtcEngineKit = [ByteRTCVideo createRTCVideo:appID delegate:self parameters:@{}];
    [self configeRTCEngine];

    // Set Business ID
    [self.rtcEngineKit setBusinessId:bid];

    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (block) {
            block(YES);
        }
    });
}

- (void)disconnect {
    [ByteRTCVideo destroyRTCVideo];
    self.rtcEngineKit = nil;
}

- (void)emitWithAck:(NSString * __nonnull)event
               with:(NSDictionary *)items
              block:(RTCSendServerMessageBlock)block {
    if (IsEmptyStr(event)) {
        [self throwErrorAck:RTSStatusCodeInvalidArgument
                    message:@"Lack EventName"
                      block:block];
        return;
    }

    [NetworkingManager callHttpEvent:event
                             content:items
                               block:^(NetworkingResponse * _Nonnull response) {
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (block) {
                RTSACKModel *ackModel = [RTSACKModel modelWithMessageData:response.json];
                block(ackModel);
            }
        });
    }];
}

- (void)throwErrorAck:(NSInteger)code message:(NSString *)message
                block:(__nullable RTCSendServerMessageBlock)block {
    if (!block) {
        return;
    }
    RTSACKModel *ackModel = [[RTSACKModel alloc] init];
    ackModel.code = code;
    ackModel.message = message;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        block(ackModel);
    });
}

- (void)onSceneListener:(NSString *)key
                  block:(RTCRoomMessageBlock)block {
    if (IsEmptyStr(key)) {
        return;
    }
    [self.listenerDic setValue:block forKey:key];
}

- (void)offSceneListener {
    [self.listenerDic removeAllObjects];
}

#pragma mark - Config

- (void)configeRTCEngine {
    // Need to be overridden by subclasses
}

+ (NSString *_Nullable)getSDKVersion {
    return [ByteRTCVideo getSDKVersion];
}

#pragma mark - ByteRTCVideoDelegate

// Callback when receiving a message from outside the room
- (void)rtcEngine:(ByteRTCVideo *)engine onUserMessageReceivedOutsideRoom:(NSString *)uid message:(NSString *)message {
    [self dispatchMessageFrom:uid message:message];
    [self addLog:@"onUserMessageReceivedOutsideRoom-" message:message];
}

#pragma mark - ByteRTCRoomDelegate
// Receive RTC/RTS join room result
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
               withUid:(NSString *)uid
                 state:(NSInteger)state
             extraInfo:(NSString *)extraInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (state == ByteRTCErrorCodeDuplicateLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLogout
                                                                object:self
                                                              userInfo:@{NotificationLogoutReasonKey: @"logout"}];
        }
    });
}

// Callback when receiving a message from the room
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomMessageReceived:(NSString *)uid message:(NSString *)message {
    [self dispatchMessageFrom:uid message:message];
    [self addLog:@"onRoomMessageReceived-" message:message];
}

// Callback when receiving a message from a user in the room
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onUserMessageReceived:(NSString *)uid message:(NSString *)message {
    [self dispatchMessageFrom:uid message:message];
    [self addLog:@"onUserMessageReceived-" message:message];
}

#pragma mark - Private Action
- (void)dispatchMessageFrom:(NSString *)uid message:(NSString *)message {
    NSDictionary *dic = [NetworkingTool decodeJsonMessage:message];
    if (!dic || !dic.count) {
        return;
    }
    NSString *messageType = dic[@"message_type"];

    if ([messageType isKindOfClass:[NSString class]] &&
        [messageType isEqualToString:RTSMessageTypeNotice]) {
        [self receivedNoticeFrom:uid object:dic];
        return;
    }
}
- (void)receivedNoticeFrom:(NSString *)uid object:(NSDictionary *)object {
    RTSNoticeModel *noticeModel = [RTSNoticeModel yy_modelWithJSON:object];
    if (IsEmptyStr(noticeModel.eventName)) {
        return;
    }
    RTCRoomMessageBlock block = self.listenerDic[noticeModel.eventName];
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(noticeModel);
        });
    }
}

#pragma mark - Getter

- (NSMutableDictionary *)listenerDic {
    if (!_listenerDic) {
        _listenerDic = [[NSMutableDictionary alloc] init];
    }
    return _listenerDic;
}

#pragma mark - Tool

- (void)addLog:(NSString *)key message:(NSString *)message {
    VOLogI(VOToolKit,@"[%@]-%@ %@", [self class], key, [NetworkingTool decodeJsonMessage:message]);
}

@end
