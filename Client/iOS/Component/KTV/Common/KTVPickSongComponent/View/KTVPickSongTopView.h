//
//  KTVPickSongTopView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVPickSongTopView : UIView

@property (nonatomic, copy) void(^selectedChangedBlock)(NSInteger index);

- (void)updatePickedSongCount:(NSInteger)count;

- (void)changedSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
