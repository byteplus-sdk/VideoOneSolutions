// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPageViewController.h"
#import <objc/runtime.h>
NSUInteger const VELPageMaxCount = NSIntegerMax;

typedef NS_ENUM(NSInteger, VELTransition) {
    VELTransitionIde = 0,
    VELTransitionAppear = 1 << 1,
    VELTransitionDisAppear = 1 << 2,
};

@interface NSObject (VeLievPageItemAdd)

@property (nonatomic, assign) NSUInteger vel_pageIndex;

@property (nonatomic, assign) VELTransition vel_Transition;

@property (nonatomic, assign) BOOL vel_Appearance;
@end

@implementation UIViewController (VeLievPageItemAdd)

- (void)setVel_pageIndex:(NSUInteger)vel_pageIndex {
    objc_setAssociatedObject(self, @selector(vel_pageIndex), @(vel_pageIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)vel_pageIndex {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setVel_Transition:(VELTransition)vel_Transition {
    objc_setAssociatedObject(self, @selector(vel_Transition), @(vel_Transition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELTransition)vel_Transition {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setVel_Appearance:(BOOL)vel_Appearance {
    objc_setAssociatedObject(self, @selector(vel_Appearance), @(vel_Appearance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)vel_Appearance {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end

static NSString *VELPageViewControllerExceptionKey = @"VELPageViewControllerExceptionKey";

@interface VELPageViewController () <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) BOOL isVerticalScroll;
@property (nonatomic, assign) BOOL needReloadData;
@property (nonatomic, assign) BOOL shouldChangeToNextPage;
@property (nonatomic, assign) VELPageDirection currentDirection;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIViewController<VELPageItemProtocol> *> *viewControllers;
@property (nonatomic, assign) BOOL releaseTouch;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<UIViewController<VELPageItemProtocol> *> *> *cacheViewControllers;
@property (nonatomic, strong) UIViewController <VELPageItemProtocol> *currentViewController;
@property (nonatomic, strong) UIViewController <VELPageItemProtocol> *changeToViewController;
@property (nonatomic, assign) CGFloat lastOffset;
@end

@implementation VELPageViewController
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [self setupPageController];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setupPageController];
    }
    return self;
}

- (void)setupPageController {
    self.viewControllers = [[NSMutableArray alloc] init];
    self.cacheViewControllers = [[NSMutableDictionary alloc] init];
    [self.view addSubview:self.scrollView];
    self.currentIndex = VELPageMaxCount;
    self.needReloadData = YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    [self _reloadDataIfNeeded];
    [self _layoutChildViewControllers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self changeTransition:(VELTransitionDisAppear) forViewController:self.currentViewController endAppearance:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self changeTransition:(VELTransitionDisAppear) forViewController:self.currentViewController endAppearance:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeTransition:(VELTransitionAppear) forViewController:self.currentViewController endAppearance:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self changeTransition:(VELTransitionAppear) forViewController:self.currentViewController endAppearance:YES];
}

- (void)_layoutChildViewControllers {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VELPageItemProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = CGRectMake(obj.view.frame.origin.x, obj.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)_reloadDataIfNeeded {
    if (self.needReloadData) {
        [self reloadData];
    }
}

- (void)_clearData {
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VELPageItemProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [self.viewControllers removeAllObjects];
    self.currentDirection = VELPageDirectionUnknown;
    self.itemCount = 0;
    self.currentIndex = VELPageMaxCount;
}

- (UIViewController<VELPageItemProtocol> *)_addChildViewControllerFromDataSourceIndex:(NSUInteger)index transition:(VELTransition)transition {
    UIViewController<VELPageItemProtocol> *viewController = [self _childViewControllerAtIndex:index];
    
    [self changeTransition:(transition) forViewController:viewController endAppearance:YES];
    
    if (viewController) return viewController;
    
    viewController = [self.dataSource pageViewController:self pageForItemAtIndex:index];
    if (!viewController) {
        [NSException raise:VELPageViewControllerExceptionKey format:@"VELPageViewController(%p) pageViewController:pageForItemAtIndex: must return a no nil instance", self];
    }
    viewController.vel_pageIndex = index;
    [self addChildViewController:viewController];
    if (!self.isVerticalScroll) {
        viewController.view.frame = CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        viewController.view.frame = CGRectMake(0, index * self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }
    [self.scrollView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    
    if ([viewController respondsToSelector:@selector(itemControllerDidLoaded)]) {
        [viewController itemControllerDidLoaded];
    }
    
    return viewController;
}

- (void)_veRemoveChildViewController:(UIViewController<VELPageItemProtocol> *)removedViewController {
    [removedViewController willMoveToParentViewController:nil];
    [removedViewController.view removeFromSuperview];
    [removedViewController removeFromParentViewController];
    removedViewController.vel_pageIndex = VELPageMaxCount;
    if ([removedViewController respondsToSelector:@selector(reuseIdentifier)] && removedViewController.reuseIdentifier.length) {
        NSMutableArray<UIViewController<VELPageItemProtocol> *>*reuseViewControllers = [self.cacheViewControllers objectForKey:removedViewController.reuseIdentifier];
        if (!reuseViewControllers) {
            reuseViewControllers = [[NSMutableArray<UIViewController<VELPageItemProtocol> *> alloc] init];
            [self.cacheViewControllers setObject:reuseViewControllers forKey:removedViewController.reuseIdentifier];
        }
        if (![reuseViewControllers containsObject:removedViewController]) {
            [reuseViewControllers addObject:removedViewController];
        }
    }
}

- (UIViewController<VELPageItemProtocol> *)_childViewControllerAtIndex:(NSUInteger)index {
    __block UIViewController<VELPageItemProtocol> *findViewController = nil;
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VELPageItemProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vel_pageIndex == index) {
            findViewController = obj;
        }
    }];
    return findViewController;
}


#pragma mark - Public Methods
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    [self setCurrentIndex:currentIndex animation:NO];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex animation:(BOOL)animation {
    [self setCurrentIndex:currentIndex autoAdjustOffset:YES animation:animation];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex autoAdjustOffset:(BOOL)autoAdjustOffset animation:(BOOL)animation {
    if (_currentIndex == currentIndex) return;
    if (_itemCount == 0) {
        _currentIndex = currentIndex;
        return;
    }
    if (currentIndex > self.itemCount - 1) {
        [NSException raise:VELPageViewControllerExceptionKey format:@"VELPageViewController(%p) currentIndex out of bounds %lu", self, (unsigned long)currentIndex];
    }
    NSMutableArray *addedViewControllers = [[NSMutableArray alloc] init];
    UIViewController<VELPageItemProtocol> *currentVieController = [self _addChildViewControllerFromDataSourceIndex:currentIndex
                                                                                                           transition:(VELTransitionAppear)];
    [addedViewControllers addObject:currentVieController];
    if (currentIndex != 0) {
        UIViewController<VELPageItemProtocol> *nextViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex - 1
                                                                                                             transition:(VELTransitionIde)];
        [addedViewControllers addObject:nextViewController];
    }
    if (self.itemCount > 1 && currentIndex != self.itemCount - 1) {
        UIViewController<VELPageItemProtocol> *preViewController = [self _addChildViewControllerFromDataSourceIndex:currentIndex + 1
                                                                                                            transition:VELTransitionIde];
        [addedViewControllers addObject:preViewController];
    }
    
    NSMutableArray *removedViewController = [[NSMutableArray alloc] init];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VELPageItemProtocol> * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL findVC = NO;
        [addedViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (vc == obj) {
                findVC = YES;
            }
        }];
        if (!findVC) {
            [removedViewController addObject:vc];
        }
    }];
    [removedViewController enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _veRemoveChildViewController:obj];
    }];
    [addedViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.viewControllers containsObject:obj]) {
            [self.viewControllers addObject:obj];
        }
    }];
    [self.viewControllers removeObjectsInArray:removedViewController];
    UIViewController <VELPageItemProtocol> *lastViewController = self.currentViewController;
    _currentIndex = currentIndex;
    self.currentViewController = [self _childViewControllerAtIndex:_currentIndex];
    
    if (autoAdjustOffset) {
        if (!self.isVerticalScroll) {
            [self.scrollView setContentOffset:CGPointMake(currentIndex * self.view.frame.size.width, 0) animated:animation];
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, currentIndex * self.view.frame.size.height) animated:animation];
        }
        if (self.view.window) {
            [self changeTransition:(VELTransitionDisAppear) forViewController:lastViewController endAppearance:YES];
            [self changeTransition:(VELTransitionAppear) forViewController:self.currentViewController endAppearance:YES];
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
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _scrollView;
}

