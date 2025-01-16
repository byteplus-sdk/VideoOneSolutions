//
//  MiniDramaHotVideoCord.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/21.
//

#import <UIKit/UIKit.h>
@class MDDramaFeedInfo;

@protocol MiniDramaHotVideoCardDelegate <NSObject>

- (void)onClickCloseCard;

- (void)onClickCardPlayButton;

@end

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaHotVideoCardViewHeight 117

@interface MiniDramaHotVideoCard : UIView

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@property (nonatomic, weak) id<MiniDramaHotVideoCardDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
