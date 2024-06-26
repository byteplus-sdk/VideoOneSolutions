// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusRoomTableView.h"
#import "ChorusEmptyComponent.h"

@interface ChorusRoomTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) ChorusEmptyComponent *emptyComponent;

@end


@implementation ChorusRoomTableView

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
    ChorusRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChorusRoomCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if ([self.delegate respondsToSelector:@selector(ChorusRoomTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate ChorusRoomTableView:self didSelectRowAtIndexPath:self.dataLists[indexPath.row]];
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
        [_roomTableView registerClass:ChorusRoomCell.class forCellReuseIdentifier:@"ChorusRoomCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        _roomTableView.rowHeight = UITableViewAutomaticDimension;
        _roomTableView.estimatedRowHeight = 139;
    }
    return _roomTableView;
}

- (ChorusEmptyComponent *)emptyComponent {
    if (!_emptyComponent) {
        _emptyComponent = [[ChorusEmptyComponent alloc] initWithView:self
                                                             rect:CGRectMake(0, 150, 100, 100)
                                                            image:[UIImage imageNamed:@"room_list_empty" bundleName:HomeBundleName]
                                                          message:LocalizedString(@"label_room_empty")];
    }
    return _emptyComponent;
}

@end
