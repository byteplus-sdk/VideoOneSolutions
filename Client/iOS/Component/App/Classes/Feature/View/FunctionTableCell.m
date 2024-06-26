//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionTableCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>

@interface FunctionTableCell ()
@property (nonatomic, strong) UIView *cellContentView;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *moreImageView;

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

    [self.contentView addSubview:self.cellContentView];
    
    self.iconImgV = [[UIImageView alloc] init];
    self.iconImgV.contentMode = UIViewContentModeScaleToFill;
    self.iconImgV.clipsToBounds = YES;
    self.iconImgV.layer.cornerRadius = 4;
    [self.cellContentView addSubview:self.iconImgV];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.leading.equalTo(self.cellContentView).mas_offset(16);
        make.centerY.equalTo(self.cellContentView);
    }];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor colorWithRed:0.0 green:0.172 blue:0.279 alpha:1.0];
    self.nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.cellContentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cellContentView);
        make.leading.equalTo(self.iconImgV.mas_trailing).offset(12);
    }];
    [self.cellContentView addSubview:self.moreImageView];
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.cellContentView);
    }];
}
- (void)updateUIConstraints {
    [self.cellContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).mas_offset(16);
        make.trailing.equalTo(self.contentView).mas_offset(-16);
        make.top.equalTo(self.contentView).mas_offset(self.model.marginTop);
        make.bottom.equalTo(self.contentView).mas_offset(-self.model.marginBottom);
    }];
}

- (void)setModel:(BaseFunctionEntrance *)model {
    _model = model;
    self.iconImgV.image = [UIImage imageNamed:model.iconName bundleName:model.bundleName];
    self.nameLabel.text = model.title;
    [self updateUIConstraints];
}

- (UIImageView *)moreImageView {
    if (!_moreImageView) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage imageNamed:@"menu_list_more" bundleName:@"App"];
    }
    return _moreImageView;
}

- (UIView *)cellContentView {
    if (!_cellContentView) {
        _cellContentView = [[UIView alloc] init];
        _cellContentView.backgroundColor = [UIColor whiteColor];
        _cellContentView.layer.cornerRadius = 8;
    }
    return _cellContentView;
}

@end
