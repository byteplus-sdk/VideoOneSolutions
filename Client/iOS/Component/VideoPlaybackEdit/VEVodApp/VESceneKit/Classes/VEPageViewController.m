// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEPageViewController.h"
#import <objc/message.h>
#import <ToolKit/ToolKit.h>

NSUInteger const VEPageMaxCount = NSIntegerMax;

@interface UIViewController (VEPageViewControllerItem)

@property (nonatomic, assign) NSUInteger veIndex;

@property (nonatomic, assign) BOOL veTransitioning;

@end

@implementation UIViewController (VEPageViewControllerItem)

- (void)setVeIndex:(NSUInteger)veIndex {
    objc_setAssociatedObject(self, @selector(veIndex), @(veIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)veIndex {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setVeTransitioning:(BOOL)veTransitioning {
    objc_setAssociatedObject(self, @selector(veTransitioning), @(veTransitioning), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)veTransitioning {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

static NSString *VEPageViewControllerExceptionKey = @"VEPageViewControllerExceptionKey";

@interface VEPageViewController () <UIScrollViewDelegate> {
    struct {
        unsigned hasDidScrollChangeDirection : 1;
        unsigned hasWillBeginDragging : 1;
        unsigned hasWillDisplayItem : 1;
        unsigned hasDidEndDisplayItem : 1;
    } _delegateHas;

    struct {
        unsigned hasPageForItemAtIndex : 1;
        unsigned hasNumberOfItemInPageViewController : 1;
        unsigned hasIsVerticalPageScrollInPageViewController : 1;
    } _dataSourceHas;
}

@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) BOOL isVerticalScroll;

@property (nonatomic, assign) BOOL needReloadData;

@property (nonatomic, assign) BOOL shouldChangeToNextPage;

@property (nonatomic, assign) VEPageItemMoveDirection currentDirection;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<UIViewController<VEPageItem> *> *viewControllers;

@property (nonatomic, assign) BOOL releaseTouch;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<UIViewController<VEPageItem> *> *> *cacheViewControllers;

@property (nonatomic, strong) UIViewController<VEPageItem> *currentViewController;

@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation VEPageViewController

#pragma mark----- UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    if ([self.currentViewController respondsToSelector:@selector(stop)]) {
        [self.currentViewController stop];
    }
}

- (void)commonInit {
    self.viewControllers = [[NSMutableArray alloc] init];
    self.cacheViewControllers = [[NSMutableDictionary alloc] init];
    [self.view addSubview:self.scrollView];
    self.currentIndex = VEPageMaxCount;
    self.needReloadData = YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        return;
    }
    self.scrollView.frame = self.view.bounds;
    [self _reloadDataIfNeeded];
    [self _layoutChildViewControllers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.currentViewController respondsToSelector:@selector(setVisible:)]) {
        [self.currentViewController setVisible:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isViewAppeared) {
        if ([self.currentViewController respondsToSelector:@selector(setVisible:)]) {
            [self.currentViewController setVisible:YES];
        }
    }
}

- (void)removeFromParentViewController {
    self.viewAppeared = NO;
    [super removeFromParentViewController];
}

- (void)_layoutChildViewControllers {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VEPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.view.frame = CGRectMake(obj.view.frame.origin.x, obj.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)_reloadDataIfNeeded {
    if (self.needReloadData) {
        [self reloadData];
    }
}

- (void)_clearData {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VEPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeAllObjects];
    self.currentDirection = VEPageItemMoveDirectionUnknown;
    self.itemCount = 0;
    self.currentIndex = VEPageMaxCount;
}

- (UIViewController<VEPageItem> *)_addChildViewControllerFromDataSourceIndex:(NSUInteger)index {
    UIViewController<VEPageItem> *viewController = [self _childViewControllerAtIndex:index];
    if (viewController.veTransitioning) {
        [viewController endAppearanceTransition];
    }
    viewController.veTransitioning = NO;

    if (viewController) return viewController;

    viewController = [self.dataSource pageViewController:self pageForItemAtIndex:index];
    if (!viewController) {
        [NSException raise:VEPageViewControllerExceptionKey format:@"VEPageViewController(%p) pageViewController:pageForItemAtIndex: must return a no nil instance", self];
    }

    [self addChildViewController:viewController];
    if (!self.isVerticalScroll) {
        viewController.view.frame = CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        viewController.view.frame = CGRectMake(0, index * self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
    [self.scrollView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    viewController.veIndex = index;

    if ([viewController respondsToSelector:@selector(itemDidLoad)]) {
        [viewController itemDidLoad];
    }

    return viewController;
}

- (void)_veRemoveChildViewController:(UIViewController<VEPageItem> *)removedViewController {
    [removedViewController willMoveToParentViewController:nil];
    [removedViewController.view removeFromSuperview];
    [removedViewController removeFromParentViewController];
    removedViewController.veIndex = VEPageMaxCount;
    if ([removedViewController respondsToSelector:@selector(reuseIdentifier)] && removedViewController.reuseIdentifier.length) {
        NSMutableArray<UIViewController<VEPageItem> *> *reuseViewControllers = [self.cacheViewControllers objectForKey:removedViewController.reuseIdentifier];
        if (!reuseViewControllers) {
            reuseViewControllers = [[NSMutableArray<UIViewController<VEPageItem> *> alloc] init];
            [self.cacheViewControllers setObject:reuseViewControllers forKey:removedViewController.reuseIdentifier];
        }
        if (![reuseViewControllers containsObject:removedViewController]) {
            [reuseViewControllers addObject:removedViewController];
        }
    }
}

- (UIViewController<VEPageItem> *)_childViewControllerAtIndex:(NSUInteger)index {
    __block UIViewController<VEPageItem> *findViewController = nil;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VEPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.veIndex == index) {
            findViewController = obj;
        }
    }];
    return findViewController;
}

#pragma mark - Public Methods
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex autoAdjustOffset:YES];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex autoAdjustOffset:(BOOL)autoAdjustOffset {
    if (currentIndex > self.itemCount - 1) {
        VOLogI(VOVideoPlayback,@"VEPageViewController(%p) currentIndex out of bounds %lu", self, (unsigned long)currentIndex);
        return;
    }
    if (_currentIndex == currentIndex) return;
    if (_itemCount == 0) {
        _currentIndex = currentIndex;
        return;
    }
    NSMutableArray *addedViewControllers = [[NSMutableArray alloc] init];
    UIViewController<VEPageItem> *currentVieController = [self _addChildViewControllerFromDataSourceIndex:currentIndex];
    [addedViewControllers addObject:currentVieController];
    if (currentIndex != 0) {
        UIViewController<VEPageItem> *nextViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex - 1];
        [addedViewControllers addObject:nextViewController];
    }
    if (self.itemCount > 1 && currentIndex != self.itemCount - 1) {
        UIViewController<VEPageItem> *preViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex + 1];
        [addedViewControllers addObject:preViewController];
    }

    NSMutableArray *removedViewController = [[NSMutableArray alloc] init];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VEPageItem> *_Nonnull vc, NSUInteger idx, BOOL *_Nonnull stop) {
        __block BOOL findVC = NO;
        [addedViewControllers enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (vc == obj) {
                findVC = YES;
            }
        }];
        if (!findVC) {
            [removedViewController addObject:vc];
        }
    }];
    [removedViewController enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [addedViewControllers enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![self.viewControllers containsObject:obj]) {
            [self.viewControllers addObject:obj];
        }
    }];
    [self.viewControllers removeObjectsInArray:removedViewController];
    UIViewController *lastViewController = self.currentViewController;
    _currentIndex = currentIndex;
    self.currentViewController = [self _childViewControllerAtIndex:_currentIndex];
    if (autoAdjustOffset) {
        if (!self.isVerticalScroll) {
            self.scrollView.contentOffset = CGPointMake(currentIndex * self.view.frame.size.width, 0);
        } else {
            self.scrollView.contentOffset = CGPointMake(0, currentIndex * self.view.frame.size.height);
        }
        if (self.view.window) {
            [lastViewController beginAppearanceTransition:NO animated:YES];
            [lastViewController endAppearanceTransition];
            [self.currentViewController beginAppearanceTransition:YES animated:YES];
            [self.currentViewController endAppearanceTransition];
            if (self.isViewAppeared) {
                [self.currentViewController play];
            }
        }
    }
}

