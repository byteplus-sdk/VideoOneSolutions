// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPopupMenuView.h"
#import "VELSettingsTableView.h"
@interface VELSettingsPopupMenuView ()
@property (nonatomic, strong) VELSettingsTableView *tableView;
@end
@implementation VELSettingsPopupMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.distanceBetweenSource = 0;
        self.preferLayoutDirection = VELPopupLayoutDirectionRight;
        [self.contentView addSubview:self.tableView];
    }
    return self;
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    __block CGFloat width = 0;
    __block CGFloat height = 0;
    [self.menuModels enumerateObjectsUsingBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        width = MAX(width, obj.size.width);
        height += MAX(obj.size.height, 8);
    }];
    size.width = width;
    size.height = height;
    return size;
}
- (void)setMenuModels:(NSArray<__kindof VELSettingsBaseViewModel *> *)menuModels {
    _menuModels = menuModels;
    self.tableView.models = menuModels;
    [self setSelectIndex:_selectIndex];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    [self.tableView reloadData];
    [self.tableView selecteIndex:selectIndex animation:NO];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.contentView.bounds;
}

- (VELSettingsTableView *)tableView {
    if (!_tableView) {
        _tableView = [[VELSettingsTableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowSelection = YES;
        _tableView.backgroundColor = UIColor.clearColor;
        __weak __typeof__(self)weakSelf = self;
        [_tableView setSelectedItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.didSelectedModelBlock) {
                self.didSelectedModelBlock(self, model, index);
            }
            [self hideWithAnimated:YES];
        }];
    }
    return _tableView;
}

@end
