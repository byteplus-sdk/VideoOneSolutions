// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushSettingViewModelTool.h"
#import "VELSettingConfig.h"
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>

@implementation VELPushSettingViewModelTool
- (instancetype)init {
    if (self = [super init]) {
        self.config = [VELSettingConfig.sharedConfig getPushSettingConfigWithCaptureType:(VELSettingCaptureTypeInner)];
    }
    return self;
}


- (VELSettingsInputViewModel *)inputViewModel {
    if (!_inputViewModel) {
        _inputViewModel = [VELSettingsInputViewModel modeWithTitle:@"" placeHolder:LocalizedStringFromBundle(@"medialive_input_push_address", @"MediaLive")];
        _inputViewModel.showQRScan = YES;
        _inputViewModel.backgroundColor = UIColor.clearColor;
        _inputViewModel.textAttribute[NSForegroundColorAttributeName] = [UIColor whiteColor];
        _inputViewModel.containerBackgroundColor = VELColorWithHexString(@"#535552");
        _inputViewModel.containerSelectBackgroundColor = VELColorWithHexString(@"#535552");
        _inputViewModel.cornerRadius = 5;
        _inputViewModel.hasBorder = YES;
        _inputViewModel.textInset = UIEdgeInsetsMake(6, 6, 6, 6);
        _inputViewModel.qRScanInContainer = YES;
        _inputViewModel.qrScanIcon = [_inputViewModel.qrScanIcon vel_imageByTintColor:UIColor.whiteColor];
        _inputViewModel.insets = UIEdgeInsetsZero;
        _inputViewModel.spacingBetweenTitleAndInput = 0;
        _inputViewModel.spacingBetweenQRAndInput = 0;
        _inputViewModel.placeHolderAttribute[NSForegroundColorAttributeName] = [UIColor.whiteColor colorWithAlphaComponent:0.3];
        _inputViewModel.margin = UIEdgeInsetsMake(0, 16, 0, 16);
        _inputViewModel.text = self.config.originUrlString;
        __weak __typeof__(self)weakSelf = self;
        [_inputViewModel setQrScanActionBlock:^(VELSettingsInputViewModel * _Nonnull model) {
            [VELQRScanViewController showFromVC:nil
                                     completion:^(VELQRScanViewController * _Nonnull vc, NSString * _Nonnull result) {
                __strong __typeof__(weakSelf)self = weakSelf;
                [self setupPushUrlWithString:[result vel_trim]];
                [vc hide];
            }];
        }];
        [_inputViewModel setTextDidChangedBlock:^(VELSettingsInputViewModel * _Nonnull model, NSString * _Nonnull text) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self setupPushUrlWithString:text];
        }];
    }
    _inputViewModel.text = self.config.originUrlString;
    return _inputViewModel;
}

- (void)setupPushUrlWithString:(NSString *)str {
    [self.config setupUrlsWithString:str];
    _inputViewModel.text = str;
    [_inputViewModel updateUI];
    [self.config save];
}
#define VEL_COMMON_POPCHOSE_VIEW_MODEL_ACTION(p, cfg_p, title, titles, values, block) \
- (VELSettingsPopChooseViewModel *)p { \
if (!_##p) { \
__weak __typeof__(self)weakSelf = self; \
_##p = [VELSettingsPopChooseViewModel createCommonMenuModelWithTitle:title \
menuTitles:(titles) \
menuValues:(values) \
selectBlock:^BOOL(NSInteger index, NSNumber *value) { \
__strong __typeof__(weakSelf)self = weakSelf; \
self.config.cfg_p = [value integerValue]; \
[self.config save]; \
if (block != nil) { return block(self); } \
return YES;\
}]; \
} \
_##p.insets = UIEdgeInsetsMake(10, 10, 10, 10); \
_##p.size = CGSizeMake((VEL_DEVICE_WIDTH - 32), 52); \
_##p.selectIndex = [values indexOfObject:@(self.config.cfg_p)]; \
return _##p; \
}

#define VEL_COMMON_POPCHOSE_VIEW_MODEL(p, cfg_p, title, titles, values) \
VEL_COMMON_POPCHOSE_VIEW_MODEL_ACTION(p, cfg_p, title, titles, values, ^BOOL (id obj){return YES;})


#define VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE_ACTION(title, p, cfg_p, block) \
- (VELSettingsSwitchViewModel *)p { \
if (!_##p) { \
__weak __typeof__(self)weakSelf = self; \
_##p = [self createSwitchViewModelWith:title action:^(VELSettingsSwitchViewModel * _Nonnull model, BOOL isOn) { \
__strong __typeof__(weakSelf)self = weakSelf; \
self.config.cfg_p = isOn; \
block(self, isOn); \
[self.config save]; \
}]; \
} \
_##p.on = self.config.cfg_p; \
return _##p; \
}

#define VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(title, p, cfg_p) VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE_ACTION(title, p, cfg_p, ^(id obj, BOOL ret){});

