//
//  MiniDramaSelectionCell.h
//  MDPlayModule
//

#import <UIKit/UIKit.h>
#import "MDDramaEpisodeInfoModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSelectionCell : UICollectionViewCell

@property (nonatomic, strong) MDDramaEpisodeInfoModel *dramaVideoInfo;
@property (nonatomic, strong) MDDramaEpisodeInfoModel *curPlayDramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
