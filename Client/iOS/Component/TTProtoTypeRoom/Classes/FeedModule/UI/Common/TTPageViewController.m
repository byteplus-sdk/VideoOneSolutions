//
//  TTPageViewController.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "TTPageViewController.h"
#import <objc/message.h>
#import <ToolKit/ToolKit.h>


NSUInteger const TTPageMaxCount = NSIntegerMax;

static NSString *TTPageViewControllerExceptionKey = @"TTPageViewControllerExceptionKey";


#pragma mark TTPageViewControllerItem
@interface UIViewController (TTPageViewControllerItem)

@property (nonatomic, assign) NSUInteger ttIndex;

@property (nonatomic, assign) BOOL ttTransitioning;

@end

@implementation UIViewController (TTPageViewControllerItem)

- (NSUInteger)ttIndex {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setTtIndex:(NSUInteger)ttIndex {
    objc_setAssociatedObject(self, @selector(ttIndex), @(ttIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttTransitioning {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTtTransitioning:(BOOL)ttTransitioning {
    objc_setAssociatedObject(self, @selector(ttTransitioning), @(ttTransitioning), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


#pragma mark TTPageViewController

@interface TTPageViewController () <UIScrollViewDelegate> {
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

@property (nonatomic, assign) TTPageItemMoveDirection currentDirection;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<UIViewController<TTPageItem> *> *viewControllers;

@property (nonatomic, assign) BOOL releaseTouch;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<UIViewController<TTPageItem> *> *> *cacheViewControllers;

@property (nonatomic, strong) UIViewController<TTPageItem> *currentViewController;

@property (nonatomic, strong) UIViewController<TTPageItem> *partialVisibleViewController;

@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation TTPageViewController
#pragma mark -- init/deinit
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
    if ([self.currentViewController respondsToSelector:@selector(pageViewControllerDealloc)]) {
        [self.currentViewController pageViewControllerDealloc];
    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isViewAppeared) {
        if ([self.currentViewController respondsToSelector:@selector(pageViewControllerVisible:)]) {
            [self.currentViewController pageViewControllerVisible:YES];
        }
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != self.currentViewController) {
                if ([obj respondsToSelector:@selector(pageViewControllerVisibleForOtherItem:)]) {
                    [obj pageViewControllerVisibleForOtherItem:YES];
                }
            }
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.currentViewController respondsToSelector:@selector(pageViewControllerVisible:)]) {
        [self.currentViewController pageViewControllerVisible:NO];
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    self.currentIndex = TTPageMaxCount;
    self.needReloadData = YES;
}

- (void) _reloadDataIfNeeded {
    if (self.needReloadData) {
        [self reloadData];
    }
}

- (void) _layoutChildViewControllers {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.view.frame = CGRectMake(obj.view.frame.origin.x, obj.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)_clearData {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeAllObjects];
//    [self.cacheViewControllers removeAllObjects];
    self.currentDirection = TTPageItemMoveDirectionUnknown;
    self.itemCount = 0;
    self.currentIndex = TTPageMaxCount;
}
- (UIViewController<TTPageItem> *)_addChildViewControllerFromDataSourceIndex:(NSUInteger)index {
    UIViewController<TTPageItem> *viewController = [self _childViewControllerAtIndex:index];
    if (viewController.ttTransitioning) {
        [viewController endAppearanceTransition];
    }
    viewController.ttTransitioning = NO;
    if (viewController) return viewController;
    viewController = [self.dataSource pageViewController:self pageForItemAtIndex:index];
    if (!viewController) {
        [NSException raise:TTPageViewControllerExceptionKey format:@"VEPageViewController(%p) pageViewController:pageForItemAtIndex: must return a no nil instance", self];
    }
    
    [self addChildViewController:viewController];
    if (!self.isVerticalScroll) {
        viewController.view.frame = CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        viewController.view.frame = CGRectMake(0, index * self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
    [self.scrollView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    viewController.ttIndex = index;

    if ([viewController respondsToSelector:@selector(itemDidLoad)]) {
        [viewController itemDidLoad];
    }

    return viewController;
}
- (UIViewController<TTPageItem> *)_childViewControllerAtIndex:(NSUInteger)index {
    __block UIViewController<TTPageItem> *findViewController = nil;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (obj.ttIndex == index) {
            findViewController = obj;
        }
    }];
    return findViewController;
}
- (void)_veRemoveChildViewController:(UIViewController<TTPageItem> *)removedViewController {
    [removedViewController willMoveToParentViewController:nil];
    [removedViewController.view removeFromSuperview];
    [removedViewController removeFromParentViewController];
    removedViewController.ttIndex = TTPageMaxCount;
    if ([removedViewController respondsToSelector:@selector(reuseIdentifier)] && removedViewController.reuseIdentifier.length) {
        NSMutableArray<UIViewController<TTPageItem> *> *reuseViewControllers = [self.cacheViewControllers objectForKey:removedViewController.reuseIdentifier];
        if (!reuseViewControllers) {
            reuseViewControllers = [[NSMutableArray<UIViewController<TTPageItem> *> alloc] init];
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

#pragma mark -- public method
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex autoAdjustOffset:YES];
}
- (void)setCurrentIndex:(NSUInteger)currentIndex autoAdjustOffset:(BOOL)autoAdjustOffset {
    if (currentIndex > self.itemCount - 1) {
        VOLogI(VOTTProto,@"index > itemCount, %lu", (unsigned long)currentIndex);
        return;
    }
    if (_currentIndex == currentIndex) return;
    if (_itemCount == 0) {
        _currentIndex = currentIndex;
        return;
    }
    NSMutableArray *removedViewController = [[NSMutableArray alloc] init];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> *_Nonnull vc, NSUInteger idx, BOOL *_Nonnull stop) {
        if (labs((long)vc.ttIndex - (long)currentIndex) > 1) {
            [removedViewController addObject:vc];
        }
    }];
    [removedViewController enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeObjectsInArray:removedViewController];
    NSMutableArray *addedViewControllers = [[NSMutableArray alloc] init];
    UIViewController<TTPageItem> *currentVieController = [self _addChildViewControllerFromDataSourceIndex:currentIndex];
    [addedViewControllers addObject:currentVieController];
    if (currentIndex != 0) {
        UIViewController<TTPageItem> *preViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex - 1];
        [addedViewControllers addObject:preViewController];
    }
    if (self.itemCount > 1 && currentIndex != self.itemCount - 1) {
        UIViewController<TTPageItem> *nextViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex + 1];
        [addedViewControllers addObject:nextViewController];
    }
    [addedViewControllers enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (![self.viewControllers containsObject:obj]) {
            [self.viewControllers addObject:obj];
        }
    }];
    
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
                [self.currentViewController completelyShow];
            }
        }
    }
}
- (UIViewController<TTPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableArray<UIViewController<TTPageItem> *> *cacheKeyViewControllers = [self.cacheViewControllers objectForKey:reuseIdentifier];
    if (!cacheKeyViewControllers) return nil;
    UIViewController<TTPageItem> *viewController = [cacheKeyViewControllers firstObject];
    [cacheKeyViewControllers removeObject:viewController];
    if ([viewController respondsToSelector:@selector(prepareForReuse)]) {
        [viewController prepareForReuse];
    }
    viewController.ttTransitioning = NO;
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
        if (preIndex >= _itemCount || preIndex == TTPageMaxCount) {
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
        if (preItemCount == 1 && preItemCount < self.itemCount) {
            VOLogI(VOTTProto, @"preAdd next item");
            UIViewController<TTPageItem> *viewController = [self _addChildViewControllerFromDataSourceIndex:1];
            [self.viewControllers addObject:viewController];
        }
    }
}
- (void)_shouldChangeToNextPage {
    UIViewController<TTPageItem> *lastViewController = self.currentViewController;
    CGFloat page = _currentIndex;
    if (self.currentDirection == TTPageItemMoveDirectionNext) {
        page = self.currentIndex + 1;
    } else if (self.currentDirection == TTPageItemMoveDirectionPrevious) {
        page = self.currentIndex - 1;
    } else {
        VOLogE(VOTTProto, @"shouldChangeToNextPage error");
        return;
    }
//    if (self.isVerticalScroll) {
//        page = self.scrollView.contentOffset.y / self.scrollView.frame.size.height + 0.5;
//    } else {
//        page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5;
//    }
    if (self.currentIndex == 0 && self.currentDirection == TTPageItemMoveDirectionPrevious) {
        return;
    } else if (self.currentIndex == (self.itemCount - 1) && self.currentDirection == TTPageItemMoveDirectionNext) {
        return;
    } else {
        [self setCurrentIndex:(NSInteger)page autoAdjustOffset:NO];
    }
    [self.currentViewController endAppearanceTransition];
    if (self.isViewAppeared) {
        [self.currentViewController completelyShow];
    }
    lastViewController.ttTransitioning = NO;
    if ([lastViewController respondsToSelector:@selector(endShow)]) {
        [lastViewController endShow];
    }
    self.currentViewController.ttTransitioning = NO;
    self.currentDirection = TTPageItemMoveDirectionUnknown;
    self.shouldChangeToNextPage = NO;
    if (_delegateHas.hasDidEndDisplayItem) {
        [self.delegate pageViewController:self didDisplayItem:self.currentViewController atIndex:self.currentIndex];
    }
}

