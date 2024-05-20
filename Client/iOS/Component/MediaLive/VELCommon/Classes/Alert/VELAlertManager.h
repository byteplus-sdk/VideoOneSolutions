// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELAlertAction.h"

@interface VELAlertManager : NSObject

/*
 * Alert Singletons
 */
+ (VELAlertManager *)shareManager;

/*
 * Show Alert window
 * @param message Prompt information
 */
- (void)showWithMessage:(NSString *)message;

/*
 * Show Alert window
 * @param message Prompt information
 * @param actions Button model
 */
- (void)showWithMessage:(NSString *)message actions:(NSArray<VELAlertAction *> *)actions;

/*
 * Show Alert window
 * @param message Prompt information
 * @param actions Button model
 * @param hideDelay dismiss delay, if <= 0 keep show
 */
- (void)showWithMessage:(NSString *)message actions:(NSArray<VELAlertAction *> *)actions hideDelay:(NSTimeInterval)delay;

/*
 * Dismiss Alert window
 * @param message Prompt information
 * @param actions Button model
 */
- (void)dismissAllAlert;

@end

