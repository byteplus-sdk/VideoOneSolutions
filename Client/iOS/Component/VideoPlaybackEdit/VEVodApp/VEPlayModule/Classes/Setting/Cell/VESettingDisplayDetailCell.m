// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingDisplayDetailCell.h"
#import "VESettingModel.h"
#import <ToolKit/Localizator.h>
#import "VEVideoPlayerController+DebugTool.h"
#import "UIColor+String.h"
#import "Masonry.h"


extern NSString *VESettingDisplayDetailCellReuseID;

@interface VESettingDisplayDetailCell ()


@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *detailLabel;

@property (strong, nonatomic) UIButton *operationButton;

@end

@implementation VESettingDisplayDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
        self.detailLabel.font = [UIFont systemFontOfSize:12];
        
        self.operationButton = [UIButton new];
        [self.operationButton setTitle:LocalizedStringFromBundle(@"copy", @"VodPlayer") forState:UIControlStateNormal];
        [self.operationButton setTitleColor:[UIColor colorFromHexString:@"#1664FF"] forState:UIControlStateNormal];
        [self.operationButton addTarget:self action:@selector(onCopy) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.operationButton];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.top.equalTo(self).offset(16);
        }];
        [self.operationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-28);
            make.centerY.equalTo(self.titleLabel);
            make.size.equalTo(@(CGSizeMake(50, 20)));
        }];
        
        self.detailLabel.numberOfLines = 2;
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.bottom.equalTo(self).offset(-16);
            make.right.equalTo(self).offset(-28);
        }];
    }
    return self;
}


- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
    self.detailLabel.text = [NSString stringWithFormat:@"%@", settingModel.detailText];
    [self.operationButton setTitle:LocalizedStringFromBundle(@"copy", @"VodPlayer") forState:UIControlStateNormal];
}

- (void)onCopy {
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@", self.settingModel.detailText];
    if (self.settingModel.allAreaAction) {
        self.settingModel.allAreaAction();
    }
}

@end
