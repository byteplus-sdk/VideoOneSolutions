// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingViewController.h"
#import "UIColor+RGB.h"
#import "VESettingDisplayCell.h"
#import "VESettingDisplayDetailCell.h"
#import "VESettingEntranceCell.h"
#import "VESettingManager.h"
#import "VESettingSwitcherCell.h"
#import "VESettingTypeMutilSelectorCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>

extern NSString *universalActionSectionKey;
extern NSString *universalDidSectionKey;
extern NSString *universalVideoUrlSectionKey;

@interface VESettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *navView;

@end

@implementation VESettingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)tabViewDidAppear {
    [super tabViewDidAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
}

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
    }];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[VESettingDisplayCell class] forCellReuseIdentifier:VESettingDisplayCellReuseID];
    [self.tableView registerClass:[VESettingSwitcherCell class] forCellReuseIdentifier:VESettingSwitcherCellReuseID];
    [self.tableView registerClass:[VESettingDisplayDetailCell class] forCellReuseIdentifier:VESettingDisplayDetailCellReuseID];
    [self.tableView registerClass:[VESettingTypeMutilSelectorCell class] forCellReuseIdentifier:VESettingTypeMutilSelectorCellReuseID];
    [self.tableView registerClass:[VESettingEntranceCell class] forCellReuseIdentifier:VESettingEntranceCellCellReuseID];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
}

- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [UIColor veveod_colorWithRGB:0xF7F8FA alpha:1.0];

        BaseButton *button = [[BaseButton alloc] init];
        button.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"black_back" bundleName:@"VodPlayer"];
        button.tintColor = [UIColor whiteColor];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-14);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.text = LocalizedStringFromBundle(@"setting_title", @"VodPlayer");
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_navView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button);
            make.centerX.equalTo(_navView);
        }];
    }
    return _navView;
}

#pragma mark----- UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[VESettingManager universalManager] settingSections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    return settings.count;
}

- (VESettingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:indexPath.section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    VESettingModel *model = [settings objectAtIndex:indexPath.row];
    VESettingCell *cell = [tableView dequeueReusableCellWithIdentifier:model.cellInfo.allKeys.firstObject];
    SettingCellCornerStyle style = SettingCellCornerStyleFull;
    if (settings.count == 1) {
        style = SettingCellCornerStyleFull;
    } else {
        if (indexPath.row == 0) {
            style = SettingCellCornerStyleUp;
        } else if (indexPath.row == settings.count - 1) {
            style = SettingCellCornerStyleBottom;
        } else {
            style = SettingCellCornerStyleMiddle;
        }
    }
    cell.cornerStyle = style;
    //    cell.showTopLine = !indexPath.row;
    [cell performSelector:@selector(setSettingModel:) withObject:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:indexPath.section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    VESettingModel *model = [settings objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    if ([sectionKey isEqualToString:universalActionSectionKey]) {
        return [UIView new];
    } else {
        return ({
            UILabel *headerLabel = [UILabel new];
            headerLabel.text = [NSString stringWithFormat:@"    %@", [[VESettingManager universalManager] sectionKeyLocalized:sectionKey]];
            headerLabel.font = [UIFont systemFontOfSize:14.0];
            headerLabel.textColor = [UIColor veveod_colorWithRGB:0x86909C alpha:1.0];
            headerLabel;
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    if ([sectionKey isEqualToString:universalActionSectionKey] || [sectionKey isEqualToString:universalDidSectionKey] || [sectionKey isEqualToString:universalVideoUrlSectionKey]) {
        return 0;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark----- Lazy Load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor veveod_colorWithRGB:0xF7F8FA alpha:1.0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end