#pragma mark - UIScrollViewDelegate

/**
 *  The delegate typically implements this method to obtain the change in content offset from scrollView and draw the affected portion of
 *  the content view.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.needReloadData) return;
    if (self.isVerticalScroll && scrollView.contentOffset.x != 0) return;
    if (!self.isVerticalScroll && scrollView.contentOffset.y != 0) return;
    CGFloat offset = self.isVerticalScroll ? scrollView.contentOffset.y : scrollView.contentOffset.x;
    CGFloat itemWidth = self.isVerticalScroll ? self.view.frame.size.height : self.view.frame.size.width;
    CGFloat offsetABS = offset - itemWidth * self.currentIndex;
    UIViewController *changeToViewController = nil;
    CGFloat progress = fabs(offsetABS) / itemWidth;
    if (offsetABS > 0 && self.currentDirection != TTPageItemMoveDirectionNext) {
        if (self.currentIndex == self.itemCount - 1) {
            return;
        }
        self.currentDirection = TTPageItemMoveDirectionNext;
        if (!self.currentViewController.ttTransitioning) {
            self.currentViewController.ttTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        UIViewController<TTPageItem> *nextViewController = [self _childViewControllerAtIndex:self.currentIndex + 1];
        if (nextViewController &&  !nextViewController.ttTransitioning) {
            nextViewController.ttTransitioning = YES;
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
    } else if (offsetABS < 0 && self.currentDirection != TTPageItemMoveDirectionPrevious) {
        if (self.currentIndex == 0) return;
        self.currentDirection = TTPageItemMoveDirectionPrevious;
        if (!self.currentViewController.ttTransitioning) {
            self.currentViewController.ttTransitioning = YES;
            [self.currentViewController beginAppearanceTransition:NO animated:YES];
        }
        UIViewController<TTPageItem> *preViewController = [self _childViewControllerAtIndex:self.currentIndex - 1];
        if (preViewController && !preViewController.ttTransitioning) {
            preViewController.ttTransitioning = YES;
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
        [self.delegate pageViewController:self didScrollChangeDirection:self.currentDirection offsetProgress:MIN(1.0, progress)];
    }
    if ([self areFloatsAlmostEqual:progress b:1.0 epsilon:0.001] ||
        progress >= 1.0) {
        VOLogI(VOTTProto, @"callback scrollViewDidScroll, shouldChangeToNextPage");
        self.shouldChangeToNextPage = YES;
        [self _shouldChangeToNextPage];
    }
}

//The delegate might not receive this message until dragging has occurred over a small distance.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegateHas.hasWillBeginDragging) {
        [self.delegate pageViewControllerWillBeginDragging:self];
    }
    if (self.currentDirection == TTPageItemMoveDirectionUnknown) {
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<TTPageItem> *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.ttTransitioning) {
                obj.ttTransitioning = NO;
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
        self.currentDirection = TTPageItemMoveDirectionUnknown;
    }
    if (self.partialVisibleViewController) {
        if (self.partialVisibleViewController && self.partialVisibleViewController != self.currentViewController) {
            if ([self.partialVisibleViewController respondsToSelector:@selector(endShow)]) {
                [self.partialVisibleViewController endShow];
            }
        }
        self.partialVisibleViewController = nil;
    }
    for (UIViewController<TTPageItem> *vc in self.viewControllers) {
        if (vc != self.currentViewController) {
            if ([vc respondsToSelector:@selector(resetAdjacentCell)]) {
                [vc resetAdjacentCell];
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

- (void)setDelegate:(id<TTPageDelegate>)delegate {
    _delegate = delegate;
    if (_delegate) {
        _delegateHas.hasWillDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:willDisplayItem:)];
        _delegateHas.hasDidEndDisplayItem = [_delegate respondsToSelector:@selector(pageViewController:didDisplayItem:atIndex:)];
        _delegateHas.hasDidScrollChangeDirection = [_delegate respondsToSelector:@selector(pageViewController:didScrollChangeDirection:offsetProgress:)];
        _delegateHas.hasWillBeginDragging = [_delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)];
    }
}

- (void)setDataSource:(id<TTPageDataSource>)dataSource {
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
