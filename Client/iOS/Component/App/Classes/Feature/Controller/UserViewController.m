// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UserViewController.h"
#import "NoticeViewController.h"
#import "UserCell.h"
#import "UserHeadView.h"
#import "UserNameViewController.h"
#import <AppConfig/BuildConfig.h>
#import <Masonry/Masonry.h>
#import <ToolKit/LoginComponent.h>
#import <ToolKit/ToolKit.h>

@interface UserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, copy) NSArray *dataLists;
@property (nonatomic, strong) UserHeadView *headView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) BaseButton *logoutButton;
@property (nonatomic, strong) BaseButton *deletAccountButton;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) BaseButton *leftButton;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];

    self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_bg" bundleName:@"App"]];
    self.bgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.roomTableView];
    [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(48);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.headView.nameString = [LocalUserComponent userModel].name;
    self.headView.iconString = [LocalUserComponent userModel].avatarName;
    [self.roomTableView reloadData];
}

#pragma mark - Publish Action

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    if (indexPath.row == 0) {
        cell.corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    } else if (indexPath.row == self.dataLists.count - 1) {
        cell.corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    MenuCellModel *model = self.dataLists[indexPath.row];
    if (model.isMore) {
        if (model.block != nil) {
            model.block();
        } else {
            if (NOEmptyStr(model.link)) {
                [self jumpToWeb:model.link];
            } else {
                // error
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}

#pragma mark - Private Action

- (void)jumpToWeb:(NSString *)url {
    if (url && [url isKindOfClass:[NSString class]] && url.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{}
                                 completionHandler:^(BOOL success){

                                 }];
    }
}

- (void)deleteAccountButtonClick {
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedStringFromBundle(@"cancel", ToolKitBundleName);
    alertCancelModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {

    };

    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedStringFromBundle(@"confirm", ToolKitBundleName);
    alertModel.font = [UIFont fontWithName:@"Roboto" size:14] ?: [UIFont systemFontOfSize:14 weight:(UIFontWeightMedium)];
    alertModel.textColor = [UIColor colorFromHexString:@"#D7312A"];
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        [[ToastComponent shareToastComponent] showLoading];
        [LoginComponent closeAccount:^(BOOL result) {
            [[ToastComponent shareToastComponent] dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLogout
                                                                object:self
                                                              userInfo:@{NotificationLogoutReasonKey: @"close_account"}];
        }];
    };
    [[AlertActionManager shareAlertActionManager] showWithTitle:LocalizedStringFromBundle(@"cancel_account", @"App")
                                                        message:LocalizedStringFromBundle(@"cancel_account_alert_message", @"App")
                                                        actions:@[alertCancelModel, alertModel]
                                                      hideDelay:-1];
}

- (void)showNoticeClick {
    NoticeViewController *vc = [[NoticeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private Action

- (void)onClickLogoutRoom {
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedStringFromBundle(@"cancel", ToolKitBundleName);
    alertCancelModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {

    };

    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedStringFromBundle(@"ok", ToolKitBundleName);
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLogout
                                                            object:self
                                                          userInfo:@{NotificationLogoutReasonKey: @"manual_logout"}];
    };
    [[AlertActionManager shareAlertActionManager] showWithTitle:LocalizedStringFromBundle(@"log_out", @"App")
                                                        message:LocalizedStringFromBundle(@"logout_confirm", @"App")
                                                        actions:@[alertCancelModel, alertModel]
                                                      hideDelay:-1];
}

- (void)navBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter

- (NSArray *)dataLists {
    if (!_dataLists) {
        NSMutableArray *lists = [[NSMutableArray alloc] init];

        MenuCellModel *model11 = [[MenuCellModel alloc] init];
        model11.title = LocalizedStringFromBundle(@"language_info", @"App");
        model11.desTitle = LocalizedStringFromBundle(@"language_name", @"App");
        model11.isMore = NO;
        [lists addObject:model11];

        MenuCellModel *model2 = [[MenuCellModel alloc] init];
        model2.title = LocalizedStringFromBundle(@"privacy_policy", @"App");
        model2.link = PrivacyPolicy;
        model2.isMore = YES;
        [lists addObject:model2];

        MenuCellModel *model8 = [[MenuCellModel alloc] init];
        model8.title = LocalizedStringFromBundle(@"terms_service", @"App");
        model8.link = TermsOfService;
        model8.isMore = YES;
        [lists addObject:model8];

        MenuCellModel *model10 = [[MenuCellModel alloc] init];
        model10.title = LocalizedStringFromBundle(@"show_notice", @"App");
        model10.isMore = YES;
        __weak __typeof__(self) weakSelf = self;
        model10.block = ^{
            [weakSelf showNoticeClick];
        };
        [lists addObject:model10];

        MenuCellModel *model9 = [[MenuCellModel alloc] init];
        model9.title = LocalizedStringFromBundle(@"cancel_account", @"App");
        model9.isMore = YES;
        model9.block = ^{
            [weakSelf deleteAccountButtonClick];
        };
        [lists addObject:model9];

        NSString *appVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        MenuCellModel *model5 = [[MenuCellModel alloc] init];
        model5.title = LocalizedStringFromBundle(@"app_version", @"App");
        model5.desTitle = [NSString stringWithFormat:@"v%@", appVer];
        [lists addObject:model5];
        
        MenuCellModel *model1 = [[MenuCellModel alloc] init];
        model1.title = @"Github";
        model1.isMore = YES;
        model1.link = @"https://github.com/byteplus-sdk/VideoOneSolutions/";
        [lists addObject:model1];

        _dataLists = [lists copy];
    }
    return _dataLists;
}

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:UserCell.class forCellReuseIdentifier:@"UserCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        _roomTableView.rowHeight = UITableViewAutomaticDimension;
        _roomTableView.tableHeaderView = self.headView;
        _roomTableView.tableFooterView = self.footerView;
        _roomTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _roomTableView.sectionFooterHeight = 0.01;
        _roomTableView.estimatedSectionFooterHeight = 0.01;
        _roomTableView.sectionHeaderHeight = 0.01;
        _roomTableView.estimatedSectionHeaderHeight = 0.01;
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _roomTableView;
}

- (BaseButton *)logoutButton {
    if (!_logoutButton) {
        _logoutButton = [[BaseButton alloc] init];
        _logoutButton.backgroundColor = [UIColor clearColor];
        _logoutButton.layer.masksToBounds = YES;
        _logoutButton.layer.cornerRadius = 4;
        _logoutButton.layer.borderWidth = 1;
        _logoutButton.layer.borderColor = [UIColor colorFromHexString:@"#C9CDD4"].CGColor;
        [_logoutButton setTitle:LocalizedStringFromBundle(@"log_out", @"App") forState:UIControlStateNormal];
        [_logoutButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
        _logoutButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_logoutButton addTarget:self action:@selector(onClickLogoutRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutButton;
}

- (BaseButton *)deletAccountButton {
    if (!_deletAccountButton) {
        _deletAccountButton = [[BaseButton alloc] init];
        _deletAccountButton.backgroundColor = [UIColor clearColor];
        _deletAccountButton.layer.masksToBounds = YES;
        _deletAccountButton.layer.cornerRadius = 4;
        _deletAccountButton.layer.borderWidth = 1;
        _deletAccountButton.layer.borderColor = [UIColor colorFromHexString:@"#C9CDD4"].CGColor;
        [_deletAccountButton setTitle:LocalizedStringFromBundle(@"cancel_account", @"App") forState:UIControlStateNormal];
        [_deletAccountButton setTitleColor:[UIColor colorFromHexString:@"#80838A"] forState:UIControlStateNormal];
        _deletAccountButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [_deletAccountButton addTarget:self action:@selector(deleteAccountButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deletAccountButton;
}

- (UserHeadView *)headView {
    if (!_headView) {
        _headView = [[UserHeadView alloc] init];
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 221);
    }
    return _headView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 88)];
        [_footerView addSubview:self.logoutButton];
        [self.logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(48);
            make.edges.equalTo(_footerView).mas_offset(UIEdgeInsetsMake(20, 16, 20, 16)).priorityHigh();
        }];
    }
    return _footerView;
}

- (BaseButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[BaseButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"img_left_black" bundleName:@"App"] forState:UIControlStateNormal];
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_leftButton addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

@end
