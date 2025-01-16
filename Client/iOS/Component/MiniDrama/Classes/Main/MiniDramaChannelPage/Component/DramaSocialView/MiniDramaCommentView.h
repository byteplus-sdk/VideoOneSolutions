//
//  MiniDramaCommentView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/19.
//

#import <UIKit/UIKit.h>
#import "MiniDramaBaseVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaCommentView : UIView

@property (nonatomic, strong) MiniDramaBaseVideoModel *videoModel;

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis;

- (void)showInView:(UIView *)superview;

- (void)close;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