- (void)setDelegate:(id<VELPageControllerDelegate>)delegate {
    _delegate = delegate;
}

- (void)setDataSource:(id<VELPageControllerDataSource>)dataSource {
    _dataSource = dataSource;
    _needReloadData = YES;
}

- (UIViewController<VELPageItemProtocol> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableArray<UIViewController<VELPageItemProtocol> *> *cacheKeyViewControllers = [self.cacheViewControllers objectForKey:reuseIdentifier];
    if (!cacheKeyViewControllers) return nil;
    UIViewController<VELPageItemProtocol> *viewController = [cacheKeyViewControllers firstObject];
    [cacheKeyViewControllers removeObject:viewController];
    if ([viewController respondsToSelector:@selector(itemControllerPrepareForReuse)]) {
        [viewController itemControllerPrepareForReuse];
    }
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
    if ([_dataSource respondsToSelector:@selector(shouldScrollVertically:)]) {
        self.isVerticalScroll = [self.dataSource shouldScrollVertically:self];
    }
    if ([_dataSource respondsToSelector:@selector(numberOfItemInPageViewController:)]) {
        self.itemCount = [self.dataSource numberOfItemInPageViewController:self];
        if (!self.isVerticalScroll) {
            [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * self.itemCount, 0)];
        } else {
            [self.scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height * self.itemCount)];
        }
    }
    if ([_dataSource respondsToSelector:@selector(pageViewController:pageForItemAtIndex:)]) {
        if (preIndex >= _itemCount || preIndex == VELPageMaxCount) {
            [self setCurrentIndex:0 autoAdjustOffset:appearanceTransition animation:NO];
        } else {
            [self setCurrentIndex:preIndex autoAdjustOffset:appearanceTransition animation:NO];
        }
    }
    self.needReloadData = NO;
}

