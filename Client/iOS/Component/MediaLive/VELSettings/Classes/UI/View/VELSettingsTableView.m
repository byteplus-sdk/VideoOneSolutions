// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsTableView.h"
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
@interface VELSettingsTableView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDate *lastTouchDate;
@end

@implementation VELSettingsTableView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _showsVerticalScrollIndicator = YES;
        _showsHorizontalScrollIndicator = YES;
        _headerHeight = 0.01;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setAllowSelection:(BOOL)allowSelection {
    _allowSelection = allowSelection;
    self.tableView.allowsSelection = allowSelection;
}

- (void)setAllowDelete:(BOOL)allowDelete {
    _allowDelete = allowDelete;
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator {
    _showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    self.tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator {
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    self.tableView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
}

- (void)setModels:(NSArray<__kindof VELSettingsBaseViewModel *> *)models {
    _models = models;
    [models enumerateObjectsUsingBlock:^(VELSettingsBaseViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView registerClass:obj.tableViewCellClass forCellReuseIdentifier:obj.identifier];
    }];
    
    [self.tableView reloadData];
}

- (void)selecteIndex:(NSInteger)index animation:(BOOL)animation {
    if (!self.allowSelection || index < 0 || index >= self.models.count) {
        return;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                animated:animation
                          scrollPosition:(UITableViewScrollPositionNone)];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.header ?: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.01)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.01)];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VELSettingsBaseViewModel *model = self.models[indexPath.row];
    if (model.size.height > 0) {
        return model.size.height;
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.models[indexPath.row].identifier
                                                            forIndexPath:indexPath];
    [(id <VELSettingsUIViewProtocol>)cell setModel:self.models[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastTouchDate != nil && [NSDate.date timeIntervalSinceDate:self.lastTouchDate] < 0.2) {
        self.lastTouchDate = [NSDate date];
        return;
    }
    self.lastTouchDate = [NSDate date];
    VELSettingsBaseViewModel *model = self.models[indexPath.row];
    if (self.selectedItemBlock) {
        self.selectedItemBlock(model, indexPath.row);
    }
    if (model.selectedBlock) {
        model.selectedBlock(model, indexPath.row);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.allowDelete;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.models];
        VELSettingsBaseViewModel *model = [self.models objectAtIndex:indexPath.row];
        [array removeObjectAtIndex:indexPath.row];
        self.models = array;
        if (self.deleteItemBlock) {
            self.deleteItemBlock(model, indexPath.row);
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LocalizedStringFromBundle(@"medialive_delete", @"MediaLive");
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.tableView.backgroundColor = backgroundColor;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.allowsMultipleSelection = NO;
        _tableView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator;
        _tableView.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            _tableView.insetsContentViewsToSafeArea = NO;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 1/UIScreen.mainScreen.scale)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 1/UIScreen.mainScreen.scale)];
        _tableView.backgroundColor = VELViewBackgroundColor;
    }
    return _tableView;
}
@end
