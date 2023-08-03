// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuLoginHome : NSObject

/**
 * @brief Show login screen
 * @param isAnimation Whether to display animation
 */

+ (void)showLoginViewControllerAnimated:(BOOL)isAnimation;

/**
 * @brief Close account api
 * @param block callback
 */

+ (void)closeAccount:(void (^)(BOOL result))block;

@end

NS_ASSUME_NONNULL_END
