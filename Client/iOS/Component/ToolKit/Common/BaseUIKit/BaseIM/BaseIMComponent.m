// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseIMComponent.h"
#import "BaseIMView.h"
#import "DeviceInforTool.h"
#import "Masonry.h"

@interface BaseIMComponent ()

@property (nonatomic, strong) BaseIMView *baseIMView;

@end

@implementation BaseIMComponent

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
        [superView addSubview:self.baseIMView];
        [self.baseIMView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.bottom.equalTo(superView.mas_safeAreaLayoutGuideBottom).offset(-44);
            make.height.mas_equalTo(184);
            make.right.mas_equalTo(-56);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateRightConstraintValue:(NSInteger)right {
    if (self.baseIMView.superview) {
        [self.baseIMView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(right);
        }];
    }
}

- (void)remakeTopConstraintValue:(NSInteger)top {
    if (self.baseIMView.superview) {
        [self.baseIMView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.bottom.equalTo(self.baseIMView.superview.mas_safeAreaLayoutGuideBottom).offset(-44);
            make.top.mas_equalTo(top);
            make.right.mas_equalTo(-56);
        }];
    }
}

- (void)hidden:(BOOL)isHidden {
    self.baseIMView.hidden = isHidden;
}

- (void)addIM:(BaseIMModel *)model {
    NSMutableArray *datas = [[NSMutableArray alloc] initWithArray:self.baseIMView.dataLists];
    [datas addObject:model];
    self.baseIMView.dataLists = [datas copy];
}

- (void)updaetHidden:(BOOL)isHidden {
    self.baseIMView.hidden = isHidden;
}

- (void)updateUserInteractionEnabled:(BOOL)isEnabled {
    self.baseIMView.userInteractionEnabled = isEnabled;
}

#pragma mark - Getter

- (BaseIMView *)baseIMView {
    if (!_baseIMView) {
        _baseIMView = [[BaseIMView alloc] init];
        _baseIMView.backgroundColor = [UIColor clearColor];
    }
    return _baseIMView;
}

@end
