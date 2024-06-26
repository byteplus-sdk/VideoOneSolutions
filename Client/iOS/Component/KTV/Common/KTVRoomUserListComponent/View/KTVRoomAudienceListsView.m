// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomAudienceListsView.h"
#import "KTVEmptyComponent.h"

@interface KTVRoomAudienceListsView ()<UITableViewDelegate, UITableViewDataSource, KTVRoomUserListtCellDelegate>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) KTVEmptyComponent *emptyComponent;

@end


@implementation KTVRoomAudienceListsView


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
    if ([self.delegate respondsToSelector:@selector(KTVRoomAudienceListsView:clickButton:)]) {
        [self.delegate KTVRoomAudienceListsView:self clickButton:model];
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
                                                             rect:CGRectMake(0, 120, 100, 100)
                                                            image:[UIImage imageNamed:@"list_user_empty" bundleName:HomeBundleName]
                                                          message:LocalizedString(@"label_user_list_empty")];
        [_emptyComponent updateMessageLabelTextColor:[UIColor whiteColor]];
    }
    return _emptyComponent;
}

- (void)dealloc {
    VOLogI(VOKTV,@"dealloc %@",NSStringFromClass([self class]));
}

@end
