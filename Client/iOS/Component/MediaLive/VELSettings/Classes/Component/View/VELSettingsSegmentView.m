// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsSegmentView.h"
#import <MediaLive/VELCommon.h>
#import "VELSettingsCollectionView.h"
@interface VELSettingsSegmentView ()
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELSettingsCollectionView *settingsCollectionView;
@end

@implementation VELSettingsSegmentView

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    [container addSubview:self.settingsCollectionView];
    [self.settingsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    __weak __typeof__(self)weakSelf = self;
    [self.settingsCollectionView setSelectedItemBlock:^(__kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (self.model.segmentSelectedBlock) {
            self.model.segmentSelectedBlock(index);
        }
        if (self.model.segmentModelSelectedBlock) {
            self.model.segmentModelSelectedBlock((VELSettingsButtonViewModel *)model, index);
        }
        self.model.selectIndex = index;
    }];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    VELSettingsSegmentViewModel *model = self.model;
    self.settingsCollectionView.itemMargin = self.model.itemMargin;
    self.settingsCollectionView.scrollDirection = self.model.scrollDirection;
    if (model.selectIndex < 0 || model.selectIndex >= model.segmentModels.count) {
        model.selectIndex = 0;
    }
    __block CGFloat height = 0;
    __block BOOL shouldUseModelHeight = YES;
    [self.model.segmentModels enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.size.height <= 0) {
            shouldUseModelHeight = NO;
        }
        height += obj.size.height;
    }];
    height += (self.model.segmentModels.count - 1) * self.model.itemMargin;
    if (VEL_IS_EMPTY_STRING(self.model.title)) {
        [self.settingsCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.container).mas_offset(0);
            make.top.equalTo(self.container).mas_offset(model.insets.top);
            make.right.equalTo(self.container).mas_offset(0);
            if (self.model.containerSize.height < 0) {
                if (self.model.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                    make.height.mas_equalTo(self.model.showPoint ? 66 : 33);
                } else if (shouldUseModelHeight) {
                    make.height.mas_equalTo(height);
                }
                make.bottom.lessThanOrEqualTo(self.container).mas_offset(-model.insets.bottom);
            } else {
                make.bottom.equalTo(self.container).mas_offset(-model.insets.bottom);
            }
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.container);
        }];
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).mas_offset(model.insets.top);
            make.left.equalTo(self.container).mas_offset(model.insets.left);
            make.right.equalTo(self.container).mas_offset(-model.insets.right);
        }];
        [self.settingsCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(model.spacingBetweenTitleAndSegments);
            make.left.equalTo(self.container);
            make.right.equalTo(self.container);
            if (self.model.containerSize.height < 0) {
                if (self.model.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                    make.height.mas_equalTo(self.model.showPoint ? 66 : 33);
                } else if (shouldUseModelHeight) {
                    make.height.mas_equalTo(height);
                }
                make.bottom.lessThanOrEqualTo(self.container.mas_bottom).mas_offset(-model.insets.bottom);
            } else {
                make.bottom.equalTo(self.container.mas_bottom).mas_offset(-model.insets.bottom);
            }
        }];
    }
    self.settingsCollectionView.models = model.segmentModels;
    [self.settingsCollectionView selecteIndex:model.selectIndex animation:NO];
    if (self.model.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        if (self.model.alignment == UIControlContentHorizontalAlignmentCenter) {
            self.settingsCollectionView.layoutMode = VELCollectionViewLayoutModeCenter;
        } else if (self.model.alignment == UIControlContentHorizontalAlignmentLeft) {
            self.settingsCollectionView.layoutMode = VELCollectionViewLayoutModeLeft;
        }
    } else {
        self.settingsCollectionView.layoutMode = VELCollectionViewLayoutModeLeft;
    }
}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    self.titleLabel.hidden = VEL_IS_EMPTY_STRING(self.model.title);
    self.titleLabel.textAttributes = self.model.titleAttributes;
    self.titleLabel.text = self.model.title;
    self.settingsCollectionView.allowSelection = !self.model.disableSelectd;
    [self.settingsCollectionView reloadData];
    [self.settingsCollectionView selecteIndex:self.model.selectIndex animation:NO];
}

- (VELSettingsCollectionView *)settingsCollectionView {
    if (!_settingsCollectionView) {
        _settingsCollectionView = [[VELSettingsCollectionView alloc] init];
        _settingsCollectionView.allowSelection = YES;
    }
    return _settingsCollectionView;
}
- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.hidden = YES;
        [_titleLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired)
                                                     forAxis:(UILayoutConstraintAxisVertical)];
    }
    return _titleLabel;
}
@end
