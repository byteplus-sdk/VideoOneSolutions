// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVSelectBgItemView.h"

@interface KTVSelectBgItemView ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) NSInteger index;

@end

@implementation KTVSelectBgItemView

- (instancetype)initWithIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _index = index;
        
        [self addSubview:self.bgImageView];
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.bottom.equalTo(@-24);
        }];
        
        [self addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bgImageView);
        }];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        self.bgImageView.image = [UIImage imageNamed:[self getBackgroundSmallImageName] bundleName:HomeBundleName];
        self.isSelected = NO;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    
    if (isSelected) {
        self.selectImageView.hidden = NO;
        self.messageLabel.textColor = [UIColor colorFromHexString:@"#FF1764"];
    } else {
        self.selectImageView.hidden = YES;
        self.messageLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
}

#pragma mark - Publish Action

- (NSString *)getBackgroundImageName {
    return [self getBackgroundImageNames][_index];
}

- (NSString *)getBackgroundSmallImageName {
    return [self getSmallBackgroundImageNames][_index];
}

#pragma mark - Private Action

- (NSArray *)getBackgroundImageNames {
    return @[@"KTV_background_0",
             @"KTV_background_1",
             @"KTV_background_2"];
}

- (NSArray *)getSmallBackgroundImageNames {
    return @[@"KTV_background_small_0",
             @"KTV_background_small_1",
             @"KTV_background_small_2"];
}

#pragma mark - Getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
    }
    return _bgImageView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.image = [UIImage imageNamed:@"KTV_bg_icon" bundleName:HomeBundleName];
        _selectImageView.hidden = YES;
    }
    return _selectImageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _messageLabel.text = [NSString stringWithFormat:LocalizedString(@"label_create_background_title_%@"), @(self.index).stringValue];
    }
    return _messageLabel;
}

@end
