//
//  MiniDramaSelectionFloatView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/12/2.
//

#import "MDDramaEpisodeInfoModel.h"
#import "MiniDramaSelectionViewController.h"
#import "MiniDramaEpisodeSelectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSelectionFloatView : UIView

@property (nonatomic, weak) id<MiniDramaSelectionViewDelegate> delegate;

- (instancetype)initWtihDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo dramaList:(NSArray<MDDramaEpisodeInfoModel *> *)dramaVideoModels;

@property (nonatomic, copy) NSString *dramaCoverUrl;

@property (nonatomic, copy) NSString *dramaTitle;

@property (nonatomic, strong) NSArray<MDDramaEpisodeInfoModel *> *dramaVideoModels;

- (void)updateCurrentDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)show;
@end

NS_ASSUME_NONNULL_END
