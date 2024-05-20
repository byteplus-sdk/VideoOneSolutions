//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionsViewController.h"
#import "FunctionTableCell.h"
#import "Localizator.h"
#import "SectionListView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>


@interface FunctionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SectionListView *sectionListView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray <BaseFunctionSection *> *sectionDataArray;
@property (nonatomic, assign) NSInteger curSectionRow;

@end

@implementation FunctionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];
    [self addSubvieAndMakeConstraints];
    __weak __typeof(self) wself = self;
    self.sectionListView.clickBlock = ^(NSInteger row) {
        wself.curSectionRow = row;
        [wself.tableView reloadData];
    };
}

#pragma mark - TableView Delegate && Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sectionDataArray.count <= 0) {
        return 0;
    }
    BaseFunctionSection *sectionModel = self.sectionDataArray[self.curSectionRow];
    return sectionModel.items.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BaseFunctionSection *sectionModel = self.sectionDataArray[self.curSectionRow];
    BaseFunctionEntrance *model = sectionModel.items[indexPath.row];
    [self sceneCellAction:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FunctionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionTableCell" forIndexPath:indexPath];
    BaseFunctionSection *sectionModel = self.sectionDataArray[self.curSectionRow];
    cell.model = sectionModel.items[indexPath.row];
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
- (void)addSubvieAndMakeConstraints {
    [self.view addSubview:self.backgroundImgView];
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
    }];
    
    [self.view addSubview:self.sectionListView];
    [self.sectionListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(31);
        make.height.equalTo(@36);
    }];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sectionListView.mas_bottom).offset(20);
        make.left.right.bottom.equalTo(self.view);
    }];
}


#pragma mark - Getter
- (SectionListView *)sectionListView {
    if (!_sectionListView) {
        _sectionListView = [[SectionListView alloc] initWithList:self.sectionDataArray];
    }
    return _sectionListView;
}


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

- (NSArray<BaseFunctionSection *> *)sectionDataArray {
    if (!_sectionDataArray) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        BaseFunctionSection *section = [[NSClassFromString(@"VODFunctionSection") alloc] init];
        if (section) {
            [list addObject:section];
        }
        _sectionDataArray = [list copy];
    }
    return _sectionDataArray;
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
