// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusSingerItemView.h"
#import "ChorusNetworkQualityView.h"
#import "ChorusRTCManager.h"

@interface ChorusSingerItemView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *avatarEdgeImageView;
@property (nonatomic, strong) ChorusNetworkQualityView *networkQualityView;
@property (nonatomic, assign) BOOL isRight;
@property (nonatomic, strong) UIView *emptyContentView;

@end

@implementation ChorusSingerItemView

- (instancetype)initWithLocationRight:(BOOL)isRight; {
    if (self = [super init]) {
        self.isRight = isRight;
        [self setupViews];
        
        self.userModel = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteVideoStateChanged) name:@"onRemoteVideoStateChanged" object:nil];
    }
    return self;
}

- (void)onRemoteVideoStateChanged {
    if (self.userModel) {
        UIView *streamView = [[ChorusRTCManager shareRtc] getStreamViewWithUserID:self.userModel.uid];
        if (streamView) {
            self.networkQualityView.hidden = streamView.hidden;
        } else {
            self.networkQualityView.hidden = YES;
        }
    } else {
        self.networkQualityView.hidden = YES;
    }
}

- (void)setupViews {
    [self addSubview:self.contentView];
    [self addSubview:self.emptyContentView];
    [self.contentView addSubview:self.avatarEdgeImageView];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.renderView];
    [self.contentView addSubview:self.networkQualityView];
    
    [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(self);
        make.top.equalTo(@50);
    }];
    [self.avatarEdgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80);
        make.center.equalTo(self.avatarImageView);
    }];
    [self.emptyContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(88);
        make.center.equalTo(self.avatarImageView);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.networkQualityView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.isRight) {
            make.right.equalTo(self).offset(-8);
        } else {
            make.left.equalTo(self).offset(8);
        }
        
        make.top.equalTo(self).offset(8);
        make.height.mas_equalTo(20);
    }];
}

- (void)setUserModel:(ChorusUserModel *)userModel {
    _userModel = userModel;
    if (userModel) {
        self.contentView.hidden = NO;
        self.emptyContentView.hidden = YES;
        self.avatarImageView.image = [UIImage avatarImageForUid:userModel.uid];
        
        [self updateFirstVideoFrameRendered];
    } else {
        self.contentView.hidden = YES;
        self.emptyContentView.hidden = NO;
    }
}

- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status {
    [self.networkQualityView updateNetworkQualityStstus:status];
}

- (void)updateFirstVideoFrameRendered {
    UIView *streamView = [[ChorusRTCManager shareRtc] getStreamViewWithUserID:self.userModel.uid];
    if (streamView) {
        [self.renderView removeAllSubviews];
        [self.renderView addSubview:streamView];
        [streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.renderView);
        }];
    }
}
- (void)updateUserAudioVolume:(NSInteger)volume {
    if (volume < 26) {
        self.avatarEdgeImageView.image = [UIImage imageNamed:@"avatar_edge" bundleName:HomeBundleName];
    } else {
        self.avatarEdgeImageView.image = [UIImage imageNamed:@"avatar_edge_ing" bundleName:HomeBundleName];
    }
}

#pragma mark - Getter

- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
    }
    return _renderView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 30;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (ChorusNetworkQualityView *)networkQualityView {
    if (!_networkQualityView) {
        _networkQualityView = [[ChorusNetworkQualityView alloc] init];
        _networkQualityView.hidden = YES;
    }
    return _networkQualityView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIImageView *)avatarEdgeImageView {
    if (!_avatarEdgeImageView) {
        _avatarEdgeImageView = [[UIImageView alloc] init];
        _avatarEdgeImageView.image = [UIImage imageNamed:@"avatar_edge" bundleName:HomeBundleName];
    }
    return _avatarEdgeImageView;
}

- (UIView *)emptyContentView {
    if (!_emptyContentView) {
        _emptyContentView = [[UIView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_singer_item_seat" bundleName:HomeBundleName]];
        [_emptyContentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_emptyContentView);
        }];
    }
    return _emptyContentView;
}


@end