#pragma mark - Variable Setter & Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _scrollView;
}

- (void)setDelegate:(id<VEPageDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateHas.hasWillDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:willDisplayItem:)];
        _delegateHas.hasDidEndDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:didDisplayItem:atIndex:)];
        _delegateHas.hasDidScrollChangeDirection = [_delegate respondsToSelector:@selector(pageViewController:didScrollChangeDirection:offsetProgress:)];
        _delegateHas.hasWillBeginDragging = [_delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)];
    }
}

- (void)setDataSource:(id<VEPageDataSource>)dataSource {
    _dataSource = dataSource;
    if (_dataSource) {
        _dataSourceHas.hasPageForItemAtIndex = [_dataSource respondsToSelector:@selector(pageViewController:pageForItemAtIndex:)];
        _dataSourceHas.hasNumberOfItemInPageViewController = [_dataSource respondsToSelector:@selector(numberOfItemInPageViewController:)];
        _dataSourceHas.hasIsVerticalPageScrollInPageViewController = [_dataSource respondsToSelector:@selector(shouldScrollVertically:)];
    }
    _needReloadData = YES;
}

- (UIViewController<VEPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableArray<UIViewController<VEPageItem> *> *cacheKeyViewControllers = [self.cacheViewControllers objectForKey:reuseIdentifier];
    if (!cacheKeyViewControllers) return nil;
    UIViewController<VEPageItem> *viewController = [cacheKeyViewControllers firstObject];
    [cacheKeyViewControllers removeObject:viewController];
    if ([viewController respondsToSelector:@selector(prepareForReuse)]) {
        [viewController prepareForReuse];
    }
    viewController.veTransitioning = NO;
    return viewController;
}

