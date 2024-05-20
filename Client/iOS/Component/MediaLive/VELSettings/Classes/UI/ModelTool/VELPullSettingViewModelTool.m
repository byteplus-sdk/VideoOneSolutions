// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingViewModelTool.h"
#import <MediaLive/VELCommon.h>
#import "VELSettingConfig.h"
#import "VELPullABRSettingViewController.h"
#import <ToolKit/Localizator.h>
@interface VELPullSettingViewModelTool ()
@end
@implementation VELPullSettingViewModelTool

- (instancetype)init {
    if (self = [super init]) {
        self.config = VELSettingConfig.sharedConfig.pullConfig;
    }
    return self;
}

- (void)showQrScan {
    __weak __typeof__(self)weakSelf = self;
    [VELQRScanViewController showFromVC:nil
                             completion:^(VELQRScanViewController * _Nonnull vc, NSString * _Nonnull result) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self setupInputUrlWithText:result];
        [vc hide];
    }];
}

- (void)showABRConfig:(nullable VELPullABRUrlConfig *)abrUrlConfig btnModel:(nullable VELSettingsButtonViewModel *)btnModel {
    __weak __typeof__(self)weakSelf = self;
    if (!self.config.urlConfig.canAddABRConfig && !abrUrlConfig) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_all_abr_gear_setted", @"MediaLive") detailText:@""];
        return;
    }
    VELPullABRSettingViewController *abrVC = [VELPullABRSettingViewController abrSettingWithSettingConfig:self.config abrConfig:abrUrlConfig];
    [abrVC showFromVC:nil completion:^(VELPullABRSettingViewController * _Nonnull vc, VELPullABRUrlConfig * _Nonnull urlConfig) {
        __strong __typeof__(weakSelf)self = weakSelf;
        btnModel.title = [urlConfig shortDescription];
        [btnModel updateUI];
        [self.config addABRConfig:urlConfig];
        [self refreshUIWithModelConfigChanged];
        [vc hide];
    }];
}

- (void)clearABRConfig {
    [self.config clearABRConfig];
    [self refreshUIWithModelConfigChanged];
}

- (void)deleteABRConfig:(VELPullABRUrlConfig *)abrConfig {
    [self.config removeABRConfig:abrConfig];
    [self refreshUIWithModelConfigChanged];
}


- (void)setupInputUrlWithText:(NSString *)text {
    _config.urlConfig.url = text;
    [self refreshUIWithModelConfigChanged];
    [_config save];
}

- (void)refreshUIWithModelConfigChanged {
    _inputViewModel.urlType = _config.urlType;
    [_inputViewModel updateUI];
    _abrViewModel.on = _config.enableABR;
    [_abrViewModel updateUI];
    _config.suggestProtocol = _config.urlConfig.protocol;
    _config.suggestFormat = _config.urlConfig.format;
    _protocolViewModel.selectIndex = _config.suggestProtocol - 1;
    [_protocolViewModel updateUI];
    _formatViewModel.selectIndex = _config.suggestFormat - 1;
    [_formatViewModel updateUI];
}

- (VELSettingsPullInputViewModel *)inputViewModel {
    if (!_inputViewModel) {
        _inputViewModel = [VELSettingsPullInputViewModel modeWithTitle:LocalizedStringFromBundle(@"medialive_input_pull_address", @"MediaLive") placeHolder:LocalizedStringFromBundle(@"medialive_pull_address_placeholder", @"MediaLive")];
        _inputViewModel.showQRScan = YES;
        _inputViewModel.qrScanTip = LocalizedStringFromBundle(@"medialive_pull_scan_placeholder", @"MediaLive");
        __weak __typeof__(self)weakSelf = self;
        [_inputViewModel setQrScanActionBlock:^(VELSettingsInputViewModel * _Nonnull m) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self showQrScan];
        }];
        [_inputViewModel setTextDidChangedBlock:^(VELSettingsInputViewModel * _Nonnull m, NSString * _Nonnull text) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self setupInputUrlWithText:text];
        }];
        [_inputViewModel setAddAbrActionBlock:^(VELSettingsPullInputViewModel * _Nonnull model) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self showABRConfig:nil btnModel:nil];
        }];
        [_inputViewModel setClearAbrActionBlock:^(VELSettingsPullInputViewModel * _Nonnull model) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self clearABRConfig];
        }];
        [_inputViewModel setDidClickAbrConfigBlock:^(VELSettingsPullInputViewModel * _Nonnull model, VELSettingsButtonViewModel *btnModel, VELPullABRUrlConfig * _Nonnull urlConfig) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self showABRConfig:urlConfig btnModel:btnModel];
        }];
        [_inputViewModel setDeleteAbrConfigBlock:^(VELSettingsPullInputViewModel * _Nonnull model, VELSettingsButtonViewModel * _Nonnull btnModel, VELPullABRUrlConfig * _Nonnull cfg) {
            __strong __typeof__(weakSelf)self = weakSelf;
            [self deleteABRConfig:cfg];
        }];
    }
    _inputViewModel.mainUrlConfig = self.config.mainUrlConfig;
    _inputViewModel.urlType = self.config.urlType;
    return _inputViewModel;
}

