// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Masonry/Masonry.h>
#import <MediaLive/VELCommon.h>
#import "VELCategoryView.h"
#import "VELSwitchTabView.h"

@interface VELCategoryView () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VELSwitchTabView *tabView;
@property (nonatomic, strong) UIView *vBorder;
@property (nonatomic, assign) BOOL shouldIgnoreAnimation;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) NSInteger currentSelectIndex;
@property (nonatomic, assign) NSInteger lastWillIndex;
@end

@implementation VELCategoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _showTabBottomLine = YES;
        _tabHeight = 44;
        _contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        _tabInset = UIEdgeInsetsZero;
        [self addSubview:self.tabView];
        [self addSubview:self.vBorder];
        
        [self layoutTabView];
        
    }
    return self;
}

- (void)layoutTabView {
    [self.tabView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(self.tabInset.top);
        make.left.equalTo(self).mas_offset(self.tabInset.left);
        make.right.equalTo(self).mas_offset(-self.tabInset.right);
        make.height.mas_equalTo(self.tabHeight);
    }];
    
    [self.vBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.tabView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setShowTabBottomLine:(BOOL)showTabBottomLine {
    _showTabBottomLine = showTabBottomLine;
    self.vBorder.hidden = !showTabBottomLine;
}

- (void)setTabInset:(UIEdgeInsets)tabInset {
    _tabInset = tabInset;
    [self layoutTabView];
}

- (void)setTabHeight:(CGFloat)tabHeight {
    _tabHeight = tabHeight;
    [self layoutTabView];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).mas_offset(contentInset);
    }];
}
- (void)reloadData {
    [self.tabView reloadData];
}

#pragma mark - public
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    self.currentSelectIndex = index;
    self.lastWillIndex = index;
    self.selectIndex = index;
    [self.tabView selectItemAtIndex:index animated:animated];
}

- (VELSwitchTabView *)switchTabView {
    return self.tabView;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.contentView.bounds.size;
}

- (void)adjustSelectMethodWith:(CGFloat)proportion {
    if (ABS(proportion - self.currentSelectIndex) < 0.01) {
        return;
    }
    NSInteger willSelectIndex = self.currentSelectIndex;
    if (proportion > self.currentSelectIndex) {
        willSelectIndex = ceil(proportion);
    } else {
        willSelectIndex = floor(proportion);
    }
    
    if (willSelectIndex < 0 || willSelectIndex >= self.tabView.categories.count) {
        return;
    }
    
    if (willSelectIndex != self.lastWillIndex) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(categoryView:willDeSelectIndex:)]) {
            [self.delegate categoryView:self willDeSelectIndex:self.lastWillIndex];
        }
        if (self.lastWillIndex != self.currentSelectIndex) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(categoryView:didDeSelectIndex:)]) {
                [self.delegate categoryView:self didDeSelectIndex:self.lastWillIndex];
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(categoryView:willSelectIndex:)]) {
            [self.delegate categoryView:self willSelectIndex:willSelectIndex];
        }
        self.lastWillIndex = willSelectIndex;
    }
}

- (void)adjustSelectMethodWithWhenSelectIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(categoryView:didSelectIndex:)]) {
        [self.delegate categoryView:self didSelectIndex:index];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(categoryView:didDeSelectIndex:)]) {
        if (index != self.lastWillIndex) {
            [self.delegate categoryView:self didDeSelectIndex:self.lastWillIndex];
        }
        if (index != self.currentSelectIndex) {
            [self.delegate categoryView:self didDeSelectIndex:self.currentSelectIndex];
        }
    }
    self.currentSelectIndex = index;
    self.lastWillIndex = index;
}

- (void)adjustScrollViewDidEndScroll:(UIScrollView *)scrollView {
    NSInteger wouldSelectIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (self.tabView.selectedIndex != wouldSelectIndex) {
        [self.tabView selectItemAtIndex:wouldSelectIndex animated:YES];
    }
    [self adjustSelectMethodWithWhenSelectIndex:wouldSelectIndex];
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self adjustScrollViewDidEndScroll:scrollView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
    if (!decelerate) {
        [self adjustScrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.shouldIgnoreAnimation = NO;
    if (!self.isDragging) {
        [self adjustScrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.shouldIgnoreAnimation) {
        return;
    }
    CGFloat offsetX = self.contentView.contentOffset.x;
    CGFloat proportion = offsetX / self.contentView.frame.size.width;
    if (!isnan(proportion)) {
        self.tabView.proportion = proportion;
        [self adjustSelectMethodWith:proportion];
    }
}

#pragma mark - getter
- (VELSwitchTabView *)tabView {
    if (!_tabView) {
        _tabView = [[VELSwitchTabView alloc] initWithTitles:@[]];
        _tabView.delegate = self.tabDelegate;
        _tabView.normalTextColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0];
        _tabView.hightlightTextColor = [UIColor whiteColor];
        [self.contentView invalidateIntrinsicContentSize];
        [self.contentView layoutIfNeeded];
    }
    return _tabView;
}

#pragma mark - setter
- (void)setTabDelegate:(id<VELSwitchTabViewDelegate>)tabDelegate {
    _tabDelegate = tabDelegate;
    self.tabView.delegate = tabDelegate;
}

- (void)setIndicators:(NSArray *)titles {
    [self.tabView refreshWithTitles: titles];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tabView selectItemAtIndex:self.selectIndex animated:NO];
    });
}


- (void)setContentView:(UICollectionView *)contentView {
    if (_contentView == contentView) {
        return;
    }
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    contentView.delegate = self;
    [self insertSubview:contentView atIndex:0];
    [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).mas_offset(self.contentInset);
    }];
}

- (UIView *)vBorder {
    if (_vBorder) {
        return _vBorder;
    }
    
    _vBorder = [[UIView alloc] init];
    _vBorder.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    return _vBorder;
}

@end
