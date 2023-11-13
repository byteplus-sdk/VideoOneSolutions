// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingDisplayCell.h"
#import "VESettingModel.h"
#import <ToolKit/ToolKit.h>
#import "Masonry.h"

const NSString *VESettingDisplayCellReuseID = @"VESettingDisplayCellReuseID";

@interface VESettingDisplayCell ()

@property (strong, nonatomic) UIButton *clearButton;


@end

@implementation VESettingDisplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bgView.hidden = YES;
        self.clearButton = [UIButton new];
        [self.clearButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
        self.clearButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        self.clearButton.layer.cornerRadius = 4;
        self.clearButton.layer.masksToBounds = YES;
        self.clearButton.layer.borderColor = [UIColor colorFromHexString:@"#C9CDD4"].CGColor;
        self.clearButton.layer.borderWidth = 1;
        [self.contentView addSubview:self.clearButton];
        [self.clearButton addTarget:self action:@selector(onBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-12);
            make.centerY.equalTo(self);
            make.height.equalTo(@(48));
        }];
    }
    return self;
}

- (void)onBtnClick {
    if (self.settingModel.allAreaAction) {
        self.settingModel.allAreaAction();
    }
}


- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    [self.clearButton setTitle:[NSString stringWithFormat:@"%@", settingModel.displayText] forState:UIControlStateNormal];
}

@end
