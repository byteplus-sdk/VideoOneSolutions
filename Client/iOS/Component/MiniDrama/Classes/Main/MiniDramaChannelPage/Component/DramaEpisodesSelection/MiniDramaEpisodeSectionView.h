//
//  MiniDramaEpisodeSectionView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaEpisodeSectionViewDelegate <NSObject>

- (void)onSelectTab:(NSInteger)pageOffset segmentCount:(NSInteger)segmentCount;

@end

@interface MiniDramaEpisodeSectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *cellName;

@property (nonatomic, assign) BOOL isActive;

@end

@interface MiniDramaEpisodeSectionView : UIView;

- (instancetype)initWith:(NSInteger)totalCount segmentCount:(NSInteger)segmentCount;

@property (nonatomic, assign) NSInteger currentTabOrder;

@property (nonatomic, weak) id<MiniDramaEpisodeSectionViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
