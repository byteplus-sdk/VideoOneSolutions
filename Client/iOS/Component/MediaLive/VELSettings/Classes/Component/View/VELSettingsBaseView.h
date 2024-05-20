// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <MediaLive/VELCommon.h>
#import "VELSettingsBaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface VELSettingsBaseView <__covariant ObjectType> : UIView <VELSettingsUIViewProtocol>
@property (nonatomic, strong) ObjectType model;
@property (nonatomic, strong, readonly) UIView *container;

@property (nonatomic, assign) BOOL enable;
- (void)initSubviewsInContainer:(UIView *)container;
- (void)layoutSubViewWithModel NS_REQUIRES_SUPER;
- (void)updateSubViewStateWithModel NS_REQUIRES_SUPER;
@end
@interface VELSettingsBaseCollectionCell <__covariant ObjectType> : UICollectionViewCell <VELSettingsUIViewProtocol>
@property (nonatomic, strong) ObjectType model;
@property (nonatomic, assign) BOOL enable;
@end
@interface VELSettingsBaseTableCell <__covariant ObjectType> : UITableViewCell <VELSettingsUIViewProtocol>
@property (nonatomic, strong) ObjectType model;
@property (nonatomic, assign) BOOL enable;
@end

NS_ASSUME_NONNULL_END
