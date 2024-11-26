// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceBaseVideoDetailSceneConf.h"
#import "PlayListManager.h"

NS_ASSUME_NONNULL_BEGIN
@class VEVideoModel;
@interface VEInterfacePlayListConf : VEInterfaceBaseVideoDetailSceneConf

@property (nonatomic, strong) PlayListManager *manager;

- (void)refresh;

@end

NS_ASSUME_NONNULL_END
