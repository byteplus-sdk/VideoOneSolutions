// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <MediaLive/VELCommon.h>
#import "VELPushSettingConfig.h"
NS_ASSUME_NONNULL_BEGIN
@class VELPushSettingViewController;
@protocol VELPushSettingProtocol <NSObject>
- (void)pushSetting:(VELPushSettingViewController *)vc onRenderModeChanged:(VELSettingPreviewRenderMode)renderMode;
@end

@interface VELPushSettingViewController : VELUIViewController
@property (nonatomic, weak) id <VELPushSettingProtocol> delegate;
@property (nonatomic, strong) VELPushSettingConfig *pushConfig;
@property (nonatomic, assign, getter=isShowing) BOOL showing;
@property(nonatomic, copy) void (^reconfigCaptureBlock)(VELPushSettingConfig *pushConfig);
@property(nonatomic, copy) void (^reconfigStreamBlock)(VELPushSettingConfig *pushConfig);

- (void)showFromVC:(nullable UIViewController *)vc
        completion:(void (^)(VELPushSettingViewController *vc, VELPushSettingConfig *config))completion;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
