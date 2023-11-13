//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT
//

#import "VEMainItemButton.h"
#import "Masonry.h"
#import "ToolKit.h"

@interface VEMainItemButton ()

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) NSMutableDictionary *bingImageDic;

@property (nonatomic, strong) NSMutableDictionary *bingColorDic;

@end

@implementation VEMainItemButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;

        [self addSubview:self.desLabel];
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-4);
            make.centerX.equalTo(self);
        }];

        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(4);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(28);
        }];
    }
    return self;
}

- (void)setDesTitle:(NSString *)desTitle {
    _desTitle = desTitle;

    self.desLabel.text = desTitle;
    if (NOEmptyStr(desTitle)) {
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(4);
        }];
    } else {
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
        }];
    }
}

#pragma mark - Publish Action

- (void)setStatus:(ButtonStatus)status {
    NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
    UIImage *image = self.bingImageDic[key];
    if (image && [image isKindOfClass:[UIImage class]]) {
        self.iconImageView.image = image;
    }

    NSString *keyColor = [NSString stringWithFormat:@"status_color_%ld", (long)status];
    UIColor *color = self.bingColorDic[keyColor];
    if (color && [color isKindOfClass:[UIColor class]]) {
        self.desLabel.textColor = color;
    }

    if (status == ButtonStatusActive) {
        self.desLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    } else {
        self.desLabel.font = [UIFont systemFontOfSize:12];
    }
}

- (void)bingLabelColor:(UIColor *)color status:(ButtonStatus)status {
    if (color) {
        NSString *key = [NSString stringWithFormat:@"status_color_%ld", (long)status];
        [self.bingColorDic setValue:color forKey:key];
        if (status == ButtonStatusNone) {
            self.desLabel.textColor = color;
        }
    }
}

- (void)bingImage:(UIImage *)image status:(ButtonStatus)status {
    if (image) {
        NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
        [self.bingImageDic setValue:image forKey:key];
        if (status == ButtonStatusNone) {
            self.iconImageView.image = image;
        }
    }
}

#pragma mark - Getter

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor colorFromHexString:@"#86909C"];
        _desLabel.font = [UIFont systemFontOfSize:12];
    }
    return _desLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (NSMutableDictionary *)bingImageDic {
    if (!_bingImageDic) {
        _bingImageDic = [[NSMutableDictionary alloc] init];
    }
    return _bingImageDic;
}

- (NSMutableDictionary *)bingColorDic {
    if (!_bingColorDic) {
        _bingColorDic = [[NSMutableDictionary alloc] init];
    }
    return _bingColorDic;
}

@end
