// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationListsView.h"

@interface LiveInfomationListsView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;

@end

@implementation LiveInfomationListsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray *)dataLists {
    _dataLists = dataLists;

    self.roomTableView.hidden = dataLists.count > 0 ? NO : YES;

    [self.roomTableView reloadData];
}

- (void)refresh {
    [self.roomTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveInfomationUserListtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveInfomationUserListtCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataLists.count && self.dataLists.count >= indexPath.row) {
        cell.model = self.dataLists[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
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
        _roomTableView.hidden = YES;
        [_roomTableView registerClass:LiveInfomationUserListtCell.class forCellReuseIdentifier:@"LiveInfomationUserListtCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
    }
    return _roomTableView;
}

@end
