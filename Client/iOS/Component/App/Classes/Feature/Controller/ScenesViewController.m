// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "ScenesViewController.h"
#import "Localizator.h"
#import "SceneTableCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface ScenesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ScenesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];
    [self.view addSubview:self.backgroundImgView];
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.top.mas_equalTo(45 + [DeviceInforTool getStatusBarHight]);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(13);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView);
        make.top.equalTo(self.iconImageView.mas_bottom).mas_offset(8);
        make.right.lessThanOrEqualTo(self.view.mas_right).mas_offset(-16);
    }];

    [self.view addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(16);
        make.right.lessThanOrEqualTo(self.view.mas_right).mas_offset(-16);
    }];

    // TableView
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.desLabel.mas_bottom).mas_offset(30);
        make.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - TableView Delegate && Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SceneTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SceneTableCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    __weak __typeof__(self) weakSelf = self;
    [cell setGoAction:^(SceneTableCell *cell, BaseSceneEntrance *_Nonnull model) {
        __strong __typeof__(weakSelf) self = weakSelf;
        [self sceneCell:cell action:model];
    }];
    return cell;
}

#pragma mark - Touch Action

- (void)sceneCell:(SceneTableCell *)cell action:(BaseSceneEntrance *)model {
    // Open the corresponding scene home page
    self.tableView.userInteractionEnabled = NO;

    __weak __typeof__(self) weakSelf = self;
    [model enterSceneWithCallback:^(BOOL result) {
        __strong __typeof__(weakSelf) self = weakSelf;
        self.tableView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Private Action

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
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
        [_tableView registerClass:SceneTableCell.class forCellReuseIdentifier:@"SceneTableCell"];
    }
    return _tableView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.image = [UIImage imageNamed:@"logo_icon" bundleName:@"App"];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        for (NSDictionary *scene in [ScenesViewController scenesList]) {
            BaseSceneEntrance *entrance = [[NSClassFromString(scene[@"className"]) alloc] init];
            if (entrance) {
                entrance.isNew = [scene[@"isNew"] boolValue];
                [_dataArray addObject:entrance];
            }
        }
    }
    return _dataArray;
}

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg" bundleName:@"App"]];
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"Roboto" size:28] ?: [UIFont boldSystemFontOfSize:28];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if (@available(iOS 14.0, *)) {
            _titleLabel.lineBreakStrategy = NSLineBreakStrategyNone;
        }
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
        paraStyle.lineBreakStrategy = NSLineBreakStrategyNone;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:LocalizedStringFromBundle(@"home_title", @"App") attributes:@{
            NSFontAttributeName: _titleLabel.font,
            NSForegroundColorAttributeName: _titleLabel.textColor,
            NSParagraphStyleAttributeName: paraStyle
        }];
        _titleLabel.attributedText = attr;
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor whiteColor];
        _desLabel.font = [UIFont systemFontOfSize:14];
        _desLabel.text = LocalizedStringFromBundle(@"home_des", @"App");
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}

+ (NSArray *)scenesList {
    static NSArray *_scenes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scenes = @[@{@"className": @"InteractiveLive",
                      @"isNew": @(NO)},
                    @{@"className": @"VideoPlaybackEdit",
                      @"isNew": @(YES)},
        ];
    });
    return _scenes;
}

@end
