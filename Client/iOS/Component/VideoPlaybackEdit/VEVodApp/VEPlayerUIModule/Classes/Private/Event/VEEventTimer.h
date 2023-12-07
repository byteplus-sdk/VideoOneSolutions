// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@interface VEEventTimer : NSObject

- (void)addTarget:(id)target action:(SEL)selector loopInterval:(NSInteger)ms; // millisecond

- (void)removeTarget:(id)target ofAction:(SEL)selector;

- (void)restart;

- (void)stop;

@end
