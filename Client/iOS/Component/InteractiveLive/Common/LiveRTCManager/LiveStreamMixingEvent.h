// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <ToolKit/BaseRTCManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamMixingEvent : NSObject
@property (nonatomic, assign) ByteRTCMixedStreamTaskEvent event;
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, assign) ByteRTCMixedStreamTaskErrorCode code;
@property (nonatomic, assign) ByteRTCMixedStreamType mixType;
@end

NS_ASSUME_NONNULL_END
