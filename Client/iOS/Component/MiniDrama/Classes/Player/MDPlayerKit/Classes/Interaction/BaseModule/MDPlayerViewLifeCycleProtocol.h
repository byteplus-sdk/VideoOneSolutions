// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerViewLifeCycleProtocol <NSObject>

- (void)viewDidLoad;

- (void)controlViewTemplateDidUpdate;

@end

NS_ASSUME_NONNULL_END
