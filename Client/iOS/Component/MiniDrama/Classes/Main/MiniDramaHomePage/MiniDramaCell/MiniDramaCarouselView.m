// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaCarouselView.h"
#import "MiniDramaCarouselCell.h"
#import "MiniDramaCarouselPageControl.h"
#import "MiniDramaCarouselViewFlowLayout.h"

static NSString *MiniDramaCarouselReuseID = @"MiniDramaCarouselCell";

@interface MiniDramaCarouselView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MiniDramaCarouselPageControl *dramaCarouselPageControl;
@property (nonatomic, strong) NSMutableArray<MDDramaInfoModel *> *datas;

@property (nonatomic, assign) NSInteger startDragItemIndex;
@property (nonatomic, assign) NSInteger scrollingItemIndex;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger autoScrollInterval;
@end

@implementation MiniDramaCarouselView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - UI
-(void) initViews {
    self.backgroundColor = [UIColor clearColor];

    self.autoScrollInterval = 3;

    MiniDramaCarouselViewFlowLayout *layout = [[MiniDramaCarouselViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(260, 348);
    layout.minimumInteritemSpacing = 16;
    layout.minimumLineSpacing = 16;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = NO;
    self.collectionView.decelerationRate = 0.99;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [_collectionView registerClass:[MiniDramaCarouselCell class] forCellWithReuseIdentifier:MiniDramaCarouselReuseID];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(348);
    }];

    self.dramaCarouselPageControl = [[MiniDramaCarouselPageControl alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 4)];
    [self addSubview:self.dramaCarouselPageControl];
    [self.dramaCarouselPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(12);
        make.height.mas_equalTo(4);
    }];

}

#pragma mark - public methods
- (void)setMiniDramaDatas:(NSArray<MDDramaInfoModel *> *)miniDramaDatas{
    if (miniDramaDatas && miniDramaDatas.count > 8) {
        miniDramaDatas = [miniDramaDatas subarrayWithRange:NSMakeRange(0, 8)];
    }
    _datas = [NSMutableArray arrayWithArray:miniDramaDatas];
    if (miniDramaDatas && miniDramaDatas.count == 1){
        [self.dramaCarouselPageControl setNumberOfPages:miniDramaDatas.count];
        [self.collectionView layoutIfNeeded];
        [self scrollToItemAtIndex:0 animate:NO];
    } else if (miniDramaDatas && miniDramaDatas.count > 1){
        [_datas addObject:miniDramaDatas.firstObject];
        [_datas addObject:miniDramaDatas[1]];
        [_datas insertObject:miniDramaDatas.lastObject atIndex:0];
        [_datas insertObject:miniDramaDatas[miniDramaDatas.count - 2] atIndex:0];
        [self.dramaCarouselPageControl setNumberOfPages:miniDramaDatas.count];
        [self.collectionView layoutIfNeeded];
        [self scrollToItemAtIndex:2 animate:NO];
    } else {
        [self.dramaCarouselPageControl setNumberOfPages:0];
        [self.collectionView reloadData];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self removeTimer];
    if (newSuperview) {
        if (self.autoScrollInterval > 0) {
            [self addTimer];
        }
    }
}

- (void)setViewisVisible:(BOOL)viewisVisible {
    _viewisVisible = viewisVisible;
    if (viewisVisible) {
        [self addTimer];
    } else {
        [self removeTimer];
    }
}

#pragma mark - timer

- (void)addTimer {
    if (_timer || self.autoScrollInterval <= 0) {
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:self.autoScrollInterval target:self selector:@selector(timerScroll:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}

- (void)timerScroll:(NSTimer *)timer {
    if (!self.superview || !self.window || self.datas.count == 0 || self.datas.count == 1) {
        return;
    }
    NSInteger index =  [self getItemIndexByContentOffsetX:self.collectionView.contentOffset.x];
    if (index < self.datas.count - 3) {
        [self scrollToItemAtIndex:index + 1 animate:YES];
        [self updateCarouselPageControl: index + 1];
    } else {
        if (index == self.datas.count - 3){
            [self scrollToItemAtIndex:1 animate:NO];
            [self scrollToItemAtIndex:2 animate:YES];
            [self updateCarouselPageControl: 2];
        } else if (index == self.datas.count - 2) {
            [self scrollToItemAtIndex:2 animate:NO];
            [self scrollToItemAtIndex:3 animate:YES];
            [self updateCarouselPageControl: 3];
        } else if (index == self.datas.count - 1) {
            [self scrollToItemAtIndex:3 animate:NO];
            [self scrollToItemAtIndex:4 animate:YES];
            [self updateCarouselPageControl: 4];
        }
    }
}

#pragma mark - private methods
-(void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate{
    if (index < 0 || index >= self.datas.count) {
        return;
    }
    CGFloat offsetX = [self getItemOffsetXAtIndex:index];
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animate];
}

-(CGFloat)getItemOffsetXAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.datas.count) {
        return 0;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat leftEdge = (self.collectionView.frame.size.width - layout.itemSize.width) / 2;
    CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
    CGFloat offsetX = leftEdge + itemWidth * index - layout.minimumInteritemSpacing/2 - (self.collectionView.frame.size.width - itemWidth)/2;
    return MAX(offsetX, 0);
}

#pragma mark- UICollectionViewDataSource
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MiniDramaCarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaCarouselReuseID forIndexPath:indexPath];
    cell.dramaInfoModel = _datas[indexPath.row];
    cell.selectDelegate = self.selectDelegate;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return _datas.count;
}

