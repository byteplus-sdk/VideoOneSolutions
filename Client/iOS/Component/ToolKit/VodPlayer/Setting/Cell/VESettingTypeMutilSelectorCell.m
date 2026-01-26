// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingTypeMutilSelectorCell.h"
#import "VESettingModel.h"
#import "UIColor+String.h"
#import "Masonry.h"
#import "Localizator.h"


extern NSString *VESettingTypeMutilSelectorCellReuseID;

@interface VESettingTypeMutilSelectorCell ()


@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *detailLabel;

@end

@implementation VESettingTypeMutilSelectorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
        self.detailLabel.font = [UIFont systemFontOfSize:12];
        
//        UIButton *copyBtn = [UIButton new];
//        [copyBtn setTitle:LocalizedStringFromBundle(@"copy", @"VodPlayer") forState:UIControlStateNormal];
//        [copyBtn setTitleColor:[UIColor colorFromHexString:@"#1664FF"] forState:UIControlStateNormal];
        
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.top.equalTo(self).offset(16);
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

- (void)onCopy {
    
}


@end
