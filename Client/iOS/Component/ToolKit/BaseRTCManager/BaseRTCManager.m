// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseRTCManager.h"
#import "Localizator.h"
#import "NotificationConstans.h"

typedef NSString *RTSMessageType;
static RTSMessageType const RTSMessageTypeResponse = @"return";
static RTSMessageType const RTSMessageTypeNotice = @"inform";

@interface BaseRTCManager ()

@property (nonatomic, copy) void (^rtcLoginBlock)(BOOL result);
@property (nonatomic, copy) void (^rtcSetParamsBlock)(BOOL result);
@property (nonatomic, strong) NSMutableDictionary *listenerDic;
@property (nonatomic, strong) NSMutableDictionary *senderDic;

@end

@implementation BaseRTCManager

#pragma mark - Publish Action

- (void)connect:(NSString *)appID
       RTSToken:(NSString *)RTSToken
      serverUrl:(NSString *)serverUrl
      serverSig:(NSString *)serverSig
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

    // Log in RTS
    [self.rtcEngineKit login:RTSToken uid:uid];

    // Login RTS result callback
    __weak __typeof(self) wself = self;
    self.rtcLoginBlock = ^(BOOL result) {
        wself.rtcLoginBlock = nil;
        if (result) {
            // Set application server parameters
            [wself.rtcEngineKit setServerParams:serverSig url:serverUrl];
        } else {
            wself.rtcSetParamsBlock = nil;
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
                if (block) {
                    block(result);
                }
            });
        }
    };
    // Set application server parameters callback
    self.rtcSetParamsBlock = ^(BOOL result) {
        wself.rtcSetParamsBlock = nil;
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            if (block) {
                block(result);
            }
        });
    };
}

- (void)disconnect {
    [self.rtcEngineKit logout];
    [ByteRTCVideo destroyRTCVideo];
    self.rtcEngineKit = nil;
    self.rtcLoginBlock = nil;
    self.rtcSetParamsBlock = nil;
}

- (void)emitWithAck:(NSString *)event
               with:(NSDictionary *)item
              block:(RTCSendServerMessageBlock)block {
    if (IsEmptyStr(event)) {
        [self throwErrorAck:RTSStatusCodeInvalidArgument
                    message:@"Lack EventName"
                      block:block];
        return;
    }
    NSString *appId = @"";
    NSString *roomId = @"";
    if ([item isKindOfClass:[NSDictionary class]]) {
        appId = item[@"app_id"];
        roomId = item[@"room_id"];
        if (IsEmptyStr(appId)) {
            [self throwErrorAck:RTSStatusCodeInvalidArgument
                        message:@"Lack AppID"
                          block:block];
            return;
        }
    }
    NSString *wisd = [NetworkingTool getWisd];
    RTSRequestModel *requestModel = [[RTSRequestModel alloc] init];
    requestModel.eventName = event;
    requestModel.app_id = appId;
    requestModel.roomID = roomId;
    requestModel.userID = [LocalUserComponent userModel].uid;
    requestModel.requestID = [NetworkingTool MD5ForLower16Bate:wisd];
    requestModel.content = [item yy_modelToJSONString];
    requestModel.deviceID = [NetworkingTool getDeviceId];
    requestModel.requestBlock = block;
    NSString *json = [requestModel yy_modelToJSONString];

    // Client side sends a text message to the application server (P2Server)
    requestModel.msgid = (NSInteger)[self.rtcEngineKit sendServerMessage:json];

    NSString *key = requestModel.requestID;
    [self.senderDic setValue:requestModel forKey:key];
    [self addLog:@"sendServerMessage-" message:json];
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

+ (NSString *_Nullable)getSdkVersion {
    return [ByteRTCVideo getSdkVersion];
}

#pragma mark - ByteRTCVideoDelegate
// Receive RTS login result
- (void)rtcEngine:(ByteRTCVideo *)engine onLoginResult:(NSString *)uid errorCode:(ByteRTCLoginErrorCode)errorCode elapsed:(NSInteger)elapsed {
    if (self.rtcLoginBlock) {
        self.rtcLoginBlock((errorCode == ByteRTCLoginErrorCodeSuccess) ? YES : NO);
    }
}
// Receive the business server parameter setting result
- (void)rtcEngine:(ByteRTCVideo *)engine onServerParamsSetResult:(NSInteger)errorCode {
    if (self.rtcSetParamsBlock) {
        self.rtcSetParamsBlock((errorCode == RTSStatusCodeSuccess) ? YES : NO);
    }
}
// Receive RTC/RTS join room result
- (void)rtcEngine:(ByteRTCVideo *)engine onServerMessageSendResult:(int64_t)msgid error:(ByteRTCUserMessageSendResult)error message:(NSData *)message {
    if (error == ByteRTCUserMessageSendResultSuccess) {
        // Successfully sent, waiting for business callback information
    } else {
        // Failed to send
        NSString *key = @"";
        for (RTSRequestModel *model in self.senderDic.allValues) {
            if (model.msgid == msgid) {
                key = model.requestID;
                [self throwErrorAck:RTSStatusCodeSendMessageFaild
                            message:[NetworkingTool messageFromResponseCode:RTSStatusCodeSendMessageFaild]
                              block:model.requestBlock];
                NSLog(@"[%@]-RECEIVED %@ msgid %lld request_id %@ ErrorCode %ld", [self class], model.eventName, msgid, key, (long)error);
                break;
            }
        }
        if (NOEmptyStr(key)) {
            [self.senderDic removeObjectForKey:key];
        }

        if (error == ByteRTCUserMessageSendResultNotLogin) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoginExpired object:@"logout"];
            });
        }
    }
}

