//
//  MiniDramaPlayerSpeedView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN
// protocol
@protocol MiniDramaPlayerSpeedViewDelegate <NSObject>

- (void)onChoosePlaybackSpeed:(CGFloat)speed;

@end
// cell
@interface MiniDramaPlayerSpeedViewCell : UITableViewCell

@property (nonatomic, copy) NSString *speedValue;

@end
// view
@interface MiniDramaPlayerSpeedView : UIView;

- (void)showSpeedViewInView:(UIView *)parentView;

@property (nonatomic, weak) id<MiniDramaPlayerSpeedViewDelegate> delegate;

@end



NS_ASSUME_NONNULL_END