- (VELSettingsPopChooseViewModel *)protocolViewModel {
    if (!_protocolViewModel) {
        __weak __typeof__(self)weakSelf = self;
        NSArray <NSString *> *titles = @[@"TCP", @"Quic", @"TLS"];
        NSArray <NSNumber *> *values = @[@(VELPullUrlProtocolTCP), @(VELPullUrlProtocolQuic), @(VELPullUrlProtocolTLS)];
        _protocolViewModel = [VELSettingsPopChooseViewModel createWhiteCommonMenuModelWithTitle:LocalizedStringFromBundle(@"medialive_protocol", @"MediaLive") menuTitles:titles menuValues:values selectBlock:^BOOL (NSInteger index, NSNumber * _Nonnull value) {
            __strong __typeof__(weakSelf)self = weakSelf;
            VELPullUrlProtocol protocol = [value integerValue];
            /// quic
            if (protocol == VELPullUrlProtocolQuic) {
                if (![self.config checkShouldOpentQuic]) {
                    [VELUIToast showText:LocalizedStringFromBundle(@"medialive_quick_check", @"MediaLive") detailText:@""];
                    return NO;
                }
            }
            self.config.suggestProtocol = protocol;
            return YES;
        }];
        _protocolViewModel.margin = UIEdgeInsetsZero;
        _protocolViewModel.insets = UIEdgeInsetsMake(10, 10, 10, 10);
        _protocolViewModel.size = CGSizeMake((VEL_DEVICE_WIDTH - 40), 52);
    }
    _protocolViewModel.selectIndex = self.config.suggestProtocol - 1;
    return _protocolViewModel;
}

- (VELSettingsPopChooseViewModel *)formatViewModel {
    if (!_formatViewModel) {
        __weak __typeof__(self)weakSelf = self;
        NSArray <NSString *> *titles = @[@"FLV", @"HLS", @"RTM"];
        NSArray <NSNumber *> *values = @[@(VELPullUrlFormatFLV), @(VELPullUrlFormatHLS), @(VELPullUrlFormatRTM)];
        _formatViewModel = [VELSettingsPopChooseViewModel createWhiteCommonMenuModelWithTitle:LocalizedStringFromBundle(@"medialive_format", @"MediaLive") menuTitles:titles menuValues:values selectBlock:^BOOL (NSInteger index, NSNumber * _Nonnull value) {
            __strong __typeof__(weakSelf)self = weakSelf;
            VELPullUrlFormat format = [value integerValue];
            if (self.config.suggestProtocol == VELPullUrlProtocolQuic && format != VELPullUrlFormatFLV) {
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_open_quick", @"MediaLive") detailText:@""];
                return NO;
            }
            self.config.suggestFormat = [value integerValue];
            return YES;
        }];
        _formatViewModel.margin = UIEdgeInsetsZero;
        _formatViewModel.insets = UIEdgeInsetsMake(10, 10, 10, 10);
        _formatViewModel.size = CGSizeMake((VEL_DEVICE_WIDTH - 40), 52);
    }
    _formatViewModel.selectIndex = self.config.suggestFormat - 1;
    return _formatViewModel;
}

- (VELSettingsSwitchViewModel *)abrViewModel {
    if (!_abrViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _abrViewModel = [self createSwitchViewModelWith:@"ABR" action:^(VELSettingsSwitchViewModel * _Nonnull model, BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.config.enableABR = isOn;
            [self.config save];
            [self refreshUIWithModelConfigChanged];
            if (!isOn) {
                self.resolutionDegradeViewModel.on = NO;
                self.config.enableAutoResolutionDegrade = NO;
            }
            [self.resolutionDegradeViewModel updateUI];
        }];
    }
    _abrViewModel.on = self.config.enableABR;
    return _abrViewModel;
}

- (VELSettingsSwitchViewModel *)resolutionDegradeViewModel {
    if (!_resolutionDegradeViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _resolutionDegradeViewModel = [self createSwitchViewModelWith:LocalizedStringFromBundle(@"medialive_auto_switch", @"MediaLive") action:^(VELSettingsSwitchViewModel * _Nonnull model, BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (!self.abrViewModel.isOn) {
                model.on = NO;
                [model updateUI];
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_open_abr_toast", @"MediaLive") detailText:@""];
                return;
            }
            self.config.enableAutoResolutionDegrade = isOn;
            [self refreshUIWithModelConfigChanged];
            [self.config save];
        }];
    }
    _resolutionDegradeViewModel.on = self.config.enableAutoResolutionDegrade && self.config.enableABR;
    return _resolutionDegradeViewModel;
}

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

#define VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(title, p, cfg_p) VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE_ACTION(title, p, cfg_p, ^(VELPullSettingViewModelTool * tool, BOOL ret){});

- (VELSettingsSwitchViewModel *)createSwitchViewModelWith:(NSString *)title action:(void (^)(VELSettingsSwitchViewModel * _Nonnull model, BOOL isOn))action {
    VELSettingsSwitchViewModel *viewModel = [[VELSettingsSwitchViewModel alloc] init];
    viewModel.margin = UIEdgeInsetsZero;
    viewModel.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    viewModel.hasBorder = YES;
    viewModel.hasShadow = YES;
    viewModel.title = title;
    viewModel.lightStyle = YES;
    viewModel.titleAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    viewModel.titleAttribute[NSForegroundColorAttributeName] = UIColor.blackColor;
    viewModel.size = CGSizeMake((VEL_DEVICE_WIDTH - 40), 52);
    [viewModel setSwitchModelBlock:action];
    return viewModel;
}

VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"SEI", seiViewModel, enableSEI);
VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(LocalizedStringFromBundle(@"medialive_rtm_add_flv", @"MediaLive"), rtmAutoDowngradeViewModel, rtmAutoDowngrade);

@end
