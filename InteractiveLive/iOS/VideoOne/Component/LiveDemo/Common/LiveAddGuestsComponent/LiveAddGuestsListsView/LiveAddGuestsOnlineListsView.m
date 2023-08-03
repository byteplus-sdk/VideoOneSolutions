// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsOnlineListsView.h"
#import "LiveListEmptyView.h"

@interface LiveAddGuestsOnlineListsView () <UITableViewDelegate, UITableViewDataSource, LiveAddGuestsUserListtCellDelegate>

@property (nonatomic, strong) LiveListEmptyView *emptyView;
@property (nonatomic, strong) BaseButton *applicationButton;

@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, assign) NSInteger second;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) BaseButton *closeConnectButton;
@property (nonatomic, strong) UIImageView *bottomImageView;

@end

@implementation LiveAddGuestsOnlineListsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.emptyView];
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(92);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
        }];
        
        [self addSubview:self.applicationButton];
        [self.applicationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(131, 24));
            make.top.equalTo(self.emptyView.mas_bottom).offset(12);
            make.centerX.equalTo(self);
        }];
        
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.centerX.equalTo(self);
            make.top.equalTo(self);
        }];
        
        [self addSubview:self.closeConnectButton];
        [self.closeConnectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(48);
            make.bottom.equalTo(self).offset(-(4 + [DeviceInforTool getVirtualHomeHeight]));
        }];
        
        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.closeConnectButton.mas_top).offset(-11);
            make.top.equalTo(self.timeLabel.mas_bottom);
        }];
        
        [self addSubview:self.bottomImageView];
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.roomTableView);
            make.height.mas_equalTo(24);
        }];
        
        __weak __typeof(self) wself = self;
        [self.timer start:1 block:^(BOOL result) {
            [wself timerMethod];
        }];
        [self.timer suspend];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateStartTime:(NSDate *)time {
    if (!time) {
        time = [NSDate date];
    }
    NSInteger createTime = [time timeIntervalSince1970];
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
    NSInteger second = nowTime - createTime;
    self.second = second;
    [self.timer resume];
}

- (void)setDataLists:(NSArray<LiveUserModel *> *)dataLists {
    _dataLists = dataLists;
    
    BOOL isOnlineUser = dataLists.count > 0;
    self.emptyView.hidden = isOnlineUser ? YES : NO;
    self.applicationButton.hidden = self.emptyView.hidden;
    self.roomTableView.hidden = isOnlineUser ? NO : YES;
    self.timeLabel.hidden = self.roomTableView.hidden;
    self.closeConnectButton.hidden = self.roomTableView.hidden;
    self.bottomImageView.hidden = self.roomTableView.hidden;
    
    [self.roomTableView reloadData];
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    for (LiveUserModel *userModel in self.dataLists) {
        if ([userModel.uid isEqualToString:uid]) {
            userModel.mic = mic;
            break;
        }
    }
    [self setDataLists:self.dataLists];
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    for (LiveUserModel *userModel in self.dataLists) {
        if ([userModel.uid isEqualToString:uid]) {
            userModel.camera = camera;
            break;
        }
    }
    [self setDataLists:self.dataLists];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveAddGuestsUserListtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveAddGuestsUserListtCellID" forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexStr = @(indexPath.row + 1).stringValue;
    cell.onlineUserModel = self.dataLists[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}

#pragma mark - LiveAddGuestsUserListtCellDelegate

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
    clickDisconnectButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(onlineListsView:clickKickButton:)]) {
        [self.delegate onlineListsView:self clickKickButton:model];
    }
}

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
           clickMicButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(onlineListsView:clickMicButton:)]) {
        [self.delegate onlineListsView:self clickMicButton:model];
    }
}

- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
        clickCameraButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(onlineListsView:clickCameraButton:)]) {
        [self.delegate onlineListsView:self clickCameraButton:model];
    }
}


#pragma mark - Private Action

