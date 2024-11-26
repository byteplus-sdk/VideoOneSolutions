// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingSwitcherCell.h"
#import "VESettingModel.h"
#import "UIColor+String.h"
#import "Masonry.h"

extern NSString *VESettingSwitcherCellReuseID;

@interface VESettingSwitcherCell ()


@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UISwitch *switcher;

@end

@implementation VESettingSwitcherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        self.switcher = [UISwitch new];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.switcher];
        [self.switcher addTarget:self action:@selector(switcherValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.centerY.equalTo(self);
        }];
        [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-28);
            make.centerY.equalTo(self);
            make.size.equalTo(@(CGSizeMake(40, 20)));
        }];
    }
    return self;
}


- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
    self.switcher.on = settingModel.open;
}

- (void)switcherValueChanged:(UISwitch *)sender {
    self.settingModel.open = sender.on;
    if (self.settingModel.allAreaAction) {
        self.settingModel.allAreaAction();
    }
}

@end
