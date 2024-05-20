// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVCreateRoomViewController.h"
#import "KTVRoomViewController.h"
#import "KTVCreateRoomTipView.h"
#import "KTVSelectBgView.h"

@interface KTVCreateRoomViewController ()

@property (nonatomic, strong) UIView *roomTitleView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) KTVCreateRoomTipView *tipView;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) KTVSelectBgView *selectBgView;
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, copy) NSString *bgImageName;

@end

@implementation KTVCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#272E3B"];
    [self addSubviewAndConstraints];
    NSString *imageName = [[self.selectBgView getDefaults] stringByAppendingString:@".jpg"];
    self.bgImageView.image = [UIImage imageNamed:imageName];
    self.bgImageName = [self.selectBgView getDefaults];
    self.avatarImageView.image = [UIImage imageNamed:[LocalUserComponent userModel].avatarName
                                          bundleName:ToolKitBundleName
                                       subBundleName:AvatarBundleName];
    
    __weak __typeof(self) wself = self;
    self.selectBgView.clickBlock = ^(NSString * _Nonnull imageName,
                                     NSString * _Nonnull smallImageName) {
        wself.bgImageView.image = [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
        wself.bgImageName = imageName;
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navTitle = @"";
    [self.leftButton setImage:[UIImage imageNamed:@"voice_cancel" bundleName:HomeBundleName] forState:UIControlStateNormal];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)joinButtonAction:(UIButton *)sender {
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [KTVRTSManager startLive:self.roomNameLabel.text
                                 userName:[LocalUserComponent userModel].name
                              bgImageName:_bgImageName
                                    block:^(NSString * _Nonnull RTCToken,
                                            KTVRoomModel * _Nonnull roomModel,
                                            KTVUserModel * _Nonnull hostUserModel,
                                            RTSACKModel * _Nonnull model) {
        if (model.result) {
            [PublicParameterComponent share].roomId = roomModel.roomID;
            KTVRoomViewController *next = [[KTVRoomViewController alloc]
                                                 initWithRoomModel:roomModel
                                                 rtcToken:RTCToken
                                                 hostUserModel:hostUserModel];
            [wself.navigationController pushViewController:next animated:YES];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        }
        [[ToastComponent shareToastComponent] dismiss];
    }];
}

#pragma mark - Private Action

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.leftButton];
    [self.leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(24);
        make.left.mas_equalTo(16);
        make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 10);
    }];
    
    [self.view addSubview:self.roomTitleView];
    [self.roomTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.height.mas_equalTo(68);
        make.top.equalTo(self.leftButton.mas_bottom).offset(18);
    }];
        
    [self.roomTitleView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(56);
        make.left.equalTo(self.roomTitleView).offset(6);
        make.centerY.equalTo(self.roomTitleView);
    }];
    
    [self.roomTitleView addSubview:self.roomNameLabel];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).offset(12);
        make.right.lessThanOrEqualTo(self.roomTitleView).offset(-12);
        make.centerY.equalTo(self.roomTitleView);
    }];
    
    [self.view addSubview:self.tipView];
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.top.equalTo(self.roomTitleView.mas_bottom).offset(8);
    }];
    
    [self.view addSubview:self.joinButton];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.height.mas_equalTo(52);
        make.bottom.mas_equalTo(-[DeviceInforTool getVirtualHomeHeight] - 44);
    }];
    
    CGFloat selectBgViewHeight = ((SCREEN_WIDTH - (40 * 2)) - (27.5 * 2)) / 3;
    [self.view addSubview:self.selectBgView];
    [self.selectBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.right.mas_equalTo(-40);
        make.height.mas_equalTo(selectBgViewHeight + 24);
        make.bottom.equalTo(self.joinButton.mas_top).offset(-32);
    }];
}

#pragma mark - getter

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
    }
    return _bgImageView;
}

- (UIView *)roomTitleView {
    if (!_roomTitleView) {
        _roomTitleView = [[UIView alloc] init];
        _roomTitleView.backgroundColor = [UIColor colorFromRGBHexString:@"#FDFDFD" andAlpha:0.1 * 255];
        _roomTitleView.layer.cornerRadius = 12;
        _roomTitleView.layer.masksToBounds = YES;
    }
    return _roomTitleView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.font = [UIFont systemFontOfSize:14];
        _roomNameLabel.numberOfLines = 2;
        _roomNameLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _roomNameLabel.text = [NSString stringWithFormat:LocalizedString(@"label_create_name_%@"), [LocalUserComponent userModel].name];
    }
    return _roomNameLabel;
}

- (KTVSelectBgView *)selectBgView {
    if (!_selectBgView) {
        _selectBgView = [[KTVSelectBgView alloc] init];
        _selectBgView.backgroundColor = [UIColor clearColor];
    }
    return _selectBgView;
}

- (UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [[UIButton alloc] init];
        [_joinButton addTarget:self action:@selector(joinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_joinButton setTitle:LocalizedString(@"button_create_start") forState:UIControlStateNormal];
        [_joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.colors = @[
            (__bridge id)[UIColor colorFromRGBHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromRGBHexString:@"#ED3596"].CGColor
        ];
        layer.frame = CGRectMake(0, 0, SCREEN_WIDTH - 80, 52);
        layer.startPoint = CGPointMake(0.25, 0.5);
        layer.endPoint = CGPointMake(0.75, 0.5);
        [_joinButton.layer insertSublayer:layer atIndex:0];
        _joinButton.layer.cornerRadius = 8;
        _joinButton.layer.masksToBounds = YES;
    }
    return _joinButton;
}

- (KTVCreateRoomTipView *)tipView {
    if (!_tipView) {
        _tipView = [[KTVCreateRoomTipView alloc] init];
        _tipView.message = LocalizedString(@"toast_create_time_tip");
    }
    return _tipView;
}


@end
