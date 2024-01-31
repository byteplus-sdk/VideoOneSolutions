// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SmartSubtitleManager.h"
#import "SubtitleidType.h"
#import "VEInterfaceBaseVideoDetailSceneConf.h"

NS_ASSUME_NONNULL_BEGIN
@class VEVideoModel;

@protocol SmartSubtitleConfigureDelegate <NSObject>

- (void)switchSubtitleWithSubtitleId:(NSInteger)subtitleid;

@end

@interface VEInterfaceSmartSubtitleConf : VEInterfaceBaseVideoDetailSceneConf

@property (nonatomic, weak) SmartSubtitleManager *manager;

@end

NS_ASSUME_NONNULL_END
