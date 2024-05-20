// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELBasicSettingPlayInfoViewModel.h"
#import <ToolKit/Localizator.h>

@implementation VELBasicSettingPlayInfoViewModel
- (void)setupSettingsView {
    
    UIView *settingView = [[UIView alloc] init];
    UIView *lastSettingView = nil;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.settingsView);
        make.height.mas_equalTo(1);
    }];
    lastSettingView = settingView;
    
    settingView = self.cyclInfoViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom);
        make.left.equalTo(self.settingsView);
    }];
    lastSettingView = settingView;
    
    settingView = self.callBackNoteViewModel.settingView;
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom);
        make.left.equalTo(self.settingsView);
    }];
    lastSettingView = settingView;
    settingView = [[UIView alloc] init];
    [self.settingsView addSubview:settingView];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastSettingView.mas_bottom).mas_offset(10);
        make.left.equalTo(lastSettingView);
        make.bottom.equalTo(self.settingsView).mas_offset(-10);
        make.height.mas_equalTo(1);
    }];
}

- (void)setupViewModels {
    __weak __typeof__(self)weakSelf = self;
    VELSettingsButtonViewModel *btnModel = [VELSettingsButtonViewModel checkBoxModelWithTitle:LocalizedStringFromBundle(@"medialive_cycle_info", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (model.isSelected) {
            if ([self.delegate respondsToSelector:@selector(showCycleInfo)]) {
                [self.delegate showCycleInfo];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(hideCycleInfo)]) {
                [self.delegate hideCycleInfo];
            }
        }
    }];
    btnModel.margin = UIEdgeInsetsMake(11, 10, 8, 10);
    btnModel.size = CGSizeMake(VELAutomaticDimension, 27);
    self.cyclInfoViewModel = btnModel;
    
    btnModel = [VELSettingsButtonViewModel checkBoxModelWithTitle:LocalizedStringFromBundle(@"medialive_callback_info", @"MediaLive") action:^(VELSettingsButtonViewModel *model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (model.isSelected) {
            if ([self.delegate respondsToSelector:@selector(showCallbackNote)]) {
                [self.delegate showCallbackNote];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(hideCallbackNote)]) {
                [self.delegate hideCallbackNote];
            }
        }
    }];
    btnModel.margin = UIEdgeInsetsMake(8, 10, 8, 10);
    btnModel.size = CGSizeMake(VELAutomaticDimension, 27);
    self.callBackNoteViewModel = btnModel;
}

@end