- (void)reloadData {
    [self reloadDataWithAppearanceTransition:YES];
}

- (void)invalidateLayout {
    [self reloadDataWithAppearanceTransition:NO];
}

- (void)reloadDataWithAppearanceTransition:(BOOL)appearanceTransition {
    self.needReloadData = YES;
    NSInteger preIndex = self.currentIndex;
    [self _clearData];
    if (_dataSourceHas.hasIsVerticalPageScrollInPageViewController) {
        self.isVerticalScroll = [self.dataSource shouldScrollVertically:self];
    }
    if (_dataSourceHas.hasNumberOfItemInPageViewController) {
        self.itemCount = [self.dataSource numberOfItemInPageViewController:self];
        if (!self.isVerticalScroll) {
            [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * self.itemCount, 0)];
        } else {
            [self.scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height * self.itemCount)];
        }
    }
    if (_dataSourceHas.hasPageForItemAtIndex) {
        if (preIndex >= _itemCount || preIndex == VEPageMaxCount) {
            [self setCurrentIndex:0 autoAdjustOffset:appearanceTransition];
        } else {
            [self setCurrentIndex:preIndex autoAdjustOffset:appearanceTransition];
        }
    }
    self.needReloadData = NO;
    if (_delegateHas.hasDidEndDisplayItem) {
        [self.delegate pageViewController:self didDisplayItem:self.currentViewController atIndex:self.currentIndex];
    }
}

- (void)reloadContentSize {
    if (_dataSourceHas.hasNumberOfItemInPageViewController) {
        NSInteger preItemCount = self.itemCount;
        self.itemCount = [_dataSource numberOfItemInPageViewController:self];
        if (!self.isVerticalScroll) {
            BOOL resetContentOffset = NO;
            if (preItemCount < self.itemCount) {
                resetContentOffset = YES;
            }
            [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * self.itemCount, 0)];
            if (resetContentOffset && self.scrollView.contentOffset.x > self.scrollView.contentSize.width - self.scrollView.frame.size.width) {
                self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width * (self.itemCount - 1), 0);
            }
        } else {
            BOOL resetContentOffset = NO;
            if (preItemCount < self.itemCount) {
                resetContentOffset = YES;
            }
            [self.scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height * self.itemCount)];
            if (resetContentOffset && self.scrollView.contentOffset.y > self.scrollView.contentSize.height - self.scrollView.frame.size.height) {
                self.scrollView.contentOffset = CGPointMake(0, self.view.frame.size.height * (self.itemCount - 1));
            }
        }
    }
}

