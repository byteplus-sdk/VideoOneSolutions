//
//  MiniDramaIntroduceView.h
//  JSONModel
//

#import <UIKit/UIKit.h>

@class MDDramaFeedInfo;

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaIntroduceViewHeight 70

@interface MiniDramaIntroduceView : UIView

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
