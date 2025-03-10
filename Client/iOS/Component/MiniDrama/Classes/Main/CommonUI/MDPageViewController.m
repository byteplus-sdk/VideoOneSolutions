// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPageViewController.h"
#import <objc/message.h>
#import <ToolKit/ToolKit.h>

NSUInteger const MiniDramaPageMaxCount = NSIntegerMax;

@interface UIViewController (MiniDramaPageViewControllerItem)

@property (nonatomic, assign) NSUInteger veIndex;

@property (nonatomic, assign) BOOL veTransitioning;

@end

@implementation UIViewController(MiniDramaPageViewControllerItem)

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

static NSString *MiniDramaPageViewControllerExceptionKey = @"MiniDramaPageViewControllerExceptionKey";

@interface MDPageViewController () <UIScrollViewDelegate> {
    struct {
        unsigned hasDidScrollChangeDirection : 1;
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

@property (nonatomic, assign) MiniDramaPageItemMoveDirection currentDirection;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<UIViewController<MiniDramaPageItem> *> *viewControllers;

@property (nonatomic, assign) BOOL releaseTouch;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<UIViewController<MiniDramaPageItem> *> *> *cacheViewControllers;

@property (nonatomic, strong) UIViewController<MiniDramaPageItem> *currentViewController;

@property (nonatomic, strong) UIViewController<MiniDramaPageItem> *partialVisibleViewController;

@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation MDPageViewController


#pragma mark ----- UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    if ([self.currentViewController respondsToSelector:@selector(pageViewControllerDealloc)]) {
        [self.currentViewController pageViewControllerDealloc];
    }
}

- (void)onBack {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(pageViewControllerDealloc)]) {
            [obj pageViewControllerDealloc];
        }
    }];
}

#pragma mark -- system method override
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentViewController) {
        [self.currentViewController beginAppearanceTransition:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.currentViewController) {
        [self.currentViewController endAppearanceTransition];
    }
    if (self.isViewAppeared) {
        if ([self.currentViewController respondsToSelector:@selector(pageViewControllerVisible:)]) {
            [self.currentViewController pageViewControllerVisible:YES];
            [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj != self.currentViewController) {
                    if ([obj respondsToSelector:@selector(pageViewControllerVisibleForOtherItem:)]) {
                        [obj pageViewControllerVisibleForOtherItem:YES];
                    }
                }
            }];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentViewController beginAppearanceTransition:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.currentViewController endAppearanceTransition];
    
    if (self.isViewAppeared) {
        if ([self.currentViewController respondsToSelector:@selector(pageViewControllerVisible:)]) {
            [self.currentViewController pageViewControllerVisible:NO];
        }
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != self.currentViewController) {
                if ([obj respondsToSelector:@selector(pageViewControllerVisibleForOtherItem:)]) {
                    [obj pageViewControllerVisibleForOtherItem:NO];
                }
            }
        }];
    }
}

- (void)removeFromParentViewController {
    self.viewAppeared = NO;
    [super removeFromParentViewController];
}

#pragma mark -- private method
- (void)commonInit {
    self.viewControllers = [[NSMutableArray alloc] init];
    self.cacheViewControllers = [[NSMutableDictionary alloc] init];
    [self.view addSubview:self.scrollView];
    _currentIndex = MiniDramaPageMaxCount;
    self.needReloadData = YES;
}

- (void)_reloadDataIfNeeded {
    if (self.needReloadData) {
        [self reloadData];
    }
}

- (void)_layoutChildViewControllers {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = CGRectMake(obj.view.frame.origin.x, obj.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)_clearData {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeAllObjects];
    self.currentDirection = MiniDramaPageItemMoveDirectionUnknown;
    self.itemCount = 0;
    _currentIndex = MiniDramaPageMaxCount;
}

