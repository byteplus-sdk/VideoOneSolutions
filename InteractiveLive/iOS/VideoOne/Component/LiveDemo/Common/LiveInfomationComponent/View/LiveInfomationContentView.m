// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationContentView.h"
#import "LiveInfomationListsView.h"
#import "LiveInfomationTopSelectView.h"

@interface LiveInfomationContentView () <LiveInfomationTopSelectViewDelegate>

@property (nonatomic, strong) LiveInfomationTopSelectView *topSelectView;
@property (nonatomic, strong) LiveInfomationListsView *basicListView;
@property (nonatomic, strong) LiveInfomationListsView *realTimeListView;

@end

@implementation LiveInfomationContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.topSelectView];
        [self.topSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(44);
        }];
        
        [self addSubview:self.basicListView];
        [self.basicListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.top.equalTo(self.topSelectView.mas_bottom);
        }];
        
        [self addSubview:self.realTimeListView];
        [self.realTimeListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.top.equalTo(self.topSelectView.mas_bottom);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (void)refresh {
    [self.basicListView refresh];
    [self.realTimeListView refresh];
}

#pragma mark - Publish Action

- (void)setBasicDataLists:(NSArray *)basicDataLists {
    _basicDataLists = basicDataLists;
    self.basicListView.dataLists = basicDataLists;
}

- (void)setRealTimeDataLists:(NSArray *)realTimeDataLists {
    _realTimeDataLists = realTimeDataLists;
    self.realTimeListView.dataLists = realTimeDataLists;
}

#pragma mark - LiveInfomationTopSelectViewDelegate

- (void)LiveInfomationTopSelectView:(LiveInfomationTopSelectView *)LiveInfomationTopSelectView clickSwitchItem:(NSInteger)index {
    self.basicListView.hidden = (index == 0) ? NO : YES;
    self.realTimeListView.hidden = (index == 1) ? NO : YES;
}

#pragma mark - Getter

- (LiveInfomationTopSelectView *)topSelectView {
    if (!_topSelectView) {
        _topSelectView = [[LiveInfomationTopSelectView alloc] init];
        _topSelectView.delegate = self;
    }
    return _topSelectView;
}

- (LiveInfomationListsView *)basicListView {
    if (!_basicListView) {
        _basicListView = [[LiveInfomationListsView alloc] init];
        _basicListView.hidden = NO;
    }
    return _basicListView;
}

- (LiveInfomationListsView *)realTimeListView {
    if (!_realTimeListView) {
        _realTimeListView = [[LiveInfomationListsView alloc] init];
        _realTimeListView.hidden = YES;
    }
    return _realTimeListView;
}

@end
