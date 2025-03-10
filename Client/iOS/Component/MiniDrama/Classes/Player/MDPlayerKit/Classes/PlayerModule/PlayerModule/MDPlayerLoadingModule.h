// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerLoadingViewProtocol;

@interface MDPlayerLoadingModule : MDPlayerBaseModule

@property (nonatomic, strong, readonly, nullable) UIView<MDPlayerLoadingViewProtocol> *loadingView;

- (UIView<MDPlayerLoadingViewProtocol> *)createLoadingView;

@end

NS_ASSUME_NONNULL_END
