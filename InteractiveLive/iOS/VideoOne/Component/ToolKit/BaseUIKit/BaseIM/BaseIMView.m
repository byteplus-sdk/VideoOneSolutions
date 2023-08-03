// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseIMView.h"
#import "Masonry.h"

@interface BaseIMView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) UIView *tableHeaderOffset;

@end

@implementation BaseIMView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.roomTableView.tableHeaderView = self.tableHeaderOffset;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.colors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.1f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.1f].CGColor
        ];
    layer.locations = @[@0, @0.2, @.95, @1];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1);
    layer.frame = self.roomTableView.bounds;

    self.roomTableView.layer.mask = layer;
    
    [self scrollToBottom:NO tableView:self.roomTableView];
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray *)dataLists {
    _dataLists = dataLists;
    if(dataLists.count < 6) {
        float maxHeight = 149 - (dataLists.count - 1) * 30;
        self.tableHeaderOffset.frame = CGRectMake(0, 0, 0, maxHeight);
        self.roomTableView.tableHeaderView = self.tableHeaderOffset;
    } else {
        self.roomTableView.tableHeaderView = nil;
    }
    [self.roomTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom:YES tableView:self.roomTableView];
    });
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseIMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseIMCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataLists[indexPath.row];
    return cell;
}

#pragma mark - Private Action

- (void)scrollToBottom:(BOOL)animated tableView:(UITableView *)tableView {
    NSUInteger sectionCount = [tableView numberOfSections];
    NSUInteger rowCount = 0;
    while (sectionCount != 0) {
        rowCount = [tableView numberOfRowsInSection:sectionCount-1];
        if(rowCount != 0)
            break;
        sectionCount--;
    }
    NSLog(@"rowCount: %ld", rowCount);
    if (sectionCount && rowCount) {
        NSUInteger ii[2] = {sectionCount-1, rowCount-1};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:animated];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.colors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.1f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.1f].CGColor,
        ];
    layer.locations = @[@0, @0.2, @0.95,@1];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1);
    layer.frame = self.roomTableView.bounds;
    self.roomTableView.layer.mask = layer;
}

#pragma mark - Getter


- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        [_roomTableView registerClass:BaseIMCell.class forCellReuseIdentifier:@"BaseIMCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];
        _roomTableView.rowHeight = UITableViewAutomaticDimension;
        _roomTableView.estimatedRowHeight = 30;
        _roomTableView.showsVerticalScrollIndicator = NO;
        _roomTableView.showsHorizontalScrollIndicator = NO;
    
        UIView *footerView = [[UIView alloc] init];
        footerView.frame = CGRectMake(0, 0, 0, 10);
        footerView.backgroundColor = [UIColor clearColor];
        _roomTableView.tableHeaderView = footerView;
    }
    return _roomTableView;
}

- (UIView *)tableHeaderOffset {
    if(!_tableHeaderOffset) {
        _tableHeaderOffset = [[UIView alloc] init];
        _tableHeaderOffset.frame = CGRectMake(0, 0, 0, 149);
        _tableHeaderOffset.backgroundColor = [UIColor clearColor];
    }
    return _tableHeaderOffset;
}


@end
