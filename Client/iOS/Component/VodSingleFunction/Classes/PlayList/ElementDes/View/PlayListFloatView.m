// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayListFloatView.h"
#import "PlayListCell.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface PlayListFloatView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITableView *playListTable;

@end

@implementation PlayListFloatView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUIComponent];
    }
    return self;
}


- (void)createUIComponent {
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
        make.width.mas_equalTo(375);
    }];
    [self.contentView addSubview:self.playListTable];
    [self.playListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.contentView);
    }];
}

- (void)maskViewAction {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark EventListener
- (void)show{
    UIView *parentView = [DeviceInforTool topViewController].view;
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    __weak __typeof__(self) weak_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weak_self.playListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weak_self.currentPlayViewIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return 96;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:PlayListFloatTableCellIdentify forIndexPath:indexPath];
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


#pragma mark - Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 5;
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];
    }
    return _contentView;
}

- (UITableView *)playListTable {
    if (!_playListTable) {
        _playListTable = [[UITableView alloc] init];
        _playListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _playListTable.delegate = self;
        _playListTable.dataSource = self;
        [_playListTable registerClass:[PlayListCell class] forCellReuseIdentifier:PlayListFloatTableCellIdentify];
        _playListTable.backgroundColor = [UIColor clearColor];
    }
    return _playListTable;
}

@end
