// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusPickSongListView.h"
#import "ChorusEmptyComponent.h"

@interface ChorusPickSongListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) ChorusSongListViewType type;
@property (nonatomic, strong) ChorusEmptyComponent *emptyComponent;

@end

@implementation ChorusPickSongListView

- (instancetype)initWithType:(ChorusSongListViewType)type {
    if (self = [super init]) {
        self.type = type;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataArray:(NSArray<ChorusSongModel *> *)dataArray {
    _dataArray = dataArray;
    
    if (dataArray.count <= 0) {
        [self.emptyComponent show];
    } else {
        [self.emptyComponent dismiss];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChorusPickSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChorusPickSongTableViewCell class]) forIndexPath:indexPath];
    cell.type = self.type;
    
    if (indexPath.row < self.dataArray.count) {
        cell.songModel = self.dataArray[indexPath.row];
    }
    
    __weak typeof(self) weakSelf = self;
    cell.pickSongBlock = ^(ChorusSongModel * _Nonnull model) {
        if (weakSelf.pickSongBlock) {
            weakSelf.pickSongBlock(model);
        }
    };
    return cell;
}

- (void)refreshView {
    [self.tableView reloadData];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 72;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, [DeviceInforTool getVirtualHomeHeight], 0);
        _tableView.backgroundColor = UIColor.clearColor;
        
        [_tableView registerClass:[ChorusPickSongTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ChorusPickSongTableViewCell class])];
    }
    return _tableView;
}

- (ChorusEmptyComponent *)emptyComponent {
    if (!_emptyComponent) {
        _emptyComponent = [[ChorusEmptyComponent alloc] initWithView:self
                                                             rect:CGRectMake(0, 120, 100, 100)
                                                            image:[UIImage imageNamed:@"label_music_empty" bundleName:HomeBundleName]
                                                          message:LocalizedString(@"label_music_empty")];
        [_emptyComponent updateMessageLabelTextColor:[UIColor whiteColor]];
    }
    return _emptyComponent;
}

@end
