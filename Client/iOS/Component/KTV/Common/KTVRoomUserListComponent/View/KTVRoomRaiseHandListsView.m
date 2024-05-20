// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomRaiseHandListsView.h"
#import "KTVEmptyComponent.h"

@interface KTVRoomRaiseHandListsView ()<UITableViewDelegate, UITableViewDataSource, KTVRoomUserListtCellDelegate>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) KTVEmptyComponent *emptyComponent;

@end

@implementation KTVRoomRaiseHandListsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(@12);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray *)dataLists {
    _dataLists = dataLists;
    
    [self.roomTableView reloadData];
    if (dataLists.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KClearRedNotification object:nil];
    }
    if (dataLists.count <= 0) {
        [self.emptyComponent show];
    } else {
        [self.emptyComponent dismiss];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KTVRoomUserListtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KTVRoomUserListtCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    cell.indexRow = indexPath.row;
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

#pragma mark - KTVRoomUserListtCellDelegate

- (void)KTVRoomUserListtCell:(KTVRoomUserListtCell *)KTVRoomUserListtCell clickButton:(id)model {
    if ([self.delegate respondsToSelector:@selector(KTVRoomRaiseHandListsView:clickButton:)]) {
        [self.delegate KTVRoomRaiseHandListsView:self clickButton:model];
    }
}

#pragma mark - getter

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:KTVRoomUserListtCell.class forCellReuseIdentifier:@"KTVRoomUserListtCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
    }
    return _roomTableView;
}

- (KTVEmptyComponent *)emptyComponent {
    if (!_emptyComponent) {
        _emptyComponent = [[KTVEmptyComponent alloc] initWithView:self
                                                             rect:CGRectZero
                                                            image:nil
                                                          message:LocalizedString(@"label_raise_hand_list_empty")];
    }
    return _emptyComponent;
}

- (void)dealloc {
    NSLog(@"dealloc %@",NSStringFromClass([self class]));
}

@end
