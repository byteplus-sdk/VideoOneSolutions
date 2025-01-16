//
//  MiniDramaPageViewController.h
//  VOLCDemo
//
//  Created by real on 2022/7/12.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import UIKit;

typedef enum : NSUInteger {
    MiniDramaPageItemMoveDirectionUnknown,
    MiniDramaPageItemMoveDirectionPrevious,
    MiniDramaPageItemMoveDirectionNext
} MiniDramaPageItemMoveDirection;

@class MDPageViewController;

@protocol MiniDramaPageItem <NSObject>

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

@protocol MiniDramaPageDataSource <NSObject>

@required

- (__kindof UIViewController<MiniDramaPageItem> *)pageViewController:(MDPageViewController *)pageViewController
                                           pageForItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfItemInPageViewController:(MDPageViewController *)pageViewController;

@optional
- (BOOL)shouldScrollVertically:(MDPageViewController *)pageViewController;

- (void)reloadDataWith:(id<MiniDramaPageItem>)viewController index:(NSInteger)index;
@end

@protocol MiniDramaPageDelegate <NSObject>

@optional

- (void)pageViewController:(MDPageViewController *)pageViewController
  didScrollChangeDirection:(MiniDramaPageItemMoveDirection)direction
            offsetProgress:(CGFloat)progress;

- (void)pageViewController:(MDPageViewController *)pageViewController
           willDisplayItem:(id<MiniDramaPageItem>)viewController;

- (void)pageViewController:(MDPageViewController *)pageViewController
            didDisplayItem:(id<MiniDramaPageItem>)viewController;

@end


@interface MDPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, weak) id<MiniDramaPageDelegate>delegate;

@property (nonatomic, weak) id<MiniDramaPageDataSource>dataSource;

@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIViewController<MiniDramaPageItem> *currentViewController;

- (__kindof UIViewController<MiniDramaPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reloadData;
- (void)reloadNextData;
- (void)reloadPreData;
- (void)reloadDataWithPageIndex:(NSInteger)index;

- (void)invalidateLayout;

- (void)reloadContentSize;

- (void)onBack;

@end
