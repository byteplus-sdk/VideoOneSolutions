// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSwitchView.h"
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import "VELSettingsButtonViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELSettingsSwitchView ()
@property (nonatomic, strong) VELUISwitch *switchView;
@property (nonatomic, strong) UIView *labelContainer;
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELUILabel *desLabel;
@property (nonatomic, strong) VELSettingsButtonViewModel *buttonModel;
@end
@implementation VELSettingsSwitchView

- (void)initSubviewsInContainer:(UIView *)container {
    UIView *labelContainer = [[UIView alloc] init];
    self.labelContainer = labelContainer;
    [labelContainer addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(labelContainer);
    }];
    [labelContainer addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(labelContainer);
        make.left.equalTo(self.titleLabel.mas_right).mas_offset(11);
    }];
    [container addSubview:labelContainer];
    [labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(container).mas_offset(self.model.insets.top);
        make.left.equalTo(container).mas_offset(self.model.insets.left);
        make.bottom.equalTo(container).mas_offset(-self.model.insets.bottom);
    }];
    [container addSubview:self.switchView];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(labelContainer.mas_right).offset(8);
        make.centerY.equalTo(container);
        make.right.equalTo(container).offset(-self.model.insets.right);
    }];
    UIView *buttonView = self.buttonModel.settingView;
    __weak __typeof__(self)weakSelf = self;
    [self.buttonModel setSelectedBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (self.model.switchBlock) {
            self.model.switchBlock(YES);
        }
    }];
    buttonView.hidden = YES;
    [container addSubview:buttonView];
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(labelContainer.mas_right).offset(8);
        make.centerY.equalTo(container);
        make.right.equalTo(container).offset(-self.model.insets.right);
        make.size.mas_equalTo(CGSizeMake(48, 30));
    }];
}


- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    self.buttonModel.title = self.model.btnTitle;
    [self.buttonModel updateUI];
    if (VEL_IS_EMPTY_STRING(self.model.des)) {
        [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.labelContainer);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.labelContainer);
        }];
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self.labelContainer);
        }];
        [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.labelContainer);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(11);
        }];
    }
    [self.labelContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(self.model.insets.top);
        make.left.equalTo(self.container).mas_offset(self.model.insets.left);
        make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
    }];
    
    if (self.model.convertToBtn) {
        [self.switchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self.container);
        }];
        [self.buttonModel.settingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.labelContainer.mas_right).offset(8);
            make.centerY.equalTo(self.container);
            make.right.equalTo(self.container).offset(-self.model.insets.right);
            make.height.mas_equalTo(30);
        }];
    } else {
        [self.buttonModel.settingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self.container);
        }];
        [self.switchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.model.switchSize);
            make.centerY.equalTo(self.container);
            make.right.equalTo(self.container).offset(-self.model.insets.right);
        }];
    }

}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    self.switchView.onTintColor = self.model.onTintColor;
    self.switchView.onThumbTintColor = self.model.onThumbColor;
    self.switchView.onBorderColor = self.model.onBorderColor;
    self.switchView.offTintColor = self.model.offTintColor;
    self.switchView.offThumbTintColor = self.model.offThumbColor;
    self.switchView.offBorderColor = self.model.offBorderColor;
    self.titleLabel.textAttributes = self.model.titleAttribute;
    self.titleLabel.text = self.model.title;
    [self.titleLabel sizeToFit];
    self.desLabel.text = self.model.des;
    [self.desLabel sizeToFit];
    self.switchView.on = self.model.isOn;
    self.switchView.hidden = self.model.convertToBtn;
    self.switchView.enabled = self.model.enable;
    self.buttonModel.settingView.hidden = !self.model.convertToBtn;
}

- (void)switchViewAction:(VELUISwitch *)switchView {
    self.model.on = switchView.isOn;
    if (self.model.switchModelBlock) {
        self.model.switchModelBlock(self.model, switchView.isOn);
    } else if (self.model.switchBlock) {
        self.model.switchBlock(switchView.isOn);
    }
}

- (VELUISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[VELUISwitch alloc] init];
        _switchView.backgroundColor = UIColor.clearColor;
        _switchView.onTintColor = UIColor.clearColor;
        _switchView.onBorderColor = UIColor.whiteColor;
        _switchView.onThumbTintColor = UIColor.whiteColor;
        _switchView.offTintColor = UIColor.clearColor;
        _switchView.offBorderColor = VELColorWithHexString(@"#636363");
        _switchView.offThumbTintColor = VELColorWithHexString(@"#636363");
        [_switchView addTarget:self action:@selector(switchViewAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _switchView;
}

- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [self createLabelWithDefaultConfig];
    }
    return _titleLabel;
}

- (VELUILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [self createLabelWithDefaultConfig];
    }
    return _desLabel;
}

- (VELSettingsButtonViewModel *)buttonModel {
    if (!_buttonModel) {
        _buttonModel = [[VELSettingsButtonViewModel alloc] init];
        _buttonModel.titleAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
        _buttonModel.titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _buttonModel.selectTitleAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
        _buttonModel.selectTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        _buttonModel.userInteractionEnabled = YES;
        _buttonModel.backgroundColor = UIColor.clearColor;
        _buttonModel.margin = UIEdgeInsetsZero;
        _buttonModel.insets = UIEdgeInsetsMake(0, 5, 0, 5);
        _buttonModel.containerBackgroundColor = VELColorWithHexString(@"#535552");
        _buttonModel.containerSelectBackgroundColor = VELColorWithHexString(@"#535552");
        _buttonModel.cornerRadius = 5;
        _buttonModel.title = LocalizedStringFromBundle(@"medialive_intercept", @"MediaLive");
    }
    return _buttonModel;
}

- (VELUILabel *)createLabelWithDefaultConfig {
    VELUILabel *label = [[VELUILabel alloc] init];
    [label setContentCompressionResistancePriority:(UILayoutPriorityRequired)
                                           forAxis:(UILayoutConstraintAxisHorizontal)];
    label.textAttributes = @{
        NSFontAttributeName : [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName : UIColor.whiteColor
    }.mutableCopy;
    return label;
}
@end
