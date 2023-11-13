// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCRenderView.h"
#import "LiveRTCManager.h"

@interface LiveRTCRenderView ()

@property (nonatomic, strong) UIImageView *placeholderImageView;

@property (nonatomic, strong) UIView *renderView;

@end

@implementation LiveRTCRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.renderView];
        [self.renderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.self.placeholderImageView];
        [self.placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setIsCamera:(BOOL)isCamera {
    _isCamera = isCamera;

    self.placeholderImageView.hidden = isCamera;
}

- (void)setUid:(NSString *)uid {
    _uid = uid;

    UIView *rtcStreamView = [[LiveRTCManager shareRtc] bindCanvasViewToUid:uid];
    rtcStreamView.hidden = NO;
    rtcStreamView.backgroundColor = [UIColor clearColor];
    [self.renderView addSubview:rtcStreamView];
    [rtcStreamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.renderView);
    }];

    NSString *avatarName = [LiveUserModel getAvatarNameWithUid:self.uid];
    self.placeholderImageView.image = [UIImage imageNamed:avatarName
                                               bundleName:ToolKitBundleName
                                            subBundleName:AvatarBundleName];
}

#pragma mark - Getter

- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.backgroundColor = [UIColor clearColor];
        _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
        _placeholderImageView.clipsToBounds = YES;
    }
    return _placeholderImageView;
}

- (UIView *)renderView {
    if (!_renderView) {
        _renderView = [[UIView alloc] init];
        _renderView.backgroundColor = [UIColor clearColor];
    }
    return _renderView;
}

@end