// Callback when receiving a message from outside the room
- (void)rtcEngine:(ByteRTCVideo *)engine onUserMessageReceivedOutsideRoom:(NSString *)uid message:(NSString *)message {
    [self dispatchMessageFrom:uid message:message];
    [self addLog:@"onUserMessageReceivedOutsideRoom-" message:message];
}

// SDK  connection state change callback with signaling server. Triggered when the connection state changes.
- (void)rtcEngine:(ByteRTCVideo *)engine connectionChangedToState:(ByteRTCConnectionState)state {
    if (state == ByteRTCConnectionStateDisconnected) {
        for (RTSRequestModel *requestModel in self.senderDic.allValues) {
            if (requestModel.requestBlock) {
                RTSACKModel *ackModel = [[RTSACKModel alloc] init];
                ackModel.code = 400;
                ackModel.message = LocalizedStringFromBundle(@"operation_failed_message", ToolKitBundleName);
                dispatch_async(dispatch_get_main_queue(), ^{
                    requestModel.requestBlock(ackModel);
                });
            }
        }
        [self.senderDic removeAllObjects];
    }
}

#pragma mark - ByteRTCRoomDelegate
// Receive RTC/RTS join room result
- (void)rtcRoom:(ByteRTCRoom *)rtcRoom onRoomStateChanged:(NSString *)roomId
               withUid:(NSString *)uid
                 state:(NSInteger)state
             extraInfo:(NSString *)extraInfo {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (state == ByteRTCErrorCodeDuplicateLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoginExpired object:@"logout"];
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
        [messageType isEqualToString:RTSMessageTypeResponse]) {
        [self receivedResponseFrom:uid object:dic];
        return;
    }

    if ([messageType isKindOfClass:[NSString class]] &&
        [messageType isEqualToString:RTSMessageTypeNotice]) {
        [self receivedNoticeFrom:uid object:dic];
        return;
    }
}
- (void)receivedResponseFrom:(NSString *)uid object:(NSDictionary *)object {
    RTSACKModel *ackModel = [RTSACKModel modelWithMessageData:object];
    if (IsEmptyStr(ackModel.requestID)) {
        return;
    }
    NSString *key = ackModel.requestID;
    RTSRequestModel *model = self.senderDic[key];
    if (model && [model isKindOfClass:[RTSRequestModel class]]) {
        if (model.requestBlock) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
                model.requestBlock(ackModel);
            });
        }
    }
    [self.senderDic removeObjectForKey:key];
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

#pragma mark - Getter

- (NSMutableDictionary *)listenerDic {
    if (!_listenerDic) {
        _listenerDic = [[NSMutableDictionary alloc] init];
    }
    return _listenerDic;
}

- (NSMutableDictionary *)senderDic {
    if (!_senderDic) {
        _senderDic = [[NSMutableDictionary alloc] init];
    }
    return _senderDic;
}

#pragma mark - Tool

- (void)addLog:(NSString *)key message:(NSString *)message {
    NSLog(@"[%@]-%@ %@", [self class], key, [NetworkingTool decodeJsonMessage:message]);
}

@end
