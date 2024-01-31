// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayListView.h"
#import "PlayListCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>


@interface PlayListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *playListTable;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation PlayListView

#pragma mark UITableViewDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(@(1));
        }];
        
        [self addSubview:self.playListTable];
        [self.playListTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(@(16));
        }];
    }
    return self;
}

- (void)scroll:(NSInteger)index {
    __weak __typeof__(self) weak_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weak_self.playListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_playListTable deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row != self.currentPlayViewIndex) {
        if ([self.delegate respondsToSelector:@selector(onChangeCurrentVideo:index:)]) {
            [self.delegate onChangeCurrentVideo:self.playList[indexPath.row] index:indexPath.row];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:PlayListTableCellIdentify forIndexPath:indexPath];
    cell.model = self.playList[indexPath.row];
    cell.isPlaying = self.currentPlayViewIndex == indexPath.row;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playList.count;
}

- (void)setCurrentPlayViewIndex:(NSInteger)currentPlayViewIndex {
    _currentPlayViewIndex = currentPlayViewIndex;
    [self.playListTable reloadData];
    if (self.superview) {
        __weak __typeof__(self) weak_self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_self.playListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weak_self.currentPlayViewIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (void)setPlayList:(NSArray<VEVideoModel *> *)playList {
    _playList = playList;
    [self.playListTable reloadData];
}

#pragma mark Getter

- (UITableView *)playListTable {
    if (!_playListTable) {
        _playListTable = [[UITableView alloc] init];
        _playListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _playListTable.delegate = self;
        _playListTable.dataSource = self;
        [_playListTable registerClass:[PlayListCell class] forCellReuseIdentifier:PlayListTableCellIdentify];
        _playListTable.backgroundColor = [UIColor clearColor];
    }
    return _playListTable;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
    }
    return _lineView;
}

@end
