//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionTableCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>

@interface FunctionTableCell ()

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation FunctionTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];

    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12;
    contentView.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
    contentView.layer.shadowOpacity = 1;
    contentView.layer.shadowRadius = 10;
    contentView.layer.shadowOffset = CGSizeMake(0, 3);
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).mas_offset(16);
        make.trailing.equalTo(self.contentView).mas_offset(-16);
        make.top.equalTo(self.contentView).mas_offset(8);
        make.bottom.equalTo(self.contentView).mas_offset(-8);
    }];

    self.iconImgV = [[UIImageView alloc] init];
    self.iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImgV.clipsToBounds = YES;
    self.iconImgV.layer.cornerRadius = 4;
    [contentView addSubview:self.iconImgV];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).mas_offset(16);
        make.top.equalTo(contentView).mas_offset(20);
        make.bottom.equalTo(contentView).mas_offset(-20);
        make.width.mas_equalTo(116);
    }];

    UIView *textContent = [[UIView alloc] init];
    [contentView addSubview:textContent];
    [textContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImgV.mas_trailing).mas_offset(16);
        make.trailing.equalTo(contentView).mas_offset(-16);
        make.centerY.equalTo(contentView);
    }];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor colorWithRed:0.0 green:0.172 blue:0.279 alpha:1.0];
    self.nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [textContent addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(textContent);
    }];

    self.desLabel = [[UILabel alloc] init];
    self.desLabel.textColor = [UIColor colorWithRed:0.451 green:0.478 blue:0.529 alpha:1.0];
    self.desLabel.font = [UIFont systemFontOfSize:12];
    self.desLabel.numberOfLines = 0;
    self.desLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [textContent addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.leading.trailing.bottom.equalTo(textContent);
    }];
}

- (void)setModel:(BaseFunctionEntrance *)model {
    _model = model;
    self.iconImgV.image = [UIImage imageNamed:model.iconName bundleName:model.bundleName];
    self.nameLabel.text = model.title;
    self.desLabel.text = model.des;
}

@end
