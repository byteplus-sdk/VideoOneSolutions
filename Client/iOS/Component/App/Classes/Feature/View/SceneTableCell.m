// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "SceneTableCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIImage+Bundle.h>

@interface SceneTableCell ()

@property (nonatomic, strong) UIImageView *bgImgV;
@property (nonatomic, strong) UIImageView *arrowImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation SceneTableCell

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
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).mas_offset(16);
        make.trailing.equalTo(self.contentView).mas_offset(-16);
        make.top.equalTo(self.contentView).mas_offset(8);
        make.bottom.equalTo(self.contentView).mas_offset(-8);
    }];
    
    self.bgImgV = [[UIImageView alloc] init];
    self.bgImgV.contentMode = UIViewContentModeScaleAspectFit;
    [contentView addSubview:self.bgImgV];
    [self.bgImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView);
        make.trailing.equalTo(contentView);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView);
    }];

    self.arrowImgV = [[UIImageView alloc] init];
    self.arrowImgV.contentMode = UIViewContentModeCenter;
    self.arrowImgV.layer.cornerRadius = 16;
    self.arrowImgV.clipsToBounds = YES;
    self.arrowImgV.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.arrowImgV.image = [UIImage imageNamed:@"guide_arrow" bundleName:@"App"];
    [contentView addSubview:self.arrowImgV];
    [self.arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.offset(-16);
        make.bottom.offset(-29);
        make.size.mas_equalTo(32);
    }];

    self.desLabel = [[UILabel alloc] init];
    self.desLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.desLabel.font = [UIFont systemFontOfSize:12];
    self.desLabel.numberOfLines = 0;
    [contentView addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(16);
        make.bottom.offset(-16);
        make.trailing.lessThanOrEqualTo(self.arrowImgV.mas_leading).offset(-12);
    }];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    [contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.desLabel);
        make.bottom.equalTo(self.desLabel.mas_top).offset(-2);
        make.trailing.lessThanOrEqualTo(self.arrowImgV.mas_leading).offset(-12);
    }];
}

- (void)setModel:(BaseSceneEntrance *)model {
    _model = model;
    self.bgImgV.image = [UIImage imageNamed:model.iconName bundleName:model.bundleName];
    self.nameLabel.text = model.title;
    self.desLabel.text = model.des;
}

@end