- (UIViewController<MiniDramaPageItem> *)_addChildViewControllerFromDataSourceIndex:(NSUInteger)index {
    UIViewController<MiniDramaPageItem> *viewController = [self _childViewControllerAtIndex:index];
    if (viewController && viewController.veTransitioning) {
        [viewController endAppearanceTransition];
    }
    viewController.veTransitioning = NO;
    
    if (viewController) return viewController;
    
    viewController = [self.dataSource pageViewController:self pageForItemAtIndex:index];
    if (!viewController) {
        [NSException raise:MiniDramaPageViewControllerExceptionKey format:@"MiniDramaPageViewController(%p) pageViewController:pageForItemAtIndex: must return a no nil instance", self]; }
    
    [self addChildViewController:viewController];
    if (!self.isVerticalScroll) {
        viewController.view.frame = CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        viewController.view.frame = CGRectMake(0, index * self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        NSLog(@"height2: %lf", self.view.frame.size.height);
    }
    [self.scrollView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    viewController.veIndex = index;
    
    if ([viewController respondsToSelector:@selector(itemDidLoad)]) {
        [viewController itemDidLoad];
    }
    
    return viewController;
}

- (UIViewController<MiniDramaPageItem> *)_childViewControllerAtIndex:(NSUInteger)index {
    __block UIViewController<MiniDramaPageItem> *findViewController = nil;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.veIndex == index) {
            findViewController = obj;
        }
    }];
    return findViewController;
}

- (void)_veRemoveChildViewController:(UIViewController<MiniDramaPageItem> *)removedViewController {
    [removedViewController willMoveToParentViewController:nil];
    [removedViewController.view removeFromSuperview];
    [removedViewController removeFromParentViewController];
    removedViewController.veIndex = MiniDramaPageMaxCount;
    if ([removedViewController respondsToSelector:@selector(reuseIdentifier)] && removedViewController.reuseIdentifier.length) {
        NSMutableArray<UIViewController<MiniDramaPageItem> *>*reuseViewControllers = [self.cacheViewControllers objectForKey:removedViewController.reuseIdentifier];
        if (!reuseViewControllers) {
            reuseViewControllers = [[NSMutableArray<UIViewController<MiniDramaPageItem> *> alloc] init];
            [self.cacheViewControllers setObject:reuseViewControllers forKey:removedViewController.reuseIdentifier];
        }
        if (![reuseViewControllers containsObject:removedViewController]) {
            [reuseViewControllers addObject:removedViewController];
        }
    }
    if ([removedViewController respondsToSelector:@selector(itemDidRemoved)]) {
        [removedViewController itemDidRemoved];
    }
}

#pragma mark - Public Methods
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex autoAdjustOffset:YES];
}
- (void)setCurrentIndex:(NSUInteger)currentIndex autoAdjustOffset:(BOOL)autoAdjustOffset {
    VOLogI(VOMiniDrama, @"currentIndex: %lu",currentIndex);
    if (currentIndex > self.itemCount - 1 || self.itemCount == 0) {
        return;
    }
    if (_currentIndex == currentIndex) return;
    NSMutableArray *removedViewController = [[NSMutableArray alloc] init];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        if (labs((long)vc.veIndex - (long)currentIndex) > 1) {
            [removedViewController addObject:vc];
        }
    }];
    [removedViewController enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeObjectsInArray:removedViewController];
    NSMutableArray *addedViewControllers = [[NSMutableArray alloc] init];
    UIViewController<MiniDramaPageItem> *currentVieController = [self _addChildViewControllerFromDataSourceIndex:currentIndex];
    [addedViewControllers addObject:currentVieController];
    if (currentIndex != 0) {
        UIViewController<MiniDramaPageItem> *nextViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex - 1];
        [addedViewControllers addObject:nextViewController];
    }
    if (self.itemCount > 1 && currentIndex != self.itemCount - 1) {
        UIViewController<MiniDramaPageItem> *preViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex + 1];
        [addedViewControllers addObject:preViewController];
    }
    [addedViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.viewControllers containsObject:obj]) {
            [self.viewControllers addObject:obj];
        }
    }];
    
    UIViewController *lastViewController = self.currentViewController;
    _currentIndex = currentIndex;
    self.currentViewController = [self _childViewControllerAtIndex:_currentIndex];
    
    if (_delegateHas.hasDidEndDisplayItem) {
        [self.delegate pageViewController:self didDisplayItem:self.currentViewController];
    }
    for (UIViewController<MiniDramaPageItem> *vc in self.viewControllers) {
        if (vc != self.currentViewController) {
            if ([vc respondsToSelector:@selector(resetAdjacentCell)]) {
                [vc resetAdjacentCell];
            }
        }
    }
    if (self.isViewAppeared) {
        [self.currentViewController completelyShow];
    }
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
        }
    }
}
- (UIViewController<MiniDramaPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableArray<UIViewController<MiniDramaPageItem> *> *cacheKeyViewControllers = [self.cacheViewControllers objectForKey:reuseIdentifier];
    if (!cacheKeyViewControllers) return nil;
    UIViewController<MiniDramaPageItem> *viewController = [cacheKeyViewControllers firstObject];
    [cacheKeyViewControllers removeObject:viewController];
    if ([viewController respondsToSelector:@selector(prepareForReuse)]) {
        [viewController prepareForReuse];
    }
    return viewController;
}

