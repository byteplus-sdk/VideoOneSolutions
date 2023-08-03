// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePKListsView.h"
#import "LiveListEmptyView.h"

@interface LivePKListsView () <UITableViewDelegate, UITableViewDataSource, LivePKCellDelegate>

@property (nonatomic, strong) LiveListEmptyView *emptyView;
@property (nonatomic, strong) UITableView *roomTableView;

@end

@implementation LivePKListsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.emptyView];
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(60);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
        }];

        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray<LiveUserModel *> *)dataLists {
    _dataLists = dataLists;

    self.emptyView.hidden = dataLists.count > 0 ? YES : NO;
    self.roomTableView.hidden = dataLists.count > 0 ? NO : YES;

    [self.roomTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LivePKCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LivePKCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexStr = @(indexPath.row + 1).stringValue;
    cell.model = self.dataLists[indexPath.row];
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

#pragma mark - LivePKCellDelegate

- (void)LivePKCell:(LivePKCell *)LivePKCell clickButton:(id)model {
    if ([self.delegate respondsToSelector:@selector(LivePKListsView:clickButton:)]) {
        [self.delegate LivePKListsView:self clickButton:model];
    }
}

#pragma mark - Getter

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:LivePKCell.class forCellReuseIdentifier:@"LivePKCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        
        UIView *headView = [[UIView alloc] init];
        headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
        
        UIView *footView = [[UIView alloc] init];
        footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 24);
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        label.textColor = [UIColor colorFromHexString:@"#CCCED0"];
        label.numberOfLines = 2;
        [headView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(-16);
            make.centerY.equalTo(headView);
        }];
        label.text = LocalizedString(@"pk_list_head_title");
        _roomTableView.tableHeaderView = headView;
        _roomTableView.tableFooterView = footView;
        _roomTableView.hidden = YES;
    }
    return _roomTableView;
}

- (LiveListEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[LiveListEmptyView alloc] init];
        _emptyView.messageString = LocalizedString(@"pk_empty_title");
        _emptyView.hidden = YES;
    }
    return _emptyView;
}

@end
