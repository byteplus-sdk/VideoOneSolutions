// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaRecommendViewListCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/UIImage+Bundle.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/NSString+Valid.h>


NSString *const MiniDramaRecommendViewListCellIdentify = @"MiniDramaRecommendViewListCellIdentify";

@interface MiniDramaRecommendViewListCell ()

@property (nonatomic, strong) UILabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *timesWatchedLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *videoCoverImageView;
@property (nonatomic, strong) UIImageView *hotFireImageView;

@end

@implementation MiniDramaRecommendViewListCell

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

- (void)setModel:(MDDramaFeedInfo *)model {
    _model = model;
    [self.videoCoverImageView sd_setImageWithURL:[NSURL URLWithString:model.videoInfo.coverUrl] placeholderImage:[UIImage imageNamed:@"playcover_default" bundleName:@"VodPlayer"]];
    
    self.videoTitleLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_list_cell_title", @"MiniDrama"), model.dramaInfo.dramaTitle, model.videoInfo.order ,model.videoInfo.videoTitle];
    
    CGFloat minutes = [model.videoInfo.duration floatValue] / 60.0;
    CGFloat seconds = [model.videoInfo.duration integerValue] % 60;
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
    self.timesWatchedLabel.text = [NSString stringForCount:model.videoInfo.playTimes];
}

#pragma mark - Private Method
- (void)createUIComponent {
    [self.contentView addSubview:self.videoCoverImageView];
    [self.videoCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 84));
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
    }];

    
    [self.contentView addSubview:self.videoTitleLabel];
    [self.videoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoCoverImageView.mas_right).offset(12);
        make.top.equalTo(self.videoCoverImageView).offset(8);
        make.right.lessThanOrEqualTo(self.contentView).offset(-16);
    }];
    
    [self.contentView addSubview:self.durationLabel];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoTitleLabel);
        make.top.equalTo(self.videoTitleLabel.mas_bottom).offset(12);
    }];
    
    [self.contentView addSubview:self.hotFireImageView];
    [self.hotFireImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.durationLabel.mas_right).offset(12);
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.equalTo(self.durationLabel);
    }];
    
    [self.contentView addSubview:self.timesWatchedLabel];
    [self.timesWatchedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hotFireImageView.mas_right).offset(4);
        make.centerY.equalTo(self.hotFireImageView);
    }];
}


#pragma mark - Getter
- (UIImageView *)videoCoverImageView {
    if (!_videoCoverImageView) {
        _videoCoverImageView = [[UIImageView alloc] init];
        _videoCoverImageView.layer.cornerRadius = 2;
        _videoCoverImageView.layer.masksToBounds = YES;
        _videoCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _videoCoverImageView;
}

- (UILabel *)videoTitleLabel {
    if (!_videoTitleLabel) {
        _videoTitleLabel = [[UILabel alloc] init];
        _videoTitleLabel.textColor = [UIColor whiteColor];
        _videoTitleLabel.font = [UIFont systemFontOfSize:14  weight:UIFontWeightMedium];
        _videoTitleLabel.numberOfLines = 2;
    }
    return _videoTitleLabel;
}

- (UIImageView *)hotFireImageView {
    if (!_hotFireImageView) {
        _hotFireImageView = [[UIImageView alloc] init];
        _hotFireImageView.image = [UIImage imageNamed:@"mini_drama_hot_fire" bundleName:@"MiniDrama"];
    }
    return _hotFireImageView;
}

- (UILabel *)timesWatchedLabel {
    if (!_timesWatchedLabel) {
        _timesWatchedLabel = [[UILabel alloc] init];
        _timesWatchedLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
        _timesWatchedLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
        _timesWatchedLabel.numberOfLines = 1;
    }
    return _timesWatchedLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
        _durationLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    }
    return _durationLabel;
}

@end