- (void)reloadData {
    [self reloadDataWithAppearanceTransition:YES];
}

- (void)reloadNextData {
    if (_currentIndex < self.itemCount - 1) {
        [self.scrollView setContentOffset:CGPointMake(0, (self.currentIndex + 1) * self.scrollView.frame.size.height) animated:YES];
    }
}

- (void)reloadPreData {
    if (_currentIndex > 0) {
        [self.scrollView setContentOffset:CGPointMake(0, (self.currentIndex - 1) * self.scrollView.frame.size.height) animated:YES];
    }
}

- (void)reloadDataWithPageIndex:(NSInteger)index {
    __block UIViewController<MiniDramaPageItem> *cell = nil;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index == obj.veIndex) {
            cell = obj;
            *stop = YES;
        }
    }];
    if (cell && self.dataSource && [self.dataSource respondsToSelector:@selector(reloadDataWith:index:)]) {
        [self.dataSource reloadDataWith:cell index:index];
    }
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
        if (preIndex >= _itemCount || preIndex == MiniDramaPageMaxCount) {
            [self setCurrentIndex:0 autoAdjustOffset:appearanceTransition];
        } else {
            VOLogI(VOMiniDrama, @"reload preIndex: %ld", preIndex);
            [self setCurrentIndex:preIndex autoAdjustOffset:appearanceTransition];
        }
    }
    self.needReloadData = NO;
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
        if (preItemCount == 1 && preItemCount < self.itemCount) {
            VOLogI(VOMiniDrama, @"preAdd next item");
            UIViewController<MiniDramaPageItem> *viewController = [self _addChildViewControllerFromDataSourceIndex:1];
            [self.viewControllers addObject:viewController];
        }
    }
}
- (void)_shouldChangeToNextPage {
    UIViewController<MiniDramaPageItem> *lastViewController = self.currentViewController;
    CGFloat page = _currentIndex;
    if (self.currentDirection == MiniDramaPageItemMoveDirectionNext) {
        page = self.currentIndex + 1;
    } else {
        page = self.currentIndex - 1;
    }
    if (self.currentDirection == MiniDramaPageItemMoveDirectionUnknown) {
        return;
    } else if (self.currentIndex == 0 && self.currentDirection == MiniDramaPageItemMoveDirectionPrevious) {
        return;
    } else if (self.currentIndex == (self.itemCount - 1) && self.currentDirection == MiniDramaPageItemMoveDirectionNext) {
        return;
    } else {
        [self setCurrentIndex:(NSInteger)page autoAdjustOffset:NO];
    }
    [self.currentViewController endAppearanceTransition];
    [lastViewController performSelector:@selector(viewDidDisappear:) withObject:@(YES)];
    lastViewController.veTransitioning = NO;
    if ([lastViewController respondsToSelector:@selector(endShow)]) {
        [lastViewController endShow];
    }
    self.currentViewController.veTransitioning = NO;
    self.currentDirection = MiniDramaPageItemMoveDirectionUnknown;
    self.shouldChangeToNextPage = NO;
    self.scrollView.panGestureRecognizer.enabled = YES;
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
    if (offsetABS > 0 && self.currentDirection != MiniDramaPageItemMoveDirectionNext) {
        if (self.currentIndex == self.itemCount - 1) {
            return;
        }
        self.currentDirection = MiniDramaPageItemMoveDirectionNext;
        if (!self.currentViewController.veTransitioning) {
            self.currentViewController.veTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        
        UIViewController<MiniDramaPageItem> *nextViewController = [self _childViewControllerAtIndex:self.currentIndex + 1];
        if (nextViewController  && !nextViewController.veTransitioning) {
            nextViewController.veTransitioning = YES;
            [nextViewController beginAppearanceTransition:YES animated:YES];
            if ([nextViewController respondsToSelector:@selector(partiallyShow)]) {
                [nextViewController partiallyShow];
            }
            self.partialVisibleViewController = nextViewController;
            changeToViewController = nextViewController;
        }
        if (_delegateHas.hasWillDisplayItem) {
            [self.delegate pageViewController:self willDisplayItem:nextViewController];
        }
    } else if (offsetABS < 0 && self.currentDirection != MiniDramaPageItemMoveDirectionPrevious) {
        if (self.currentIndex == 0) return;
        self.currentDirection = MiniDramaPageItemMoveDirectionPrevious;
        if (!self.currentViewController.veTransitioning) {
            self.currentViewController.veTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        UIViewController<MiniDramaPageItem> *preViewController = [self _childViewControllerAtIndex:self.currentIndex - 1];
        if (preViewController && !preViewController.veTransitioning) {
            preViewController.veTransitioning = YES;
            [preViewController beginAppearanceTransition:YES animated:YES];
            if ([preViewController  respondsToSelector:@selector(partiallyShow)]) {
                [preViewController partiallyShow];
            }
            self.partialVisibleViewController = preViewController;
            changeToViewController = preViewController;
        }
        if (_delegateHas.hasWillDisplayItem) {
            [self.delegate pageViewController:self willDisplayItem:preViewController];
        }
    }
    if (_delegateHas.hasDidScrollChangeDirection) {
        [self.delegate pageViewController:self didScrollChangeDirection:self.currentDirection offsetProgress:(progress > 1) ? 1 : progress];
    }
    if (progress < 0.0) {
        VOLogI(VOMiniDrama, @"MiniDramaPageViewController progress < 0.0");
        if (self.currentViewController.veTransitioning) {
            self.currentViewController.veTransitioning = NO;
        }
        if (changeToViewController.veTransitioning) {
            changeToViewController.veTransitioning = NO;
        }
        self.currentDirection = MiniDramaPageItemMoveDirectionUnknown;
    }
    if ([self areFloatsAlmostEqual:progress b:1.0 epsilon:0.001] || progress >= 1.0) {
        VOLogI(VOMiniDrama, @"callback scrollViewDidScroll, shouldChangeToNextPage");
        self.shouldChangeToNextPage = YES;
        if (progress > 1 && self.shouldChangeToNextPage) {
            [self _shouldChangeToNextPage];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.currentDirection == MiniDramaPageItemMoveDirectionUnknown) {
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<MiniDramaPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.veTransitioning) {
                obj.veTransitioning = NO;
            }
        }];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint targetOffset = *targetContentOffset;
    CGFloat offset;
    CGFloat itemLength;
    if (!self.isVerticalScroll) {
        offset = targetOffset.x;
        itemLength = self.view.frame.size.width;
    } else {
        offset = targetOffset.y;
        itemLength = self.view.frame.size.height;
    }
    NSUInteger idx = offset / itemLength;
    UIViewController<MiniDramaPageItem> *targetVC = [self _childViewControllerAtIndex:idx];
    if (targetVC != self.currentViewController) {
        if (targetVC.veTransitioning) { // fix unpair case
            [targetVC performSelector:@selector(viewDidAppear:) withObject:@(YES)];
            scrollView.panGestureRecognizer.enabled = NO;
        }
        [targetVC endAppearanceTransition];   
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
        self.currentDirection = MiniDramaPageItemMoveDirectionUnknown;
    }
    if (self.partialVisibleViewController) {
        if (self.partialVisibleViewController && self.partialVisibleViewController != self.currentViewController) {
            if ([self.partialVisibleViewController respondsToSelector:@selector(endShow)]) {
                [self.partialVisibleViewController endShow];
            }
        }
        self.partialVisibleViewController = nil;
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
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _scrollView;
}

- (void)setDelegate:(id<MiniDramaPageDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateHas.hasWillDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:willDisplayItem:)];
        _delegateHas.hasDidEndDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:didDisplayItem:)];
        _delegateHas.hasDidScrollChangeDirection = [_delegate respondsToSelector:@selector(pageViewController:didScrollChangeDirection:offsetProgress:)];
    }
}

- (void)setDataSource:(id<MiniDramaPageDataSource>)dataSource {
    _dataSource = dataSource;
    if (_dataSource) {
        _dataSourceHas.hasPageForItemAtIndex = [_dataSource respondsToSelector:@selector(pageViewController:pageForItemAtIndex:)];
        _dataSourceHas.hasNumberOfItemInPageViewController = [_dataSource respondsToSelector:@selector(numberOfItemInPageViewController:)];
        _dataSourceHas.hasIsVerticalPageScrollInPageViewController = [_dataSource respondsToSelector:@selector(shouldScrollVertically:)];
    }
    _needReloadData = YES;
}

#pragma mark - Tool

- (BOOL)areFloatsAlmostEqual:(float)a b:(float)b epsilon:(CGFloat)epsilon {
    return fabs(a - b) <= epsilon;
}

@end
