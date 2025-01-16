//
//  MiniDramaSelectionView.h
//  MDPlayModule
//

#import <UIKit/UIKit.h>

@class MDDramaFeedInfo;

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaSelectionViewHeight 40

@protocol MiniDramaSelectionTabViewDelegate <NSObject>

- (void)onClickDramaSelectionCallback;

@end

@interface MiniDramaSelectionTabView : UIView

@property (nonatomic, weak) id<MiniDramaSelectionTabViewDelegate> delegate;

@property (nonatomic, assign) NSInteger episodeCount;

@end

NS_ASSUME_NONNULL_END