VEL_COMMON_POPCHOSE_VIEW_MODEL(captureResolutionViewModel,
                               captureResolutionType,
                               LocalizedStringFromBundle(@"medialive_setting_capture_resolution", @"MediaLive"),
                               (@[@"360P", @"480P", @"540P", @"720P", @"1080P"]),
                               (@[@(VELSettingResolutionType_360),
                                  @(VELSettingResolutionType_480),
                                  @(VELSettingResolutionType_540),
                                  @(VELSettingResolutionType_720),
                                  @(VELSettingResolutionType_1080)]));

VEL_COMMON_POPCHOSE_VIEW_MODEL(captureFPSViewModel,
                               captureFPS,
                               LocalizedStringFromBundle(@"medialive_setting_capture_fps", @"MediaLive"),
                               (@[@"15", @"20", @"25", @"30"]),
                               (@[@(15), @(20), @(25), @(30)]));



VEL_COMMON_POPCHOSE_VIEW_MODEL_ACTION(encodeResolutionViewModel,
                                      encodeResolutionType,
                                      LocalizedStringFromBundle(@"medialive_setting_encode_resolution", @"MediaLive"),
                                      (@[@"360P", @"480P", @"540P", @"720P", @"1080P"]),
                                      (@[@(VELSettingResolutionType_360),
                                         @(VELSettingResolutionType_480),
                                         @(VELSettingResolutionType_540),
                                         @(VELSettingResolutionType_720),
                                         @(VELSettingResolutionType_1080)]),
                                      ^BOOL (VELPushSettingViewModelTool *tool) {
    [tool.encodeBitrateViewModel updateUI];
    return YES;
});

VEL_COMMON_POPCHOSE_VIEW_MODEL_ACTION(encodeResolutionAndScreenViewModel,
                                      encodeResolutionType,
                                      LocalizedStringFromBundle(@"medialive_setting_encode_resolution", @"MediaLive"),
                                      (@[@"360P", @"480P", @"540P", @"720P", @"1080P",  LocalizedStringFromBundle(@"medialive_setting_screen_size", @"MediaLive")]),
                                      (@[@(VELSettingResolutionType_360),
                                         @(VELSettingResolutionType_480),
                                         @(VELSettingResolutionType_540),
                                         @(VELSettingResolutionType_720),
                                         @(VELSettingResolutionType_1080),
                                         @(VELSettingResolutionType_Screen)
                                       ]),
                                      ^BOOL (VELPushSettingViewModelTool *tool) {
    [tool.encodeBitrateViewModel updateUI];
    return YES;
});


VEL_COMMON_POPCHOSE_VIEW_MODEL(encodeFPSViewModel,
                               encodeFPS,
                               LocalizedStringFromBundle(@"medialive_setting_encode_fps", @"MediaLive"),
                               (@[@"15", @"20", @"25", @"30"]),
                               (@[@(15), @(20), @(25), @(30)]));


VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(LocalizedStringFromBundle(@"medialive_setting_fix_av_diff", @"MediaLive"), fixScreenCaptureVideoAudioDiffViewModel, enableFixScreenCaptureVideoAudioDiff);

VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(LocalizedStringFromBundle(@"medialive_setting_abr", @"MediaLive"), enableAutoBitrateViewModel, enableAutoBitrate);

VEL_COMMON_POPCHOSE_VIEW_MODEL(renderModeViewModel,
                               renderMode,
                               LocalizedStringFromBundle(@"medialive_setting_render_mode", @"MediaLive"),
                               (@[LocalizedStringFromBundle(@"medialive_setting_render_fill", @"MediaLive"), LocalizedStringFromBundle(@"medialive_setting_render_hidden", @"MediaLive"), LocalizedStringFromBundle(@"medialive_setting_render_fit", @"MediaLive")]),
                               (@[@(VELSettingPreviewRenderModeFill),
                                  @(VELSettingPreviewRenderModeHidden),
                                  @(VELSettingPreviewRenderModeFit)]));
- (VELSettingsSwitchViewModel *)createSwitchViewModelWith:(NSString *)title action:(void (^)(VELSettingsSwitchViewModel * _Nonnull model, BOOL isOn))action {
    VELSettingsSwitchViewModel *viewModel = [[VELSettingsSwitchViewModel alloc] init];
    viewModel.backgroundColor = UIColor.clearColor;
    viewModel.titleAttribute[NSForegroundColorAttributeName] = UIColor.whiteColor;
    viewModel.containerBackgroundColor = [VELColorWithHexString(@"#535552") colorWithAlphaComponent:0.8];
    viewModel.containerSelectBackgroundColor = [VELColorWithHexString(@"#535552") colorWithAlphaComponent:0.8];
    viewModel.margin = UIEdgeInsetsZero;
    viewModel.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    viewModel.hasBorder = NO;
    viewModel.hasShadow = NO;
    viewModel.title = title;
    viewModel.lightStyle = NO;
    viewModel.size = CGSizeMake((VEL_DEVICE_WIDTH - 32), 52);
    [viewModel setSwitchModelBlock:action];
    return viewModel;
}

@end

