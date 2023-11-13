// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginProtocol <NSObject>

/**
 * @brief Show login screen if need
 * @param isAnimation Whether to display animation
 */

+ (BOOL)showLoginVCIfNeed:(BOOL)isAnimation;

/**
 * @brief Show login screen
 * @param isAnimation Whether to display animation
 */

+ (void)showLoginVCAnimated:(BOOL)isAnimation;

/**
 * @brief Close account api
 * @param block callback
 */

+ (void)closeAccount:(void (^__nullable)(BOOL result))block;

@end

@interface LoginComponent : NSObject <LoginProtocol>

@end

NS_ASSUME_NONNULL_END
