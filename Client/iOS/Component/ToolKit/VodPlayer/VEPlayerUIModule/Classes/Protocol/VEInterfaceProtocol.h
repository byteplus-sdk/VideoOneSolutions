// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol VEInterfaceElementDescription;
@class VEEventMessageBus, VEEventPoster;

@protocol VEInterfaceElementDataSource <NSObject>
// Return all the elements you want, which you will fill into the scene would be create.
- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements;

- (VEEventMessageBus *)eventMessageBus;

- (VEEventPoster *)eventPoster;

/**
 * @brief Set deactive state so that you can disable some actions which bind with this dataSource.
 * Default to NO, do not change this value until necessary.
 */

@property (nonatomic, assign) BOOL deactive;

@end
