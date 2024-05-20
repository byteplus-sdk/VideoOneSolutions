// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

@class BytedEffectProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EffectType) {
    EffectTypeUnknown = 0,
    EffectTypeRTC = 1,
    EffectTypeMediaLive = 2
};
@protocol BytedEffectComponentDelegate <NSObject>

- (instancetype)protocol:(BytedEffectProtocol *)protocol
          initWithEngine:(id)engine
                useCache:(BOOL)useCache;

- (void)protocol:(BytedEffectProtocol *)protocol
    showWithView:(UIView *)superView
    dismissBlock:(void (^)(BOOL result))block;

- (void)protocol:(BytedEffectProtocol *)protocol resume:(BOOL)result;

- (void)protocol:(BytedEffectProtocol *)protocol reset:(BOOL)result;

@end

@interface BytedEffectProtocol : NSObject

- (instancetype) initWithEngine:(id)engine
            withType:(EffectType)type
                useCache:(BOOL)useCache;

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
