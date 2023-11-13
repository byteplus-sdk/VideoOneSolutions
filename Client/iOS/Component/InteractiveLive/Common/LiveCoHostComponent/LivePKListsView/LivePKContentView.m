// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LivePKContentView.h"
#import "LivePKListsView.h"
#import "LivePKTopView.h"

@interface LivePKContentView () <LivePKListsViewDelegate>

@property (nonatomic, strong) LivePKListsView *listsView;
@property (nonatomic, strong) LivePKTopView *topSelectView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *bottomImageView;

@end

@implementation LivePKContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.bgImageView];
        [self addSubview:self.bottomView];
        [self addSubview:self.listsView];
        [self addSubview:self.topSelectView];
        [self addSubview:self.bottomImageView];

        [self.listsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_offset(280 + [DeviceInforTool getVirtualHomeHeight]);
            make.bottom.mas_offset(0);
        }];

        [self.topSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.listsView.mas_top);
            make.height.mas_equalTo(50);
        }];

        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.topSelectView);
            make.height.mas_equalTo(143);
        }];

        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(self.bgImageView.mas_bottom);
        }];

        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(24 + [DeviceInforTool getVirtualHomeHeight]);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setDataLists:(NSArray<LiveUserModel *> *)dataLists {
    _dataLists = dataLists;

    self.listsView.dataLists = dataLists;
}

#pragma mark - Publish Action LivePKListsViewDelegate

- (void)LivePKListsView:(LivePKListsView *)LivePKListsView
            clickButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(livePKContentView:clickButton:)]) {
        [self.delegate livePKContentView:self clickButton:model];
    }
}

#pragma mark - Getter

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = [UIImage imageNamed:@"pk_bottom" bundleName:HomeBundleName];
    }
    return _bottomImageView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor colorFromHexString:@"#161823"];
        _bgImageView.image = [UIImage imageNamed:@"pk_bg" bundleName:HomeBundleName];

        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, 143);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = rect;
        layer.path = path.CGPath;
        _bgImageView.layer.mask = layer;
    }
    return _bgImageView;
}

- (LivePKListsView *)listsView {
    if (!_listsView) {
        _listsView = [[LivePKListsView alloc] init];
        _listsView.delegate = self;
        _listsView.backgroundColor = [UIColor clearColor];
    }
    return _listsView;
}

- (LivePKTopView *)topSelectView {
    if (!_topSelectView) {
        _topSelectView = [[LivePKTopView alloc] init];
        _topSelectView.titleStr = LocalizedString(@"pk_invite_title");
    }
    return _topSelectView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorFromHexString:@"#161823"];
    }
    return _bottomView;
}

@end
