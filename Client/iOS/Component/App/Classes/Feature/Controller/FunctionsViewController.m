//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionsViewController.h"
#import "FunctionTableCell.h"
#import "Localizator.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface FunctionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation FunctionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];

    [self.view addSubview:self.backgroundImgView];
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
    }];

    // TableView
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(71);
        make.left.right.bottom.equalTo(self.view);
    }];
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
    BaseFunctionEntrance *model = self.dataArray[indexPath.row];
    [self sceneCellAction:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FunctionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionTableCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - Touch Action

- (void)sceneCellAction:(BaseFunctionEntrance *)model {
    self.tableView.userInteractionEnabled = NO;

    __weak __typeof__(self) weakSelf = self;
    [model enterWithCallback:^(BOOL result) {
        __strong __typeof__(weakSelf) self = weakSelf;
        self.tableView.userInteractionEnabled = YES;
    }];
}

#pragma mark - Private Action

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 121.0;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:FunctionTableCell.class forCellReuseIdentifier:@"FunctionTableCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        BaseFunctionSection *section = [[NSClassFromString(@"VODFunctionSection") alloc] init];
        if (section) {
            [_dataArray addObjectsFromArray:section.items];
        }
    }
    return _dataArray;
}

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_bg" bundleName:@"App"]];
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textColor = [UIColor colorWithRed:0.114 green:0.129 blue:0.161 alpha:1.0];
        _titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:28] ?: [UIFont boldSystemFontOfSize:28];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if (@available(iOS 14.0, *)) {
            _titleLabel.lineBreakStrategy = NSLineBreakStrategyNone;
        }
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
        paraStyle.lineBreakStrategy = NSLineBreakStrategyNone;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:LocalizedStringFromBundle(@"function_title", @"App") attributes:@{
            NSFontAttributeName: _titleLabel.font,
            NSForegroundColorAttributeName: _titleLabel.textColor,
            NSParagraphStyleAttributeName: paraStyle
        }];
        _titleLabel.attributedText = attr;
    }
    return _titleLabel;
}

@end
