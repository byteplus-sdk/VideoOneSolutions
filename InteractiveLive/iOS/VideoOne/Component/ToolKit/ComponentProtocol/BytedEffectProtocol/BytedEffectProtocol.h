// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@class BytedEffectProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol BytedEffectDelegate <NSObject>

- (instancetype)protocol:(BytedEffectProtocol *)protocol
    initWithRTCEngineKit:(id)rtcEngineKit;

- (void)protocol:(BytedEffectProtocol *)protocol
    showWithView:(UIView *)superView
    dismissBlock:(void (^)(BOOL result))block;

- (void)protocol:(BytedEffectProtocol *)protocol resume:(BOOL)result;

- (void)protocol:(BytedEffectProtocol *)protocol reset:(BOOL)result;

@end

@interface BytedEffectProtocol : NSObject


/**
 * @brief Initialization
 * @param rtcEngineKit Rtc Engine
 */

- (instancetype)initWithRTCEngineKit:(id)rtcEngineKit;


/**
 * @brief Show effect beauty view
 * @param superView Super view
 * @param block Dismiss Callback
 */

- (void)showWithView:(UIView *)superView
        dismissBlock:(void (^)(BOOL result))block;


/**
 * @brief Resume the last selected beauty
 */

- (void)resume;

/**
 * @brief Reset the last selected beauty
 */

- (void)reset;

@end

NS_ASSUME_NONNULL_END
