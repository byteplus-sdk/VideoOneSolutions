// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;

@interface MDEventMessageBus : NSObject

+ (instancetype)universalBus;

+ (void)destroyUnit;

- (void)postEvent:(NSString *)eventKey withObject:(id)object rightNow:(BOOL)now;

- (void)registEvent:(NSString *)eventKey withAction:(SEL)selector ofTarget:(id)target;

@end
