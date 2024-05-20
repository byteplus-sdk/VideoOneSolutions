// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VELPageDirection) {
    VELPageDirectionUnknown,
    VELPageDirectionPrevious,
    VELPageDirectionNext
};

@class VELPageViewController;

@protocol VELPageItemProtocol <NSObject>
@property (nonatomic, copy) NSString *reuseIdentifier;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@optional

- (void)itemControllerPrepareForReuse;

- (void)itemControllerDidLoaded;

@end

@protocol VELPageControllerDataSource <NSObject>

@required

- (__kindof UIViewController<VELPageItemProtocol> *)pageViewController:(VELPageViewController *)pageViewController
                                           pageForItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfItemInPageViewController:(VELPageViewController *)pageViewController;

@optional
- (BOOL)shouldScrollVertically:(VELPageViewController *)pageViewController;

@end

@protocol VELPageControllerDelegate <NSObject>

@optional

- (void)pageViewController:(VELPageViewController *)pageViewController
  didScrollChangeDirection:(VELPageDirection)direction
            offsetProgress:(CGFloat)progress;

- (void)pageViewController:(VELPageViewController *)pageViewController
           willDisplayItem:(id<VELPageItemProtocol>)viewController;

- (void)pageViewController:(VELPageViewController *)pageViewController
         didEndDisplayItem:(id<VELPageItemProtocol>)viewController;

@end

@interface VELPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, weak) id<VELPageControllerDelegate> delegate;

@property (nonatomic, weak) id<VELPageControllerDataSource> dataSource;

- (UIScrollView *)scrollView;

- (__kindof UIViewController<VELPageItemProtocol> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCurrentIndex:(NSUInteger)currentIndex animation:(BOOL)animation;

- (void)reloadData;

- (void)invalidateLayout;

- (void)reloadContentSize;

@end

NS_ASSUME_NONNULL_END