- (void)reloadContentSize {
    if ([_dataSource respondsToSelector:@selector(numberOfItemInPageViewController:)]) {
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
    UIViewController<VELPageItemProtocol> *lastViewController = self.currentViewController;
    CGFloat page = _currentIndex;
    if (self.currentDirection == VELPageDirectionNext) {
        page = self.currentIndex + 1;
    } else {
        page = self.currentIndex - 1;
    }
    if (self.isVerticalScroll) {
        page = self.scrollView.contentOffset.y / self.scrollView.frame.size.height + 0.5;
    } else {
        page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5;
    }
    if (self.currentDirection == VELPageDirectionUnknown) {
        return;
    } else if (self.currentIndex == 0 && self.currentDirection == VELPageDirectionPrevious) {
        return;
    } else if (self.currentIndex == (self.itemCount - 1) && self.currentDirection == VELPageDirectionNext) {
        return;
    } else {
        [self setCurrentIndex:(NSInteger)page autoAdjustOffset:NO animation:NO];
    }
    [self _noticeDisplayCurrentController:lastViewController];
    self.shouldChangeToNextPage = NO;
}

- (void)_noticeDisplayCurrentController:(UIViewController <VELPageItemProtocol>*)lastViewController {
    if (lastViewController != self.currentViewController) {
        if ([_delegate respondsToSelector:@selector(pageViewController:didEndDisplayItem:)]) {
            [self.delegate pageViewController:self didEndDisplayItem:lastViewController];
        }
        if (lastViewController.vel_Transition != VELTransitionIde) {
            [self changeTransition:VELTransitionDisAppear forViewController:lastViewController endAppearance:YES];
        }
        if (self.currentViewController != VELTransitionIde) {
            [self changeTransition:VELTransitionAppear forViewController:self.currentViewController endAppearance:YES];
        }
        self.scrollView.panGestureRecognizer.enabled = YES;
    } else {
        if (self.changeToViewController.vel_Transition != VELTransitionIde) {
            [self changeTransition:VELTransitionDisAppear forViewController:self.changeToViewController endAppearance:YES];
        }
        if (self.currentViewController.vel_Transition != VELTransitionIde) {
            [self changeTransition:VELTransitionAppear forViewController:self.currentViewController endAppearance:YES];
        }
    }
    self.changeToViewController = nil;

    self.currentDirection = VELPageDirectionUnknown;
}

- (void)changeTransition:(VELTransition)transition forViewController:(UIViewController <VELPageItemProtocol>*)viewController endAppearance:(BOOL)endAppearance {
    if (viewController == nil) {
        return;
    }
    if (viewController.vel_Transition != transition
        && transition != VELTransitionIde) {
        [viewController beginAppearanceTransition:(transition == VELTransitionAppear) animated:YES];
        viewController.vel_Appearance = YES;
    }
    
    if ((endAppearance || transition == VELTransitionIde) && (viewController.vel_Appearance)) {
        [viewController endAppearanceTransition];
        viewController.vel_Appearance = NO;
    }
    
    viewController.vel_Transition = transition;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.needReloadData) return;
    if (self.isVerticalScroll && scrollView.contentOffset.x != 0) return;
    if (!self.isVerticalScroll && scrollView.contentOffset.y != 0) return;
    CGFloat offset = self.isVerticalScroll ? scrollView.contentOffset.y : scrollView.contentOffset.x;
    CGFloat itemWidth = self.isVerticalScroll ? self.view.frame.size.height : self.view.frame.size.width;
    CGFloat offsetABS = offset - itemWidth * self.currentIndex;
    CGFloat progress = fabs(offsetABS) / itemWidth;
    if (offsetABS > 0 && self.currentDirection != VELPageDirectionNext) {
        if (self.currentIndex == self.itemCount - 1) {
            return;
        }
        self.currentDirection = VELPageDirectionNext;
        if (progress >= 0.0) {
            [self changeTransition:(VELTransitionDisAppear) forViewController:self.currentViewController endAppearance:NO];
            
            UIViewController<VELPageItemProtocol> *nextViewController = [self _childViewControllerAtIndex:self.currentIndex + 1];
            [self changeTransition:(VELTransitionAppear) forViewController:nextViewController endAppearance:NO];
            self.changeToViewController = nextViewController;
            
            if ([_delegate respondsToSelector:@selector(pageViewController:willDisplayItem:)]) {
                [self.delegate pageViewController:self willDisplayItem:nextViewController];
            }
        }
    } else if (offsetABS < 0 && self.currentDirection != VELPageDirectionPrevious) {
        if (self.currentIndex == 0) {
            return;
        }
        self.currentDirection = VELPageDirectionPrevious;
        if (progress >= 0.0) {
            [self changeTransition:(VELTransitionDisAppear) forViewController:self.currentViewController endAppearance:NO];
            
            UIViewController<VELPageItemProtocol> *preViewController = [self _childViewControllerAtIndex:self.currentIndex - 1];
            [self changeTransition:(VELTransitionAppear) forViewController:preViewController endAppearance:NO];
            self.changeToViewController = preViewController;
            
            if ([_delegate respondsToSelector:@selector(pageViewController:willDisplayItem:)]) {
                [self.delegate pageViewController:self willDisplayItem:preViewController];
            }
        }
    }
    if ([_delegate respondsToSelector:@selector(pageViewController:didScrollChangeDirection:offsetProgress:)]) {
        [self.delegate pageViewController:self didScrollChangeDirection:self.currentDirection offsetProgress:(progress > 1) ? 1 : progress];
    }
    if (progress < 0.0) {
        [self changeTransition:(VELTransitionIde) forViewController:self.currentViewController endAppearance:YES];
        [self changeTransition:(VELTransitionIde) forViewController:self.changeToViewController endAppearance:YES];
        self.currentDirection = VELPageDirectionUnknown;
    }
    if (progress >= 1.0) {
        self.shouldChangeToNextPage = YES;
        if (progress > 1 && self.shouldChangeToNextPage) {
            [self _shouldChangeToNextPage];
        }
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
    UIViewController<VELPageItemProtocol> *targetVC = [self _childViewControllerAtIndex:idx];
    if (targetVC != self.currentViewController) {
        if (targetVC.vel_Transition != VELTransitionAppear) { // fix unpair case
            scrollView.panGestureRecognizer.enabled = NO;
            [self changeTransition:(VELTransitionAppear) forViewController:targetVC endAppearance:YES];
        }
    }
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController<VELPageItemProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.vel_Transition != VELTransitionIde) {
//            [self changeTransition:(VELTransitionIde) forViewController:obj endAppearance:YES];
//        }
//    }];
//}

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
        [self _noticeDisplayCurrentController:self.currentViewController];
    }
}

@end
