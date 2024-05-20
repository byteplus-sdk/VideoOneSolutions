// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVMusicEndView.h"

@interface KTVMusicEndView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BaseButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KTVMusicEndView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(110, 110));
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(0);
        }];
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.button.mas_bottom).offset(-8);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)showWithModel:(KTVSongModel *)songModel
                block:(void (^)(BOOL result))block {
    if (NOEmptyStr(songModel.musicName)) {
        self.titleLabel.text = [NSString stringWithFormat:LocalizedString(@"label_next_music_tip_%@"), songModel.musicName];
    } else {
        self.titleLabel.text = @"";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (block) {
            block(YES);
        }
    });
}

- (void)buttonAction {
    if (self.clickPlayMusicBlock) {
        self.clickPlayMusicBlock();
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#C7CCD6"];
        _titleLabel.userInteractionEnabled = NO;
    }
    return _titleLabel;
}

- (BaseButton *)button {
    if (!_button) {
        _button = [[BaseButton alloc] init];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [_button setBackgroundColor:[UIColor clearColor]];
        [_button setImage:[UIImage imageNamed:@"music_null_play" bundleName:HomeBundleName] forState:UIControlStateNormal];
    }
    return _button;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"ktv_null_bg" bundleName:HomeBundleName];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
