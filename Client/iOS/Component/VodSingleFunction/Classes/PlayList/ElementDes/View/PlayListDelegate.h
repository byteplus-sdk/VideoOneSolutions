// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
NS_ASSUME_NONNULL_BEGIN
@class VEVideoModel;
@protocol PlayListDelegate <NSObject>

- (void)onChangeCurrentVideo:(VEVideoModel *)model index:(NSInteger)index;

@end
NS_ASSUME_NONNULL_END