#pragma mark- UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGFloat horizontalSpace = (collectionView.frame.size.width - layout.itemSize.width) / 2;
    CGFloat verticalSpace = (collectionView.frame.size.height - layout.itemSize.height) / 2;
    return UIEdgeInsetsMake(verticalSpace, horizontalSpace, verticalSpace, horizontalSpace);
}


#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger newIndex =  [self getItemIndexByContentOffsetX:scrollView.contentOffset.x];
    if (newIndex < 0 || self.datas.count <= 0 || newIndex >= self.datas.count) {
        return;
    }
    self.scrollingItemIndex = newIndex;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScrollInterval > 0) {
        [self removeTimer];
    }
    self.startDragItemIndex = [self modifyItemIndex:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self modifyItemIndex:scrollView.contentOffset.x];
    if (self.autoScrollInterval > 0) {
        [self addTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.datas && self.datas.count <= 1) {
        return;
    }
    if (fabs(velocity.x) < 0.4 || self.startDragItemIndex != self.scrollingItemIndex) {
        targetContentOffset->x = [self getItemOffsetXAtIndex:self.scrollingItemIndex];
        return;
    }
    NSInteger targetIndex = 0;
    if ((scrollView.contentOffset.x < 0 && targetContentOffset->x <= 0)
        || (targetContentOffset->x < scrollView.contentOffset.x && scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width)) {
        targetIndex = self.scrollingItemIndex - 1;
    } else {
        targetIndex = self.scrollingItemIndex + 1;
    }
    targetContentOffset->x = [self getItemOffsetXAtIndex:targetIndex];
}

#pragma mark- Calculation
- (NSInteger)getItemIndexByContentOffsetX:(CGFloat)offsetX {
    if (_datas.count <= 0) {
        return 0;
    }
   UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
   CGFloat leftEdge = (self.collectionView.frame.size.width - layout.itemSize.width) / 2;
   CGFloat width = self.collectionView.frame.size.width;
   CGFloat middleOffset = offsetX + width / 2;
   CGFloat itemWidth = layout.itemSize.width + layout.minimumInteritemSpacing;
   NSInteger curIndex = 0;
   if (middleOffset - leftEdge >= 0) {
       NSInteger itemIndex = (middleOffset - leftEdge + layout.minimumInteritemSpacing / 2) / itemWidth;
       if (itemIndex < 0) {
           itemIndex = 0;
       } else if (itemIndex >= self.datas.count) {
           itemIndex = self.datas.count - 1;
       }
       curIndex = itemIndex % self.datas.count;
   }
   return curIndex;
}

-(void)updateCarouselPageControl:(NSInteger)itemIndex {
    if (self.datas.count > 1) {
        if (itemIndex == self.datas.count - 4) {
            [self.dramaCarouselPageControl setCurrentPage:self.datas.count - 6];
        } else if (itemIndex == self.datas.count - 3) {
            [self.dramaCarouselPageControl setCurrentPage:self.datas.count - 5];
        } else if (itemIndex == 3) {
            [self.dramaCarouselPageControl setCurrentPage:1];
        } else if (itemIndex == 2) {
            [self.dramaCarouselPageControl setCurrentPage:0];
        }
        [self.dramaCarouselPageControl setCurrentPage:itemIndex - 2];
    } else {
        [self.dramaCarouselPageControl setCurrentPage:0];
    }
}

- (NSInteger)modifyItemIndex:(CGFloat)contentOffsetX{
    if (self.datas.count > 1) {
        if (self.scrollingItemIndex <= 0) {
            [self scrollToItemAtIndex:self.datas.count - 4 animate:NO];
            [self updateCarouselPageControl: self.datas.count - 4];
            return self.datas.count - 4;
        } else if (self.scrollingItemIndex == 1) {
            [self scrollToItemAtIndex:self.datas.count - 3 animate:NO];
            [self updateCarouselPageControl: self.datas.count - 3];
            return self.datas.count - 3;
        } else if (self.scrollingItemIndex >= self.datas.count - 1) {
            [self scrollToItemAtIndex:3 animate:NO];
            [self updateCarouselPageControl: 3];
            return 3;
        } else if (self.scrollingItemIndex == self.datas.count - 2) {
            [self scrollToItemAtIndex:2 animate:NO];
            [self updateCarouselPageControl: 2];
            return 2;
        }
    }
    [self updateCarouselPageControl: self.scrollingItemIndex];;
    return [self getItemIndexByContentOffsetX:contentOffsetX];
}

@end
