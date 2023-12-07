// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import UIKit;

typedef enum : NSUInteger {
    VEPageItemMoveDirectionUnknown,
    VEPageItemMoveDirectionPrevious,
    VEPageItemMoveDirectionNext
} VEPageItemMoveDirection;

@class VEPageViewController;

@protocol VEPageItem <NSObject>

@optional

@property (nonatomic, copy) NSString *reuseIdentifier;

- (void)prepareForReuse;

- (void)itemDidLoad;

- (void)prepareToPlay;

- (void)play;

- (void)pause;

- (void)stop;

- (void)setVisible:(BOOL)visible;

@end

@protocol VEPageDataSource <NSObject>

@required

- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController
                                           pageForItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController;

@optional
- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController;

@end

@protocol VEPageDelegate <NSObject>

@optional

- (void)pageViewController:(VEPageViewController *)pageViewController
    didScrollChangeDirection:(VEPageItemMoveDirection)direction
              offsetProgress:(CGFloat)progress;

- (void)pageViewControllerWillBeginDragging:(VEPageViewController *)pageViewController;

- (void)pageViewController:(VEPageViewController *)pageViewController
           willDisplayItem:(id<VEPageItem>)viewController;

- (void)pageViewController:(VEPageViewController *)pageViewController
            didDisplayItem:(id<VEPageItem>)viewController
                   atIndex:(NSUInteger)index;

@end
/**
 * @brief A fullscreen scroll page ViewController framework, we have provide some basic scroll and control logic. You can use this to add your custom views.
 */

@interface VEPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, weak) id<VEPageDelegate> delegate;

@property (nonatomic, weak) id<VEPageDataSource> dataSource;

@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;

- (UIScrollView *)scrollView;

- (__kindof UIViewController<VEPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reloadData;

- (void)invalidateLayout;

- (void)reloadContentSize;

@end
