// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCreateRoomSettingView.h"
#import "BaseSwitchView.h"
#import "LiveSettingBitrateView.h"
#import "LiveSettingSingleSelectView.h"

@interface LiveCreateRoomSettingView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *fpsSelectView;
@property (nonatomic, strong) BaseSwitchView *fpsSwitchView;
@property (nonatomic, strong) LiveSettingSingleSelectView *resolutoinSelectView;
@property (nonatomic, strong) LiveSettingBitrateView *bitrateSelectView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation LiveCreateRoomSettingView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"];
        [self addSubviewConstraints];

        __weak __typeof(self) wself = self;
        self.fpsSwitchView.didChangeBlock = ^(BaseSwitchViewState state) {
            LiveSettingVideoFpsType type = LiveSettingVideoFpsType_15;
            if (state == BaseSwitchViewStateLeft) {
                type = LiveSettingVideoFpsType_15;
            } else {
                type = LiveSettingVideoFpsType_20;
            }
            [LiveSettingVideoConfig defultVideoConfig].fpsType = type;
            if ([wself.delegate respondsToSelector:@selector(liveCreateRoomSettingView:didChangefpsType:)]) {
                [wself.delegate liveCreateRoomSettingView:wself didChangefpsType:type];
            }
        };

        [self.bitrateSelectView setBitrateDidChangedBlock:^(NSInteger bitrate) {
            [wself bitrateDidChanged:bitrate];
        }];

        self.resolutoinSelectView.itemClickBlock = ^{
            if ([wself.delegate respondsToSelector:@selector(liveCreateRoomSettingView:didSelectQuality:)]) {
                [wself.delegate liveCreateRoomSettingView:wself didSelectQuality:YES];
            }
        };
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (void)setVideoConfig:(LiveSettingVideoConfig *)videoConfig {
    _videoConfig = videoConfig;

    NSDictionary *resDic = videoConfig.resolutionDic;
    self.resolutoinSelectView.valueString = (NSString *)resDic[@(videoConfig.resolutionType)];

    self.bitrateSelectView.maxBitrate = videoConfig.maxBitrate;
    self.bitrateSelectView.minBitrate = videoConfig.minBitrate;
    self.bitrateSelectView.bitrate = videoConfig.bitrate;

    [self bitrateDidChanged:videoConfig.bitrate];
}

- (void)bitrateDidChanged:(NSInteger)bitrate {
    self.videoConfig.bitrate = bitrate;
    if ([self.delegate respondsToSelector:@selector(liveCreateRoomSettingView:didChangeBitrate:)]) {
        [self.delegate liveCreateRoomSettingView:self didChangeBitrate:bitrate];
    }
}

#pragma mark - Private Action

- (void)addSubviewConstraints {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(16);
    }];

    [self addSubview:self.fpsSelectView];
    [self.fpsSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(24);
        make.height.mas_equalTo(60);
    }];

    [self addSubview:self.fpsSwitchView];
    [self.fpsSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(87, 32));
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.fpsSelectView);
    }];

    [self addSubview:self.resolutoinSelectView];
    [self.resolutoinSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.fpsSelectView);
        make.top.equalTo(self.fpsSelectView.mas_bottom);
    }];

    [self addSubview:self.bitrateSelectView];
    [self.bitrateSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.fpsSelectView);
        make.top.equalTo(self.resolutoinSelectView.mas_bottom).offset(20);
        make.height.mas_equalTo(60);
    }];

    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(16);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedString(@"settings");
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _titleLabel;
}

- (UIView *)fpsSelectView {
    if (!_fpsSelectView) {
        _fpsSelectView = [[UIView alloc] init];

        UILabel *label = [[UILabel alloc] init];
        label.text = LocalizedString(@"video_FPS");
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        label.textColor = [UIColor whiteColor];
        [_fpsSelectView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.centerY.equalTo(_fpsSelectView);
        }];
    }
    return _fpsSelectView;
}

- (BaseSwitchView *)fpsSwitchView {
    if (!_fpsSwitchView) {
        LiveSettingVideoFpsType type = [LiveSettingVideoConfig defultVideoConfig].fpsType;
        BOOL isOn = (type == LiveSettingVideoFpsType_15) ? NO : YES;
        _fpsSwitchView = [[BaseSwitchView alloc] initWithOn:isOn];
        _fpsSwitchView.layer.cornerRadius = 16;
        _fpsSwitchView.layer.masksToBounds = YES;
        _fpsSwitchView.backgroundColor = [UIColor colorFromHexString:@"#41464F"];
        _fpsSwitchView.selectColor = [UIColor colorFromHexString:@"#FF1764"];
        _fpsSwitchView.defaultColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
    }
    return _fpsSwitchView;
}

- (LiveSettingSingleSelectView *)resolutoinSelectView {
    if (!_resolutoinSelectView) {
        _resolutoinSelectView = [[LiveSettingSingleSelectView alloc] initWithTitle:LocalizedString(@"quality")];
        LiveSettingVideoResolutionType resType = [LiveSettingVideoConfig defultVideoConfig].resolutionType;
        NSDictionary *resolutionDic = [LiveSettingVideoConfig defultVideoConfig].resolutionDic;
        _resolutoinSelectView.valueString = resolutionDic[@(resType)];
    }
    return _resolutoinSelectView;
}

- (LiveSettingBitrateView *)bitrateSelectView {
    if (!_bitrateSelectView) {
        _bitrateSelectView = [[LiveSettingBitrateView alloc] init];
    }
    return _bitrateSelectView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