- (void)closeConnectButtonAction {
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedString(@"cancel");
    AlertActionModel *alertConfirmModel = [[AlertActionModel alloc] init];
    alertConfirmModel.title = LocalizedString(@"confirm");
    __weak typeof(self) weakSelf = self;
    alertConfirmModel.alertModelClickBlock = ^(UIAlertAction * _Nonnull action) {
        if(weakSelf.clickCloseConnectBlock) {
            weakSelf.clickCloseConnectBlock();
        }
    };
    NSString *title = @"End all co-host session?";
    NSString *message = @"Co-host with all user will end immediately";
    [[AlertActionManager shareAlertActionManager]
     showWithTitle:title
     message:message
     actions:@[alertCancelModel, alertConfirmModel]
     hideDelay:0];
}

- (void)applicationButtonAction {
    if (self.clickApplicationBlock) {
        self.clickApplicationBlock();
    }
}

- (void)timerMethod {
    self.second++;
    
    NSString *message = @"";
    if (self.second < 60) {
        message = [NSString stringWithFormat:@"%.02lds", (long)self.second % 60];
    } else {
        message = [NSString stringWithFormat:@"%.02ldm %.02lds", (long)self.second / 60, (long)self.second % 60];
    }
    if (self.second > 0) {
        [self updateTimeLabel:message];
    }
}

- (void)updateTimeLabel:(NSString *)time {
    NSString *str1 = LocalizedString(@"co-host_time");
    NSString *str2 = time;
    NSString *all = [NSString stringWithFormat:@"%@ %@", str1, str2];
    NSRange range1 = [all rangeOfString:str1];
    NSRange range2 = [all rangeOfString:str2];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:all];
    
    CGFloat font = 14;
    UIColor *titleColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:1.0 * 255];
    UIColor *timeColor = [UIColor colorFromRGBHexString:@"#FFC95E" andAlpha:1.0 * 255];
    [string addAttribute:NSForegroundColorAttributeName
                             value:titleColor
                             range:range1];
    [string addAttribute:NSForegroundColorAttributeName
                             value:timeColor
                             range:range2];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:font]
                   range:NSMakeRange(0, all.length)];

    self.timeLabel.attributedText = string;
}


#pragma mark - Getter

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        _roomTableView.hidden = YES;
        [_roomTableView registerClass:LiveAddGuestsUserListtCell.class forCellReuseIdentifier:@"LiveAddGuestsUserListtCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        
        UIView *footView = [[UIView alloc] init];
        footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 24);
        _roomTableView.tableFooterView = footView;
    }
    return _roomTableView;
}

- (BaseButton *)applicationButton {
    if (!_applicationButton) {
        _applicationButton = [[BaseButton alloc] init];
        [_applicationButton addTarget:self action:@selector(applicationButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _applicationButton.layer.cornerRadius = 2;
        _applicationButton.layer.masksToBounds = YES;
        CGRect rect = CGRectMake(0, 0, 131, 24);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = rect;
        gradient.colors = @[(id)[UIColor colorFromHexString:@"#FF1764"].CGColor,
                            (id)[UIColor colorFromHexString:@"#ED3596"].CGColor];
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
        [_applicationButton.layer addSublayer:gradient];
        _applicationButton.hidden = YES;
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = rect;
        label.text = LocalizedString(@"co-host_empty_button");
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        label.userInteractionEnabled = NO;
        [_applicationButton addSubview:label];
    }
    return _applicationButton;
}

- (LiveListEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[LiveListEmptyView alloc] init];
        _emptyView.hidden = YES;
        _emptyView.messageString = LocalizedString(@"co-host_empty_online_title");
    }
    return _emptyView;
}

- (BaseButton *)closeConnectButton {
    if (!_closeConnectButton) {
        _closeConnectButton = [[BaseButton alloc] init];
        [_closeConnectButton addTarget:self action:@selector(closeConnectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _closeConnectButton.layer.cornerRadius = 4;
        _closeConnectButton.layer.masksToBounds = YES;
        [_closeConnectButton setTitle:LocalizedString(@"co-host_end") forState:UIControlStateNormal];
        [_closeConnectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeConnectButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _closeConnectButton.backgroundColor = [UIColor colorFromHexString:@"#F53F3F"];
        _closeConnectButton.hidden = YES;
    }
    return _closeConnectButton;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = [UIImage imageNamed:@"ch-host_bottom" bundleName:HomeBundleName];
    }
    return _bottomImageView;
}

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

- (void)dealloc {
    
}

@end
