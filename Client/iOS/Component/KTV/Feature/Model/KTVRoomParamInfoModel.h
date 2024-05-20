// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVRoomParamInfoModel : NSObject
@property (nonatomic, assign) NSInteger txQuality;
@property (nonatomic, assign) NSInteger rxQuality;
@property (nonatomic, strong) NSString *rtt;

@end

NS_ASSUME_NONNULL_END
