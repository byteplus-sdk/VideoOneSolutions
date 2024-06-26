// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusMusicControlView.h"
#import "ChorusDataManager.h"
#import <SDWebImage/SDWebImage.h>

@interface ChorusMusicControlView ()

@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) UIImageView *scoreImageView;
@property (nonatomic, strong) UIImageView *songCoverImageView;
@property (nonatomic, strong) UILabel *musicTitleLabel;
@property (nonatomic, strong) UILabel *musicTimeLabel;

@end

@implementation ChorusMusicControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.lineImageView];
        [self addSubview:self.scoreImageView];
        [self addSubview:self.songCoverImageView];
        [self addSubview:self.musicTitleLabel];
        [self addSubview:self.musicTimeLabel];
        
        [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(14);
        }];
        
        [self.scoreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(62, 62));
            make.centerY.equalTo(self);
            make.left.mas_equalTo(19);
        }];
        
        [self.songCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.center.equalTo(self.scoreImageView);
        }];
        
        [self.musicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25);
            make.left.equalTo(self.scoreImageView.mas_right).offset(11);
            make.right.lessThanOrEqualTo(self).offset(-5);
        }];
        
        [self.musicTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicTitleLabel.mas_bottom).offset(4);
            make.left.equalTo(self.musicTitleLabel);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateUI {
    [self.songCoverImageView sd_setImageWithURL:[NSURL URLWithString:[ChorusDataManager shared].currentSongModel.coverURL] placeholderImage:nil];
    self.musicTitleLabel.text = [ChorusDataManager shared].currentSongModel.musicName;
    self.time = 0;
}

- (void)setTime:(NSTimeInterval)time {
    _time = time;
    NSString *allTimeStr = [self secondsToMinutes:(long)([ChorusDataManager shared].currentSongModel.musicAllTime / 1000.0)];
    
    self.musicTimeLabel.text = [NSString stringWithFormat:@"%@ / %@", [self secondsToMinutes:time], allTimeStr];
}

- (NSString *)secondsToMinutes:(NSInteger)allSecond {
    NSInteger minute = allSecond / 60;
    NSInteger second = allSecond - (minute * 60);
    NSString *minuteStr = (minute < 10) ? [NSString stringWithFormat:@"0%ld", minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    NSString *secondStr = (second < 10) ? [NSString stringWithFormat:@"0%ld", second] : [NSString stringWithFormat:@"%ld", (long)second];
    return [NSString stringWithFormat:@"%@:%@", minuteStr, secondStr];
}


#pragma mark - Getter

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"music_playing_line" bundleName:HomeBundleName]];
    }
    return _lineImageView;
}

- (UIImageView *)scoreImageView {
    if (!_scoreImageView) {
        _scoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"music_song_cover_edge" bundleName:HomeBundleName]];
    }
    return _scoreImageView;
}

- (UIImageView *)songCoverImageView {
    if (!_songCoverImageView) {
        _songCoverImageView = [[UIImageView alloc] init];
        _songCoverImageView.backgroundColor = [UIColor redColor];
        _songCoverImageView.layer.cornerRadius = 20;
        _songCoverImageView.layer.masksToBounds = YES;
    }
    return _songCoverImageView;
}

- (UILabel *)musicTitleLabel {
    if (!_musicTitleLabel) {
        _musicTitleLabel = [[UILabel alloc] init];
        _musicTitleLabel.textColor = [UIColor whiteColor];
        _musicTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _musicTitleLabel;
}

- (UILabel *)musicTimeLabel {
    if (!_musicTimeLabel) {
        _musicTimeLabel = [[UILabel alloc] init];
        _musicTimeLabel.textColor = [UIColor colorFromHexString:@"#C9CDD4"];
        _musicTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    return _musicTimeLabel;
}

@end
