// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomListsViewController.h"
#import "LiveCreateRoomViewController.h"
#import "LiveRoomTableView.h"
#import "LiveRoomViewController.h"
#import "LocalizatorBundle.h"
#import <Masonry/Masonry.h>
#import "ToolKit.h"
#import "SceneTableCell.h"
#import "LiveRoomCell.h"
#import "MJRefresh.h"
#import "LiveSettingViewController.h"
#import <TTSDK/TTSDKManager.h>

 #define TTSDK_APPID @""



@interface LiveRoomListsViewController ()  <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UIImageView *noHostImageView;
@property (nonatomic, strong) UILabel *noHostLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel1;
@property (nonatomic, strong) UILabel *desLabel2;
@property (nonatomic, strong) UILabel *desLabel3;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *createButton;
@end

@implementation LiveRoomListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6F8FA"];
    
    [self.bgView removeFromSuperview];

    self.navRightImage = [UIImage imageNamed:@"list_settings" bundleName:HomeBundleName];
    self.navLeftImage = [UIImage imageNamed:@"list_back" bundleName:HomeBundleName];
    
    [self.view addSubview:self.backgroundImgView];
    [self.view insertSubview:self.backgroundImgView belowSubview:self.navView];
    self.navView.backgroundColor = [UIColor clearColor];

    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];
    
    [self.view addSubview:self.noHostLabel];
    [self.noHostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
    }];

    [self.view addSubview:self.noHostImageView];
    [self.noHostImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.mas_equalTo(100);
        make.bottom.mas_equalTo(self.noHostLabel.mas_top).offset(-18);
    }];
    
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(33);
        make.top.mas_equalTo(104);
        make.right.lessThanOrEqualTo(self.view.mas_right).mas_offset(-16);
    }];
    
    [self.view addSubview:self.desLabel1];
    [self.desLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(52, 20));
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(16);
    }];
    
    [self.view addSubview:self.desLabel2];
    [self.desLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.desLabel1.mas_right).mas_offset(6);
        make.size.mas_equalTo(CGSizeMake(52, 20));
        make.top.equalTo(self.desLabel1);
    }];

    [self.view addSubview:self.desLabel3];
    [self.desLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.desLabel2.mas_right).mas_offset(6);
        make.size.mas_equalTo(CGSizeMake(28, 20));
        make.top.equalTo(self.desLabel1);
        make.right.lessThanOrEqualTo(self.view.mas_right).mas_offset(-16);
    }];

    
    // TableView
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.desLabel1.mas_bottom).mas_offset(30);
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
    
    [self.view addSubview:self.createButton];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(152, 52));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20 - [DeviceInforTool getVirtualHomeHeight]);
    }];
    
    [self setupTTSDK];
    [[LivePlayerManager sharePlayer] startWithConfiguration];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDataWithGetLists:^(BOOL result) {
    }];
}
- (void)rightButtonAction:(BaseButton *)sender {
    [super rightButtonAction:sender];
    LiveSettingViewController *next = [[LiveSettingViewController alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)setupTTSDK {
    TTSDKConfiguration *cfg = [TTSDKConfiguration defaultConfigurationWithAppID:TTSDK_APPID licenseName:@"ttsdk"];
    cfg.channel = [NSBundle.mainBundle.infoDictionary objectForKey:@"CHANNEL_NAME"];
    cfg.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    cfg.bundleID = NSBundle.mainBundle.bundleIdentifier;
    cfg.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    cfg.shouldInitAppLog = YES;
    cfg.serviceVendor = TTSDKServiceVendorSG;
    [TTSDKManager setCurrentUserUniqueID:[LocalUserComponent userModel].uid ?: @""];
    [TTSDKManager setShouldReportToAppLog:YES];
    [TTSDKManager startWithConfiguration:cfg];
}


#pragma mark - TableView Delegate && Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveRoomCell"];
    cell.model = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveRoomInfoModel *model = self.dataArray[indexPath.row];
    [PublicParameterComponent share].roomId = model.roomID;
    LiveRoomViewController *next = [[LiveRoomViewController alloc]
                                    initWithRoomModel:model
                                    streamPushUrl:@""];
    [self.navigationController pushViewController:next animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 116;
}

#pragma mark - Touch Action

- (void)sceneCell:(LiveRoomCell *)cell action:(SceneButtonModel *)model {
    // Open the corresponding scene home page
    self.tableView.userInteractionEnabled = NO;
    BaseHomeDemo *scenes = (BaseHomeDemo *)model.scenes;
    scenes.scenesName = model.scenesName;
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof__(self)weakSelf = self;
    [scenes pushDemoViewControllerBlock:^(BOOL result) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [[ToastComponent shareToastComponent] dismiss];
        self.tableView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Private Action

- (void)headerWithRefreshing {
    __weak __typeof(self) wself = self;
    [self loadDataWithGetLists:^(BOOL result) {
        [wself.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 105)];
        _tableView.sectionFooterHeight = 0.01;
        _tableView.estimatedSectionFooterHeight = 0.01;
        _tableView.sectionHeaderHeight = 0.01;
        _tableView.estimatedSectionHeaderHeight = 0.01;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0.01;
        }
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:LiveRoomCell.class forCellReuseIdentifier:@"LiveRoomCell"];
        __weak __typeof(self) wself = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself headerWithRefreshing];
        }];
        header.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        header.lastUpdatedTimeLabel.hidden = YES;
        header.automaticallyChangeAlpha = YES;
        [header setTitle:LocalizedString(@"refresh_header_idle_text")
                forState:MJRefreshStateIdle];
        [header setTitle:LocalizedString(@"refresh_header_pulling_text")
                forState:MJRefreshStatePulling];
        [header setTitle:LocalizedString(@"refresh_header_refreshing_text")
                forState:MJRefreshStateRefreshing];
        _tableView.mj_header = header;
    }
    return _tableView;
}


