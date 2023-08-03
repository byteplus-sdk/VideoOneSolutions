// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingViewController.h"
#import "LiveSettingCell.h"
#import "LiveSettingData.h"

@interface LiveSettingViewController () <UITableViewDelegate, UITableViewDataSource, LiveSettingCellDelegate>
@property (nonatomic, strong) UIImageView *backgroundTopImgView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<NSNumber *> *optionList;

@end

@implementation LiveSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navTitle = LocalizedString(@"live_setting");
    self.navTitleColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor colorFromRGBHexString:@"#F6F8FA"];
    [self.bgView removeFromSuperview];
    self.navLeftImage = [UIImage imageNamed:@"interact_live_back" bundleName:HomeBundleName];
    
    [self.view addSubview:self.backgroundTopImgView];
    [self.backgroundTopImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(88);
    }];
    [self.view insertSubview:self.backgroundTopImgView belowSubview:self.navView];
    self.navView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(12);
        make.right.mas_equalTo(self.view).offset(-13);
        make.top.mas_equalTo(self.navView.mas_bottom).offset(16);
        make.height.mas_equalTo(238);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - LiveSettingCellDelegate
- (void)saveSettingInfo:(LiveSettingCellType)cellType isOn:(BOOL)isOn {
    switch(cellType) {
        case LiveSettingRTMPullStreaming:
            [LiveSettingData setRtmPullStreaming:isOn];
            if(isOn) {
                [LiveSettingData setAbr:NO];
                for(NSInteger  row = 0; row < [self.tableView  numberOfRowsInSection:0]; row++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    LiveSettingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if(cell.cellType == LiveSettingABR) {
                        cell.isOn = NO;
                        break;
                    }
                }
            }
            break;
        case LiveSettingRTMPushStreaming:
            [LiveSettingData setRtmPushStreaming:isOn];
            break;
        case LiveSettingABR:
            [LiveSettingData setAbr:isOn];
            if(isOn) {
                [LiveSettingData setRtmPullStreaming:NO];
                for(NSInteger  row = 0; row < [self.tableView  numberOfRowsInSection:0]; row++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    LiveSettingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if(cell.cellType == LiveSettingRTMPullStreaming) {
                        cell.isOn = NO;
                        break;
                    }
                }
            }
            break;
        defaults:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveSettingListCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellType = self.optionList[indexPath.row].integerValue;
    cell.isOn = [LiveSettingData boolValueForKey:cell.cellType];
    cell.delegate = self;
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 3) {
        return 90;
    } else {
        return 74;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionList.count;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Getter
- (UIImageView *)backgroundTopImgView {
    if(!_backgroundTopImgView) {
        _backgroundTopImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_background" bundleName:HomeBundleName]];
        _backgroundTopImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundTopImgView;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:LiveSettingCell.class forCellReuseIdentifier:@"LiveSettingListCellID"];
        _tableView.layer.cornerRadius = 8;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)optionList {
    if(!_optionList) {
        _optionList = @[@1, @2, @3];
    }
    return _optionList;
}

 @end
