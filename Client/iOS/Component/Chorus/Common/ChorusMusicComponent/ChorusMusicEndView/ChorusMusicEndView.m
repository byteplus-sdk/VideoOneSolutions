// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusMusicEndView.h"
#import "ChorusSongNameLabel.h"
@interface ChorusMusicEndView ()

@property (nonatomic, strong) ChorusSongNameLabel *songNameLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation ChorusMusicEndView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-16);
            make.centerX.equalTo(self);
        }];
        
        [self addSubview:self.songNameLabel];
        [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-94);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)showEndViewWithNextSongModel:(ChorusSongModel *)songModel {
    if (NOEmptyStr(songModel.musicName)) {
        self.songNameLabel.text = [NSString stringWithFormat:LocalizedString(@"label_song_end_title_%@"), songModel.musicName];
        self.tipLabel.text = @"";
    } else {
        self.songNameLabel.text = @"";
        self.tipLabel.text = LocalizedString(@"label_song_end_title");
    }
}

#pragma mark - Getter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    }
    return _tipLabel;
}

- (ChorusSongNameLabel *)songNameLabel {
    if (!_songNameLabel) {
        _songNameLabel = [[ChorusSongNameLabel alloc] init];
    }
    return _songNameLabel;
}

@end
