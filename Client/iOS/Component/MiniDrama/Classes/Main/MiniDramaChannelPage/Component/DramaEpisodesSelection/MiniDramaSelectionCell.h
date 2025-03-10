// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDDramaEpisodeInfoModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSelectionCell : UICollectionViewCell

@property (nonatomic, strong) MDDramaEpisodeInfoModel *dramaVideoInfo;
@property (nonatomic, strong) MDDramaEpisodeInfoModel *curPlayDramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