- (void)_shouldChangeToNextPage {
    UIViewController<VEPageItem> *lastViewController = self.currentViewController;
    CGFloat page = _currentIndex;
    if (self.currentDirection == VEPageItemMoveDirectionNext) {
        page = self.currentIndex + 1;
    } else {
        page = self.currentIndex - 1;
    }
    if (self.isVerticalScroll) {
        page = self.scrollView.contentOffset.y / self.scrollView.frame.size.height + 0.5;
    } else {
        page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5;
    }
    if (self.currentDirection == VEPageItemMoveDirectionUnknown) {
        return;
    } else if (self.currentIndex == 0 && self.currentDirection == VEPageItemMoveDirectionPrevious) {
        return;
    } else if (self.currentIndex == (self.itemCount - 1) && self.currentDirection == VEPageItemMoveDirectionNext) {
        return;
    } else {
        [self setCurrentIndex:(NSInteger)page autoAdjustOffset:NO];
    }
    if (self.isViewAppeared) {
        [self.currentViewController play];
    }
    lastViewController.veTransitioning = NO;
    self.currentViewController.veTransitioning = NO;
    self.currentDirection = VEPageItemMoveDirectionUnknown;
    self.shouldChangeToNextPage = NO;
    if (_delegateHas.hasDidEndDisplayItem) {
        [self.delegate pageViewController:self didDisplayItem:self.currentViewController atIndex:self.currentIndex];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.needReloadData) return;
    if (self.isVerticalScroll && scrollView.contentOffset.x != 0) return;
    if (!self.isVerticalScroll && scrollView.contentOffset.y != 0) return;
    CGFloat offset = self.isVerticalScroll ? scrollView.contentOffset.y : scrollView.contentOffset.x;
    CGFloat itemWidth = self.isVerticalScroll ? self.view.frame.size.height : self.view.frame.size.width;
    CGFloat offsetABS = offset - itemWidth * self.currentIndex;
    UIViewController *changeToViewController = nil;
    CGFloat progress = fabs(offsetABS) / itemWidth;
    if (offsetABS > 0 && self.currentDirection != VEPageItemMoveDirectionNext) {
        if (self.currentIndex == self.itemCount - 1) {
            return;
        }
        self.currentDirection = VEPageItemMoveDirectionNext;
        if (!self.currentViewController.veTransitioning) {
            self.currentViewController.veTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        UIViewController<VEPageItem> *nextViewController = [self _childViewControllerAtIndex:self.currentIndex + 1];
        if (!nextViewController.veTransitioning) {
            nextViewController.veTransitioning = YES;
            [nextViewController beginAppearanceTransition:YES animated:YES];
            changeToViewController = nextViewController;
        }
        if (_delegateHas.hasWillDisplayItem) {
            [self.delegate pageViewController:self willDisplayItem:nextViewController];
        }
    } else if (offsetABS < 0 && self.currentDirection != VEPageItemMoveDirectionPrevious) {
        if (self.currentIndex == 0) return;
        self.currentDirection = VEPageItemMoveDirectionPrevious;
        if (!self.currentViewController.veTransitioning) {
            self.currentViewController.veTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        UIViewController<VEPageItem> *preViewController = [self _childViewControllerAtIndex:self.currentIndex - 1];
        if (!preViewController.veTransitioning) {
            preViewController.veTransitioning = YES;
            [preViewController beginAppearanceTransition:YES animated:YES];
            changeToViewController = preViewController;
        }
        if (_delegateHas.hasWillDisplayItem) {
            [self.delegate pageViewController:self willDisplayItem:preViewController];
        }
    }
    if (_delegateHas.hasDidScrollChangeDirection) {
        [self.delegate pageViewController:self didScrollChangeDirection:self.currentDirection offsetProgress:MIN(1.0, progress)];
    }
    if ([self areFloatsAlmostEqual:progress b:1.0 epsilon:0.001] ||
        progress >= 1.0) {
        self.shouldChangeToNextPage = YES;
        [self _shouldChangeToNextPage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegateHas.hasWillBeginDragging) {
        [self.delegate pageViewControllerWillBeginDragging:self];
    }
    if (self.currentDirection == VEPageItemMoveDirectionUnknown) {
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VEPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.veTransitioning) {
                obj.veTransitioning = NO;
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidStopScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidStopScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidStopScroll];
}

- (void)scrollViewDidStopScroll {
    if (self.shouldChangeToNextPage) {
        [self _shouldChangeToNextPage];
    } else {
        self.currentDirection = VEPageItemMoveDirectionUnknown;
    }
    for (UIViewController<VEPageItem> *vc in self.viewControllers) {
        if (vc != self.currentViewController) {
            [vc pause];
        }
    }
}

#pragma mark - Tool

- (BOOL)areFloatsAlmostEqual:(float)a b:(float)b epsilon:(CGFloat)epsilon {
    return fabs(a - b) <= epsilon;
}


@end
