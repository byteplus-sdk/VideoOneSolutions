//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionTableView.h"
#import "FunctionTableCell.h"
#import <Masonry/Masonry.h>


@interface FunctionTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) BaseFunctionDataList *tableModel;


@end

@implementation FunctionTableView

- (instancetype)initWithDataList:(BaseFunctionDataList *)dataList {
    self = [super init];
    if (self) {
        _tableModel = dataList;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

}

#pragma mark - TableView Delegate && Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableModel.items.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = self.tableModel.items[section].tableSectionName ?: @"";
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.text = title;
    titleLable.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    titleLable.textColor = [UIColor colorFromRGBHexString:@"#737A87"];
    
    UIView *contentView = [[UIView alloc] init];
    [contentView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.leading.equalTo(contentView).offset(32);
        make.top.equalTo(contentView).offset(8);
    }];
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = self.tableModel.items[section].tableSectionName;
    return title ? 25 : 0 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BaseFunctionSection *sectionModel = self.tableModel.items[section];
    return sectionModel.items.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseFunctionSection *sectionModel = self.tableModel.items[indexPath.section];
    BaseFunctionEntrance *model = sectionModel.items[indexPath.row];
    return model.height + model.marginTop + model.marginBottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BaseFunctionSection *sectionModel = self.tableModel.items[indexPath.section];
    BaseFunctionEntrance *model = sectionModel.items[indexPath.row];
    [self sceneCellAction:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FunctionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionTableCell" forIndexPath:indexPath];
    BaseFunctionSection *sectionModel = self.tableModel.items[indexPath.section];
    BaseFunctionEntrance *model = sectionModel.items[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)sceneCellAction:(BaseFunctionEntrance *)model {
    self.tableView.userInteractionEnabled = NO;

    __weak __typeof__(self) weakSelf = self;
    [model enterWithCallback:^(BOOL result) {
        __strong __typeof__(weakSelf) self = weakSelf;
        self.tableView.userInteractionEnabled = YES;
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0;
        [_tableView registerClass:FunctionTableCell.class forCellReuseIdentifier:@"FunctionTableCell"];
    }
    return _tableView;
}

@end
