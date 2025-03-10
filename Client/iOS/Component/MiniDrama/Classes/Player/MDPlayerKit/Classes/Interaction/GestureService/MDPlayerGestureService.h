// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerGestureServiceInterface.h"
#import "MDPlayerInteractionDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @locale zh
 * @type api
 * @brief 手势管理 service，请参考MDPlayerContext的DI接口获取该服务
 */
@interface MDPlayerGestureService : NSObject <MDPlayerGestureServiceInterface>

@property (nonatomic, strong) UIView *gestureView;

@end

NS_ASSUME_NONNULL_END
