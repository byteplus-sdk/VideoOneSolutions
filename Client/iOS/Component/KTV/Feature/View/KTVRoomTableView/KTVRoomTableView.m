// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomTableView.h"
#import "KTVEmptyComponent.h"
#import <ToolKit/ToolKit.h>

@interface KTVRoomTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) KTVEmptyComponent *emptyComponent;

@end


@implementation KTVRoomTableView

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
    
    [self.roomTableView reloadData];
    if (dataLists.count <= 0) {
        [self.emptyComponent show];
    } else {
        [self.emptyComponent dismiss];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KTVRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KTVRoomCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([self.delegate respondsToSelector:@selector(KTVRoomTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate KTVRoomTableView:self didSelectRowAtIndexPath:self.dataLists[indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}


#pragma mark - getter


- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:KTVRoomCell.class forCellReuseIdentifier:@"KTVRoomCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        _roomTableView.rowHeight = UITableViewAutomaticDimension;
        _roomTableView.estimatedRowHeight = 100;
        _roomTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 52 + [DeviceInforTool getVirtualHomeHeight] + 12)];
    }
    return _roomTableView;
}

- (KTVEmptyComponent *)emptyComponent {
    if (!_emptyComponent) {
        _emptyComponent = [[KTVEmptyComponent alloc] initWithView:self
                                                             rect:CGRectMake(0, 150, 100, 100)
                                                            image:[UIImage imageNamed:@"room_list_empty" bundleName:HomeBundleName]
                                                          message:LocalizedString(@"label_room_list_empty")];
    }
    return _emptyComponent;
}

@end
