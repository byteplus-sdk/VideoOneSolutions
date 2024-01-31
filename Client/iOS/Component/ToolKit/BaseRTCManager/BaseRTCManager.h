// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LocalUserComponent.h"
#import "NetworkingTool.h"
#import "PublicParameterComponent.h"
#import "RTCJoinModel.h"
#import "RTSACKModel.h"
#import "RTSNoticeModel.h"
#import "RTSRequestModel.h"
#import <BytePlusRTC/BytePlusRTC.h>
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RTCRoomMessageBlock)(RTSNoticeModel *noticeModel);

@interface BaseRTCManager : NSObject <ByteRTCVideoDelegate, ByteRTCRoomDelegate>

// Engine management
@property (nonatomic, strong, nullable) ByteRTCVideo *rtcEngineKit;

/**
 * @brief Open RTS connection
 * @param appID APPID, needed to initialize ByteRTCVideo.
 * @param RTSToken RTS token, required to join RTS room.
 * @param serverUrl RTS server address, required for setting application server parameters.
 * @param serverSig RTS signature, required for setting application server parameters.
 * @param bid business ID, different RTC configurations can be delivered according to different business IDs.
 * @param block open connection result callback
 */

- (void)connect:(NSString *)appID
       RTSToken:(NSString *)RTSToken
      serverUrl:(NSString *)serverUrl
      serverSig:(NSString *)serverSig
            bid:(NSString *)bid
          block:(void (^)(BOOL result))block;

/**
 * @brief Close the RTS connection
 */

- (void)disconnect;

/**
 * @brief Emit an RTS request
 * @param event request event KEY
 * @param item request parameter
 * @param block sends RTS request result callback
 */

- (void)emitWithAck:(NSString *)event
               with:(NSDictionary *)item
              block:(__nullable RTCSendServerMessageBlock)block;

/**
 * @brief Register RTS listener
 * @param key the key needed to register the listener
 * @param block callback when receiving listener
 */

- (void)onSceneListener:(NSString *)key
                  block:(RTCRoomMessageBlock)block;

/**
 * @brief Remove broadcast listener
 */

- (void)offSceneListener;

#pragma mark - Config

/**
 * @brief It will be called every time rtcEngineKit is initialized, and the subclass overrides the implementation.
 */

- (void)configeRTCEngine;

/**
 * @brief Get Sdk Version.
 */

+ (NSString *_Nullable)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
