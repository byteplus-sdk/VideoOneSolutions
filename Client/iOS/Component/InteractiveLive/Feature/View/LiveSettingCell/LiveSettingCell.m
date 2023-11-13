// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingCell.h"

@interface LiveSettingCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UISwitch *switchView;

@end

@implementation LiveSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)createUIComponent {
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(16);
        make.top.mas_equalTo(self.contentView).offset(16);
        make.width.mas_equalTo(250);
    }];
    [self.contentView addSubview:self.descriptionLabel];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.width.mas_equalTo(250);
    }];
    [self.contentView addSubview:self.switchView];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(16);
        make.right.mas_equalTo(self.contentView).offset(-16);
    }];
}

- (void)setCellType:(LiveSettingCellType)cellType {
    _cellType = cellType;
    switch (cellType) {
        case LiveSettingRTMPullStreaming: {
            self.titleLabel.text = LocalizedString(@"rtm_pull_streaming");
            self.descriptionLabel.text = LocalizedString(@"rtm_pull_streaming_des");
            break;
        }
        case LiveSettingRTMPushStreaming: {
            self.titleLabel.text = LocalizedString(@"rtm_push_streaming");
            self.descriptionLabel.text = LocalizedString(@"rtm_push_streaming_des");
            break;
        }
        case LiveSettingABR: {
            self.titleLabel.text = LocalizedString(@"ABR");
            self.descriptionLabel.text = LocalizedString(@"ABR_des");
            break;
        }
        default: {
            NSLog(@"Set CellType");
            break;
        };
    }
}

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    [self.switchView setOn:isOn];
}

- (void)switchAction:(UISwitch *)sw {
    if ([self.delegate respondsToSelector:@selector(saveSettingInfo:isOn:)]) {
        [self.delegate saveSettingInfo:self.cellType isOn:sw.isOn];
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#0C0D0E"];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = [UIColor colorFromRGBHexString:@"#737A87"];
        _descriptionLabel.font = [UIFont systemFontOfSize:12];
        _descriptionLabel.numberOfLines = 0;
    }
    return _descriptionLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 36, 20)];
        [_switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

@end