- (UIImageView *)noHostImageView {
    if (!_noHostImageView) {
        _noHostImageView = [[UIImageView alloc] init];
        _noHostImageView.backgroundColor = [UIColor clearColor];
        _noHostImageView.image = [UIImage imageNamed:@"list_no_host_live" bundleName:HomeBundleName];
        _noHostImageView.contentMode = UIViewContentModeScaleAspectFit;
        _noHostImageView.hidden = YES;
    }
    return _noHostImageView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_header_bg" bundleName:HomeBundleName]];
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImgView;
}

- (UILabel *)noHostLabel {
    if (!_noHostLabel) {
        _noHostLabel = [[UILabel alloc] init];
        _noHostLabel.textColor = [UIColor colorFromHexString:@"#161823"];
        _noHostLabel.font = [UIFont fontWithName:@"Roboto" size:16] ?: [UIFont boldSystemFontOfSize:16];
        _noHostLabel.text = LocalizedStringFromBundle(@"interactive_live_no_host_live", @"App");
        _noHostLabel.hidden = YES;
    }
    return _noHostLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont fontWithName:@"Roboto" size:28] ?: [UIFont boldSystemFontOfSize:28];
        _titleLabel.text = LocalizedStringFromBundle(@"interactive_live_home_title", @"App");
    }
    return _titleLabel;
}

- (UILabel *)desLabel1 {
    if (!_desLabel1) {
        _desLabel1 = [self createStyledLabel:@"interactive_live_home_des_pk"];
    }
    return _desLabel1;
}

- (UILabel *)desLabel2 {
    if (!_desLabel2) {
        _desLabel2 = [self createStyledLabel:@"interactive_live_home_des_co"];
    }
    return _desLabel2;
}

- (UILabel *)desLabel3 {
    if (!_desLabel3) {
        _desLabel3 = [self createStyledLabel:@"interactive_live_home_des_gift"];
    }
    return _desLabel3;
}

- (UILabel *)createStyledLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorFromRGBHexString:@"#161823" andAlpha:0.6*255];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    label.text = LocalizedStringFromBundle(text, @"App");
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor colorFromRGBHexString:@"#161823" andAlpha:0.05*255];
    label.layer.cornerRadius = 4;
    label.clipsToBounds = YES;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return  label;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [[UIButton alloc] init];
        [_createButton addTarget:self action:@selector(createButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_createButton setTitle:LocalizedString(@"create_live") forState:UIControlStateNormal];
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

#pragma mark - Touch Action

- (void)createButtonAction:(UIButton *)sender {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(videoStatus == AVAuthorizationStatusAuthorized && audioStatus == AVAuthorizationStatusAuthorized) {
        sender.userInteractionEnabled = NO;
        LiveCreateRoomViewController *next = [[LiveCreateRoomViewController alloc] init];
        [self.navigationController pushViewController:next animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    } else if(videoStatus == AVAuthorizationStatusNotDetermined
              || audioStatus == AVAuthorizationStatusNotDetermined) {
        if(videoStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
        }
        
        if (audioStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {}];
        }
    } else {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"live_without_permission")];
    }
 
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return  UIStatusBarStyleDefault;
}

#pragma mark - load data

- (void)loadDataWithGetLists:(void (^)(BOOL result))block {
    __weak __typeof(self) wself = self;
    [[ToastComponent shareToastComponent] showLoading];
    [LiveRTSManager liveClearUserWithBlock:^(RTSACKModel * _Nonnull model) {
        [LiveRTSManager liveGetActiveLiveRoomListWithBlock:^(NSArray<LiveRoomInfoModel *> *roomList, RTSACKModel *model) {
            [[ToastComponent shareToastComponent] dismiss];
            if (roomList.count > 0) {
                wself.noHostImageView.hidden = YES;
                wself.noHostLabel.hidden = YES;
                wself.dataArray = [NSMutableArray arrayWithArray:roomList];
                [wself.tableView reloadData];
            } else {
                wself.noHostImageView.hidden = NO;
                wself.noHostLabel.hidden = NO;
                [wself.dataArray removeAllObjects];
                [wself.tableView reloadData];
            }
            if (block) {
                block(YES);
            }
        }];
    }];
}

@end
