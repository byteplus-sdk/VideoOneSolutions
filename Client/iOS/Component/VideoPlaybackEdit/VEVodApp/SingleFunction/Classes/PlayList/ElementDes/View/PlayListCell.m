// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayListCell.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/ToolKit.h>
#import <Lottie/LOTAnimationView.h>

NSString *const PlayListTableCellIdentify = @"PlayListTableCellIdentify";
NSString *const PlayListFloatTableCellIdentify = @"PlayListFloatTableCellIdentify";

@interface PlayListCell ()
@property (nonatomic, strong) UILabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timesWatchedLabel;
@property (nonatomic, strong) UIView *videoTimeView;
@property (nonatomic, strong) UIImageView *videoCoverImageView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation PlayListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

#pragma mark - Publish Action
- (void)setModel:(VEVideoModel *)model {
    _model = model;
    self.nameLabel.text = model.userName;
    self.videoTitleLabel.text = model.title;
    self.timesWatchedLabel.text = [NSString stringWithFormat:@"%@ · %@", [model playTimeToString], model.createTime];
    [self.videoCoverImageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholderImage:[UIImage imageNamed:@"playcover_default"]];
    CGFloat minutes = [model.duration floatValue] / 60.0;
    CGFloat seconds = [model.duration integerValue] % 60;
    UILabel *timeLabel = [self.videoTimeView viewWithTag:3001];
    timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    self.maskView.hidden = !isPlaying;
    self.videoTimeView.hidden = isPlaying;
    if (isPlaying) {
        [self.animationView play];
    } else {
        [self.animationView stop];
    }
}


#pragma mark - Private Action

- (void)createUIComponent {
    [self.contentView addSubview:self.videoCoverImageView];
    [self.videoCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(152, 84));
        make.left.equalTo(self.contentView).offset(12);
        make.centerY.equalTo(self.contentView);
    }];

    [self.videoCoverImageView addSubview:self.videoTimeView];
    [self.videoTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoCoverImageView).offset(-4);
        make.bottom.equalTo(self.videoCoverImageView).offset(-4.5);
    }];
    
    [self.videoCoverImageView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.videoCoverImageView);
    }];
    
    [self.maskView addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerX.equalTo(self.maskView);
        make.centerY.equalTo(self.maskView);
    }];
    
    [self.contentView addSubview:self.videoTitleLabel];
    
    if ([self.reuseIdentifier isEqualToString:PlayListTableCellIdentify]) {
        [self.videoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.videoCoverImageView.mas_right).offset(12);
            make.top.equalTo(self.videoCoverImageView);
            make.right.lessThanOrEqualTo(self.contentView).offset(-12);
        }];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.videoTitleLabel);
            make.top.equalTo(self.videoTitleLabel.mas_bottom).offset(4);
            make.right.lessThanOrEqualTo(self.contentView).offset(-12);
        }];
        
        [self.contentView addSubview:self.timesWatchedLabel];
        [self.timesWatchedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.videoTitleLabel);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
            make.right.lessThanOrEqualTo(self.contentView).offset(-12);
        }];
    } else {
        [self.videoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.videoCoverImageView.mas_right).offset(12);
            make.centerY.equalTo(self.videoCoverImageView);
            make.right.lessThanOrEqualTo(self.contentView).offset(-12);
        }];
    }
}

#pragma mark - Getter

- (UIImageView *)videoCoverImageView {
    if (!_videoCoverImageView) {
        _videoCoverImageView = [[UIImageView alloc] init];
        _videoCoverImageView.layer.cornerRadius = 4;
        _videoCoverImageView.layer.masksToBounds = YES;
    }
    return _videoCoverImageView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];
        _maskView.layer.cornerRadius = 4;
        _maskView.layer.masksToBounds = YES;
    }
    return _maskView;
}


- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorFromHexString:@"#73767A"];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        _nameLabel.numberOfLines = 1;
    }
    return _nameLabel;
}

- (UILabel *)timesWatchedLabel {
    if (!_timesWatchedLabel) {
        _timesWatchedLabel = [[UILabel alloc] init];
        _timesWatchedLabel.textColor = [UIColor colorFromHexString:@"#73767A"];
        _timesWatchedLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        _timesWatchedLabel.numberOfLines = 1;
    }
    return _timesWatchedLabel;
}

- (UILabel *)videoTitleLabel {
    if (!_videoTitleLabel) {
        _videoTitleLabel = [[UILabel alloc] init];
        _videoTitleLabel.textColor = [UIColor whiteColor];
        _videoTitleLabel.font = [UIFont systemFontOfSize:14];
        _videoTitleLabel.numberOfLines = 2;
    }
    return _videoTitleLabel;
}

- (UIView *)videoTimeView {
    if (!_videoTimeView) {
        _videoTimeView = [[UIView alloc] init];
        _videoTimeView.layer.cornerRadius = 4;
        _videoTimeView.layer.masksToBounds = YES;
        _videoTimeView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];

        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.tag = 3001;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
        [_videoTimeView addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_videoTimeView).with.insets(UIEdgeInsetsMake(0, 2, 0, 2));
        }];
    }
    return _videoTimeView;
}

- (LOTAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [LOTAnimationView animationWithFilePath:[[NSBundle mainBundle] pathForResource:@"video_playing" ofType:@"json"]] ;
        _animationView.loopAnimation = YES;
        _animationView.contentMode = UIViewContentModeScaleToFill;
    }
    return _animationView;
}


@end
