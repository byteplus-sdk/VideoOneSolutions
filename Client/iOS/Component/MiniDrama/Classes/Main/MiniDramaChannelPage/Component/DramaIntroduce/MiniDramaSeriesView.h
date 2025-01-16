//
//  MiniDramaSeriesView.h
//  JSONModel
//

#import <UIKit/UIKit.h>

@class MDDramaFeedInfo;

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaSeriesViewHeight 26

@protocol MiniDramaSeriesViewDelegate <NSObject>

- (void)onClickSeriesViewCallback;

@end

@interface MiniDramaSeriesView : UIView

@property (nonatomic, weak) id<MiniDramaSeriesViewDelegate> delegate;

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
