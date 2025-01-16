//
//  MiniDramaTrendingSubCell.h
//
//  Created by ByteDance on 2024/11/20.
//

#import "MiniDramaCollectionViewBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaTrendingSubCell : MiniDramaCollectionViewBaseCell

-(void)setMiniDramaData:(NSArray<MDDramaInfoModel *> *)datas startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

@end

NS_ASSUME_NONNULL_END
