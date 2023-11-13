// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;

/**
 * @brief A message router implementation. You can post messages with specific eventkey to any targets who subscribe this key with solid function.
 */

@interface VEEventMessageBus : NSObject

- (void)destroyUnit;

/**
 * @brief Post event with some body, and will call the targets immediately.
 * @param eventKey: key for this message.
 * @param object: message body, can be any form.
 * @param now: currently is not working, message will be deliver immediately.
 */

- (void)postEvent:(NSString *)eventKey withObject:(id)object rightNow:(BOOL)now;

/**
 * @brief Subscribe some eventkey with solid action. When this event has been posted, the action will be called immediately.
 * @param eventKey: key for this message.
 * @param selector: action function for this eventkey.
 * @param target: the target of this action. Like someclassInstance.someFunction.
 */

- (void)registEvent:(NSString *)eventKey withAction:(SEL)selector ofTarget:(id)target;

@end
