// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/ToolKit.h>
#import "MDDramaInfoModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaItemSelectDelegate <NSObject>

@optional
- (void)didMiniDramaSelectItem:(MDDramaInfoModel *)dramaInfoModel;
- (void)miniDramaScrollViewWillMove:(UIScrollView *)scrollView;
- (void)miniDramaScrollViewDidMove:(UIScrollView *)scrollView;
- (void)miniDramaScrollViewDidStop:(UIScrollView *)scrollView;
@end

@interface MiniDramaCollectionViewBaseCell : UICollectionViewCell

@property (nonatomic, weak) id <MiniDramaItemSelectDelegate> selectDelegate;

@property (nonatomic, strong) NSArray<MDDramaInfoModel *> *miniDramaDatas;
@property (nonatomic, strong) MDDramaInfoModel *dramaInfoModel;
@property (nonatomic, assign) NSInteger preloadScrollDirection;
- (NSArray<MDDramaInfoModel *> *)visibleDramaInfosInView:(UIView *)viewport;
- (NSArray<MDDramaInfoModel *> *)adjacentDramaInfosInDirection:(NSInteger)direction;
- (void)notifyScrollWillMove:(UIScrollView *)scrollView;
- (void)notifyScrollDidMove:(UIScrollView *)scrollView;
- (void)notifyScrollDidStop:(UIScrollView *)scrollView;

-(NSString *)formatPlayTimesString:(NSInteger) playTimes;

@end

NS_ASSUME_NONNULL_END
