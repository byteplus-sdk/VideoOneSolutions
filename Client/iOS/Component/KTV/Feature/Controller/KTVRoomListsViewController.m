//
//  KTVRoomViewController.m
//  veRTC_Demo
//
//  Created by on 2021/5/18.
//  
//

#import "KTVRoomListsViewController.h"
#import "KTVCreateRoomViewController.h"
#import "KTVRoomViewController.h"
#import "KTVRoomTableView.h"
#import "KTVRTSManager.h"
#import "KTVDownloadMusicComponent.h"
#import <ToolKit/ToolKit.h>

@interface KTVRoomListsViewController () <KTVRoomTableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) KTVRoomTableView *roomTableView;
@property (nonatomic, copy) NSString *currentAppid;

@end

@implementation KTVRoomListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBackgroundImageView.hidden = NO;
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];
    
    [self addSubviewAndMakeConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.rightButton setImage:[UIImage imageNamed:@"nav_refresh" bundleName:HomeBundleName] forState:UIControlStateNormal];
    
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
    [KTVRTSManager clearUser:^(RTSACKModel * _Nonnull model) {
        [KTVRTSManager getActiveLiveRoomListWithBlock:^(NSArray<KTVRoomModel *> * _Nonnull roomList, RTSACKModel * _Nonnull model) {
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

#pragma mark - KTVRoomTableViewDelegate

- (void)KTVRoomTableView:(KTVRoomTableView *)KTVRoomTableView didSelectRowAtIndexPath:(KTVRoomModel *)model {
    [PublicParameterComponent share].roomId = model.roomID;
    KTVRoomViewController *next = [[KTVRoomViewController alloc]
                                         initWithRoomModel:model];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Touch Action

- (void)createButtonAction {
    KTVCreateRoomViewController *next = [[KTVCreateRoomViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - Private Action

- (void)addSubviewAndMakeConstraints {
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
        [_createButton setTitle:LocalizedString(@"button_room_list_create") forState:UIControlStateNormal];
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

- (KTVRoomTableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[KTVRoomTableView alloc] init];
        _roomTableView.delegate = self;
    }
    return _roomTableView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedString(@"ktv_scenes");
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    }
    return _titleLabel;
}

- (void)dealloc {
    [[KTVDownloadMusicComponent shared] removeLocalMusicFile];
    [PublicParameterComponent clear];
    [[KTVRTCManager shareRtc] disconnect];
}


@end
