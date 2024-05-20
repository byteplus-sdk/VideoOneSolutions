// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingsViewController.h"
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import "VELPullSettingViewModelTool.h"
#import "VELSettingsCollectionView.h"
#import "VELSettingConfig.h"
#import <ToolKit/Localizator.h>
@interface VELPullSettingsViewController ()
@property (nonatomic, strong) NSMutableArray <__kindof VELSettingsBaseViewModel *> *settingModels;
@property (nonatomic, strong) VELUIButton *startPlayBtn;
@property (nonatomic, strong) VELSettingsCollectionView *settingCollectionView;
@property (nonatomic, strong) VELPullSettingViewModelTool *modelTool;
@end

@implementation VELPullSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelTool = [[VELPullSettingViewModelTool alloc] init];
    if (self.config == nil) {
        self.config = self.modelTool.config;
    } else {
        self.modelTool.config = self.config;
    }
    [self reSetupUI];
}

- (void)setconfig:(VELPullSettingConfig *)config {
    _config = config;
    self.modelTool.config = config;
    if (self.settingType == VELPullSettingsTypeNormal) {
        [self.modelTool.inputViewModel updateUI];
    }
    [self setupSettingsModels];
    [self.settingCollectionView reloadData];
}

- (void)reSetupUI {
    self.settingModels = [NSMutableArray arrayWithCapacity:20];
    [self setupUI];
    [self setupSettingsModels];
}

- (void)setupSettingsModels {
    if (!self.settingModels) {
        self.settingModels = [NSMutableArray arrayWithCapacity:10];
    } else {
        [self.settingModels removeAllObjects];
    }
    if (self.settingType == VELPullSettingsTypeNormal) {
        /// abr
        [self.settingModels addObject:self.modelTool.abrViewModel];
        [self.settingModels addObject:self.modelTool.resolutionDegradeViewModel];
    }
    [self.settingModels addObject:self.modelTool.protocolViewModel];
    [self.settingModels addObject:self.modelTool.formatViewModel];
    
    if (self.settingType == VELPullSettingsTypeNormal) {
        if (self.config.isNewApi) {
            [self.settingModels addObject:self.modelTool.seiViewModel];
        }
    }
    self.settingCollectionView.models = self.settingModels;
}

- (void)startPlayBtnAction {
    [self.view endEditing:YES];
    if (!self.config.mainUrlConfig.isValid) {
        if (self.config.mainUrlConfig.enableABR) {
            NSString *info = LocalizedStringFromBundle(@"medialive_abr_gear_setting", @"MediaLive");
            if (self.config.mainUrlConfig.abrUrlConfigs.count == 0) {
                info = LocalizedStringFromBundle(@"medialive_abr_gear_setting", @"MediaLive");
            } else if (self.config.mainUrlConfig.getDefaultABRConfig == nil) {
                info =  LocalizedStringFromBundle(@"medialive_abr_resolution_setting", @"MediaLive");
            } else if (self.config.mainUrlConfig.getOriginABRConfig == nil) {
                info = LocalizedStringFromBundle(@"medialive_abr_source_setting", @"MediaLive");
            } else {
                info = LocalizedStringFromBundle(@"medialive_abr_bitrate_error", @"MediaLive");
            }
            [VELUIToast showText:@"%@", info];
        } else {
            [VELUIToast showText: LocalizedStringFromBundle(@"medialive_no_pull_address", @"MediaLive") detailText:@""];
        }
        self.config.urlType = VELPullUrlTypeMain;
        [self.modelTool refreshUIWithModelConfigChanged];
        return;
    }
    if (self.startBlock) {
        self.startBlock();
    }
}
- (void)setupUI {
    [self.navigationBar onlyShowLeftBtn];
    UIView *topContainer = [[UIView alloc] init];
    VELSettingsInputViewModel *inputModel = self.modelTool.inputViewModel;
    UIView *settingView = inputModel.settingView;
    [topContainer addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(topContainer);
        make.height.equalTo(@(290.0));
    }];
    
    [topContainer addSubview:self.startPlayBtn];
    [self.startPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(topContainer);
        make.top.equalTo(settingView.mas_bottom).mas_offset(24);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(topContainer).mas_offset(-8);
    }];
    
    [self.view addSubview:topContainer];
    [topContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).mas_offset(14);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).mas_offset(-14);
        } else {
            make.left.equalTo(self.view).mas_offset(14);
            make.right.equalTo(self.view).mas_offset(-14);
        }
    }];
    
    [self.view addSubview:self.settingCollectionView];
    [self.settingCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContainer.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).mas_offset(14);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).mas_offset(-14);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.left.equalTo(self.view).mas_offset(14);
            make.right.equalTo(self.view).mas_offset(-14);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
    }];
}

- (VELUIButton *)startPlayBtn {
    if (!_startPlayBtn) {
        _startPlayBtn = [[VELUIButton alloc] init];
        _startPlayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_startPlayBtn setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _startPlayBtn.cornerRadius = 24;
        _startPlayBtn.backgroundColor = VELColorWithHex(0x2C5BF6);
        [_startPlayBtn setTitle:LocalizedStringFromBundle(@"medialive_start_play", @"MediaLive") forState:(UIControlStateNormal)];
        [_startPlayBtn addTarget:self action:@selector(startPlayBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _startPlayBtn;
}

- (VELSettingsCollectionView *)settingCollectionView {
    if (!_settingCollectionView) {
        _settingCollectionView = [[VELSettingsCollectionView alloc] init];
        _settingCollectionView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _settingCollectionView.layoutMode = VELCollectionViewLayoutModeCenter;
    }
    return _settingCollectionView;
}
@end
