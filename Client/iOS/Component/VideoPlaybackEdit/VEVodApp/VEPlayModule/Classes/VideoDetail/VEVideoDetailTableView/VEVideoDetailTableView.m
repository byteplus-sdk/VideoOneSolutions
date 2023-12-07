// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEVideoDetailTableView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>
#import <MJRefresh/MJRefresh.h>
#import "UIScrollView+Refresh.h"

@interface VEVideoDetailTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation VEVideoDetailTableView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(@(1));
        }];
        
        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(@(16));
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray<VEVideoModel *> *)dataLists {
    _dataLists = dataLists;

    [self.roomTableView reloadData];
}

- (void)endRefreshingWithNoMoreData {
    [self.roomTableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)endRefresh {
    [self.roomTableView.mj_footer endRefreshing];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VEVideoDetailCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtModel:)]) {
        [self.delegate tableView:self didSelectRowAtModel:self.dataLists[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}

#pragma mark - Getter

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:VEVideoDetailCell.class forCellReuseIdentifier:@"VEVideoDetailCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        __weak __typeof(self) wself = self;
        _roomTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if ([wself.delegate respondsToSelector:@selector(tableView:loadDataWithMore:)]) {
                [wself.delegate tableView:wself loadDataWithMore:YES];
            }
        }];
    }
    return _roomTableView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
