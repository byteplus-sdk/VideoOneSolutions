// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaCollectionViewBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaTrendingSubCell : MiniDramaCollectionViewBaseCell

-(void)setMiniDramaData:(NSArray<MDDramaInfoModel *> *)datas startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

@end

NS_ASSUME_NONNULL_END
