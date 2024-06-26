// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusRoomListsViewController.h"
#import "ChorusCreateRoomViewController.h"
#import "ChorusRoomViewController.h"
#import "ChorusRoomTableView.h"
#import "ChorusRTSManager.h"
#import "ChorusDownloadMusicComponent.h"
#import <ToolKit/ToolKit.h>

@interface ChorusRoomListsViewController () <ChorusRoomTableViewDelegate>

@property (nonatomic, strong) UIImageView *topBackgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) ChorusRoomTableView *roomTableView;
@property (nonatomic, copy) NSString *currentAppid;

@end

@implementation ChorusRoomListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];
    
    [self addSubviewAndMakeConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.bgView.hidden = YES;
    self.navView.backgroundColor = [UIColor clearColor];
    self.navLeftImage = [UIImage imageNamed:@"nav_left" bundleName:HomeBundleName];
    self.navRightImage = [UIImage imageNamed:@"nav_refresh" bundleName:HomeBundleName];
    
    [self loadDataWithGetLists];
}

- (void)rightButtonAction:(BaseButton *)sender {
    [super rightButtonAction:sender];
    
    [self loadDataWithGetLists];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - load data

- (void)loadDataWithGetLists {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [ChorusRTSManager clearUser:^(RTSACKModel * _Nonnull model) {
        [ChorusRTSManager getActiveLiveRoomListWithBlock:^(NSArray<ChorusRoomModel *> * _Nonnull roomList, RTSACKModel * _Nonnull model) {
            [[ToastComponent shareToastComponent] dismiss];
            if (model.result) {
                wself.roomTableView.dataLists = roomList;
            } else {
                wself.roomTableView.dataLists = @[];
                [[ToastComponent shareToastComponent] showWithMessage:model.message];
            }
        }];
    }];
}

#pragma mark - ChorusRoomTableViewDelegate

- (void)ChorusRoomTableView:(ChorusRoomTableView *)ChorusRoomTableView didSelectRowAtIndexPath:(ChorusRoomModel *)model {
    [PublicParameterComponent share].roomId = model.roomID;
    ChorusRoomViewController *next = [[ChorusRoomViewController alloc]
                                         initWithRoomModel:model];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Touch Action

- (void)createButtonAction {
    ChorusCreateRoomViewController *next = [[ChorusCreateRoomViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Private Action

- (void)addSubviewAndMakeConstraints {
    [self.view insertSubview:self.topBackgroundImageView belowSubview:self.navView];
    [self.topBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@340);
    }];
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.mas_equalTo([DeviceInforTool getSafeAreaInsets].bottom + 60);
    }];
    
    [self.view addSubview:self.roomTableView];
    [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
    }];
    
    [self.view addSubview:self.createButton];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(152, 52));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-12 - [DeviceInforTool getVirtualHomeHeight]);
    }];
}

#pragma mark - Getter

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        [_createButton addTarget:self action:@selector(createButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_createButton setTitle:LocalizedString(@"button_create_room") forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _createButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.colors = @[
            (__bridge id)[UIColor colorFromRGBHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromRGBHexString:@"#ED3596"].CGColor
        ];
        layer.frame = CGRectMake(0, 0, 152, 52);
        layer.startPoint = CGPointMake(0.25, 0.5);
        layer.endPoint = CGPointMake(0.75, 0.5);
        [_createButton.layer insertSublayer:layer atIndex:0];
        _createButton.layer.cornerRadius = 8;
        _createButton.layer.masksToBounds = YES;
    }
    return _createButton;
}

- (ChorusRoomTableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[ChorusRoomTableView alloc] init];
        _roomTableView.delegate = self;
    }
    return _roomTableView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedString(@"chorus_scene_name");
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    }
    return _titleLabel;
}

- (UIImageView *)topBackgroundImageView {
    if (!_topBackgroundImageView) {
        _topBackgroundImageView = [[UIImageView alloc] init];
        _topBackgroundImageView.image = [UIImage imageNamed:@"room_list_bg" bundleName:HomeBundleName];
        _topBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBackgroundImageView.clipsToBounds = YES;
    }
    return _topBackgroundImageView;
}

- (void)dealloc {
    [[ChorusDownloadMusicComponent shared] removeLocalMusicFile];
    [PublicParameterComponent clear];
    [[ChorusRTCManager shareRtc] disconnect];
}


@end
