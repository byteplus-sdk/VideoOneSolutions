// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TTPageItemMoveDirectionUnknown,
    TTPageItemMoveDirectionPrevious,
    TTPageItemMoveDirectionNext
} TTPageItemMoveDirection;

@class TTPageViewController;

// protocol:TTPageItem
@protocol TTPageItem <NSObject>

@optional

@property (nonatomic, copy) NSString *reuseIdentifier;
- (void)prepareForReuse;
- (void)itemDidLoad;
- (void)itemDidRemoved;
- (void)partiallyShow;
- (void)completelyShow;
- (void)endShow;
- (void)resetAdjacentCell;
- (void)pageViewControllerDealloc;
- (void)pageViewControllerVisible:(BOOL)visible;
- (void)pageViewControllerVisibleForOtherItem:(BOOL)visible;
@end

// protocol:TTPageDataSource
@protocol TTPageDataSource <NSObject>

@required
- (__kindof UIViewController<TTPageItem> *)pageViewController:(TTPageViewController *)pageViewController
                                           pageForItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfItemInPageViewController:(TTPageViewController *)pageViewController;


@optional
- (BOOL)shouldScrollVertically:(TTPageViewController *)pageViewController;
@end

// protocol:TTPageDelegate
@protocol TTPageDelegate <NSObject>

@optional
- (void)pageViewController:(TTPageViewController *)pageViewController
    didScrollChangeDirection:(TTPageItemMoveDirection)direction
              offsetProgress:(CGFloat)progress;

- (void)pageViewControllerWillBeginDragging:(TTPageViewController *)pageViewController;

- (void)pageViewController:(TTPageViewController *)pageViewController
           willDisplayItem:(id<TTPageItem>)viewController;

- (void)pageViewController:(TTPageViewController *)pageViewController
            didDisplayItem:(id<TTPageItem>)viewController
                   atIndex:(NSUInteger)index;
@end

// class:TTPageViewController
/**
 * @brief A fullscreen scroll page ViewController framework, we have provide some basic scroll and control logic. You can use this to add your custom views.
 */

@interface TTPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, weak) id<TTPageDelegate> delegate;

@property (nonatomic, weak) id<TTPageDataSource> dataSource;

@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;

- (UIScrollView *)scrollView;

- (__kindof UIViewController<TTPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reloadData;

- (void)invalidateLayout;

- (void)reloadContentSize;

@end

NS_ASSUME_NONNULL_END
