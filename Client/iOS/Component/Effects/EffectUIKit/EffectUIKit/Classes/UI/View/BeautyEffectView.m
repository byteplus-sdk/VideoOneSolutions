// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BeautyEffectView.h"
#import "EffectCategoryView.h"
#import "BeautyFaceCell.h"
#import "BeautyHairColorCell.h"
#import <Masonry/Masonry.h>
#import "ColorFaceBeautyViewController.h"
#import "TextSwitchView.h"
#import <objc/runtime.h>
#import "EffectCommon.h"
#import "EffectCollectionView.h"
@interface EffectItem (EffectIntensity)
@property (nonatomic, strong, nullable, readonly) NSArray <TextSwitchItem *> *intensitySwitchItems;
@end
@implementation EffectItem (EffectIntensity)
static char kAssociatedObjectKey_intensitySwitchItems;
- (void)setIntensitySwitchItems:(NSArray<TextSwitchItem *> * _Nullable)intensitySwitchItems {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_intensitySwitchItems, intensitySwitchItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<TextSwitchItem *> *)intensitySwitchItems {
    NSArray<TextSwitchItem *> *items = (NSArray<TextSwitchItem *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_intensitySwitchItems);
    if (items == nil && (self.ID == EffectUIKitNodeTypeStyleMakeup3D || self.ID == EffectUIKitNodeTypeStyleMakeup)) {
        items = [EffectDataManager styleMakeupSwitchItems];
        [self setIntensitySwitchItems:items];
    }
    return items;
}
@end

@interface BeautyEffectView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
EffectUIKitSwitchTabViewDelegate, TextSwitchItemViewDelegate,FaceBeautyViewControllerDelegate,
EffectUIKitUISliderDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) TextSwitchView *textSwitchView;
@property (nonatomic, strong) EffectUISlider *textSlider;
@property (nonatomic, strong) EffectCategoryView *categoryView;
@property (nonatomic, strong) EffectCollectionView *cv;
@property (nonatomic, strong) UIView *vBoard;
@property (nonatomic, strong) FaceBeautyViewController *vcMakeupOption;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) NSArray <TextSwitchItem *> *textSwitchItems;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, assign) BOOL textSliderHidden;
@property (nonatomic, strong, readwrite) EffectUIKitCategoryModel *selectedCategory;
@property (nonatomic, assign, readwrite) NSInteger selectIndex;
@property (nonatomic, assign, readwrite) NSInteger selectIntensityIndex;
@property (nonatomic, weak) EffectItem *currentSelectItem;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, FaceBeautyViewController *> *vcMakeupOptionMap;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@end

@implementation BeautyEffectView

- (NSMutableArray *)faceBeautyViewArray {
    if (_faceBeautyViewArray == nil) {
        _faceBeautyViewArray = [[NSMutableArray alloc] init];
    }
    return _faceBeautyViewArray;
}

- (void)setTextSliderHidden:(BOOL)textSliderHidden {
    _textSliderHidden = textSliderHidden;
    self.textSlider.hidden = textSliderHidden;
    self.textSwitchView.hidden = textSliderHidden;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sliderHeight = 45;
        _topTabHeight = 44;
        _boardContentHeight = 150;
        _sliderBottomMargin = 8;
        _cornerRadius = 7;
        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
        self.visualEffectView.hidden = YES;
        [self.vBoard addSubview:self.visualEffectView];
        [self addSubview:self.textSwitchView];
        [self addSubview:self.textSlider];
        [self addSubview:self.vBoard];
        [self addSubview:self.categoryView];
        [self addSubview:self.resetBtn];
        
        _selectIndex = 0;
        _selectIntensityIndex = 0;
        _colorView = [[UIView alloc] init];
        _colorView.hidden = YES;
        [self addSubview:_colorView];
        [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(70);
            make.right.mas_equalTo(-70);
            make.top.mas_equalTo(25);
            make.height.mas_equalTo(50);
        }];
        
        [self.textSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(10);
            make.height.mas_equalTo(55);
            make.width.mas_equalTo(0.01);
            make.bottom.equalTo(self.textSlider).offset(-4);
        }];
        
        [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-10);
            make.width.mas_equalTo(0.01);
            make.bottom.equalTo(self.textSlider).offset(-4);
        }];
        
        [self.textSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.height.mas_equalTo(self.sliderHeight);
            make.leading.equalTo(self.textSwitchView.mas_trailing);
            make.trailing.equalTo(self.resetBtn.mas_leading);
        }];
        
        [self.vBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(self.textSlider.mas_bottom).offset(self.sliderBottomMargin);
        }];
        
        [self.visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.vBoard);
        }];
        
        [self.categoryView.switchTabView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topTabHeight);
        }];
        
        [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.bottom.equalTo(self).mas_offset(self.bottomMargin);
            make.top.equalTo(self.vBoard);
        }];
        [self roundView:self.vBoard rect:UIRectCornerTopLeft|UIRectCornerTopRight withSize:CGSizeMake((self.cornerRadius), (self.cornerRadius))];
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self roundView:self.vBoard rect:UIRectCornerTopLeft|UIRectCornerTopRight withSize:CGSizeMake((self.cornerRadius), (self.cornerRadius))];
}

- (void)setShowVisulEffect:(BOOL)showVisulEffect {
    _showVisulEffect = showVisulEffect;
    self.visualEffectView.hidden = !showVisulEffect;
    if (showVisulEffect) {
        self.vBoard.backgroundColor = UIColor.clearColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.vBoard setBackgroundColor:_showVisulEffect ? UIColor.clearColor : backgroundColor];
}

- (void)setTopTabHeight:(CGFloat)topTabHeight {
    _topTabHeight = topTabHeight;
    [self.categoryView.switchTabView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.topTabHeight);
    }];
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    [self.textSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.sliderHeight);
    }];
}

- (void)setSliderBottomMargin:(CGFloat)sliderBottomMargin {
    _sliderBottomMargin = sliderBottomMargin;
    [self.vBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textSlider.mas_bottom).offset(self.sliderBottomMargin);
    }];
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    [self.categoryView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(self.bottomMargin);
    }];
}

- (void)setShowResetButton:(BOOL)showResetButton {
    _showResetButton = showResetButton;
    self.resetBtn.hidden = !showResetButton;
    [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.width.mas_equalTo(showResetButton ? 30 : 0.01);
        make.bottom.equalTo(self.textSlider).offset(-4);
    }];
    [self.textSlider setNeedsDisplay];
}

- (void)setupTextSwithForItem:(EffectItem *)item {
    if (item.intensitySwitchItems != nil) {
        [self.textSwitchView setSelectItem:nil];
        [self setTextSwitchItems:item.intensitySwitchItems];
        self.selectIntensityIndex = item.intensityIndex;
        [self.textSwitchView setSelectItem:item.intensitySwitchItems[item.intensityIndex]];
    } else {
        [self.textSwitchView setSelectItem:nil];
        [self setTextSwitchItems:nil];
        self.selectIntensityIndex = 0;
    }
}

- (void)setTextSwitchItems:(NSArray<TextSwitchItem *> *)textSwitchItems {
    _textSwitchItems = textSwitchItems;
    self.textSwitchView.hidden = textSwitchItems.count == 0 || self.textSliderHidden;
    if (textSwitchItems == nil || textSwitchItems.count == 0 || self.textSliderHidden) {
        [self.textSwitchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0.01);
            make.leading.equalTo(self).offset(10);
            make.height.mas_equalTo(55);
            make.bottom.equalTo(self.textSlider).offset(-4);
        }];
        [self.textSlider setNeedsDisplay];
        return;
    }
    self.textSwitchView.items = textSwitchItems;
    
    CGFloat totalWidth = 0.f;
    for (TextSwitchItem *item in textSwitchItems) {
        totalWidth += item.minTextWidth + 8;
    }
    totalWidth += 16 * (textSwitchItems.count - 1);
    [self.textSwitchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(textSwitchItems.count == 0 ? 0 : totalWidth);
        make.leading.equalTo(self).offset(10);
        make.height.mas_equalTo(55);
        make.bottom.equalTo(self.textSlider).offset(-4);
    }];
    [self.textSlider setNeedsDisplay];
}
#pragma mark - public
- (void)reloadData {
    [self.cv reloadData];
    [self.categoryView reloadData];
    if (_vcMakeupOption && [_vcMakeupOption parentViewController]) {
        [_vcMakeupOption reloadData];
    }
}
- (void)refreshUI {
    [self.cv reloadData];
    [self.categoryView reloadData];
    if (_vcMakeupOption && [_vcMakeupOption parentViewController]) {
        [self hideOption:self.superview != nil];
    }
}

- (void)setDataSource:(id<BeautyEffectDataSource>)dataSource {
    _dataSource = dataSource;
    if (self.selectIndex < 0 || self.selectIndex >= self.categories.count) {
        self.selectIndex = 0;
    }
    self.categories = dataSource.dataManager.effectCategoryModelArray;
    self.selectedCategory = self.categories[self.selectIndex];
    NSMutableArray<NSString *> *titles = [NSMutableArray array];
    for (EffectUIKitCategoryModel *model in self.categories) {
        [titles addObject:model.title];
    }
    [self.categoryView setIndicators:titles];
    [self.categoryView selectItemAtIndex:self.selectIndex animated:NO];
    [self switchTabDidSelectedAtIndex:self.selectIndex];
    [self.cv reloadData];
}

- (void)updateProgressWithItem:(nullable EffectItem *)item {
    if (item == nil) {
        self.textSlider.value = 0;
        [self setTextSliderHidden:YES];
        return;
    }
    if (self.textSliderHidden) {
        return;
    }
    NSArray<NSNumber *> *intensityArray = item.validIntensity;
    
    NSArray<NSNumber *> *intensityMaxArray = item.validIntensityMax ?: [self.dataSource.dataManager defaultIntensityMax:item.ID];
    NSArray<NSNumber *> *intensityMinArray = item.validIntensityMin ?:[self.dataSource.dataManager defaultIntensityMin:item.ID];
    [self.textSlider setMinValue:[intensityMinArray[self.selectIntensityIndex] floatValue]];
    [self.textSlider setMaxValue:[intensityMaxArray[self.selectIntensityIndex] floatValue]];
    
    self.textSlider.negativeable = item.availableItem.enableNegative;
    
    if (intensityArray == nil) {
        self.textSlider.value = 0.f;
    } else {
        self.textSlider.value = [intensityArray[self.selectIntensityIndex] floatValue];
    }
    self.textSlider.hidden = !item.showIntensityBar;
    
    [item updateState];
}

- (void)showOption:(FaceBeautyViewController *)optionVC withAnimation:(BOOL)animation {

    optionVC.view.alpha = 0;
    self.vcMakeupOption = optionVC;
    self.categoryView.switchTabView.alpha = 0;
    self.vcMakeupOption.beautyView.alpha = 0;
    self.vcMakeupOption.view.alpha = 0;
    [self.vcMakeupOption showPlaceholder:NO];
    [optionVC addToView:self];
    optionVC.placeholderView = self.categoryView.switchTabView;
    
    [self updateProgressWithItem:optionVC.item.selectChild];
    if (animation) {
        
        [optionVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cv.mas_bottom);
            make.left.right.equalTo(self.cv);
            make.height.equalTo(self.cv);
        }];
        [optionVC showPlaceholder:NO];
        [optionVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.cv);
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.categoryView.switchTabView.alpha = 0;
            self.cv.alpha = 0;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.vcMakeupOption.beautyView.alpha = 1;
            self.vcMakeupOption.view.alpha = 1;
            [self.vcMakeupOption showPlaceholder:YES];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [optionVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.cv);
        }];
        [optionVC showPlaceholder:YES];
    }
}

- (void)hideOption:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.vcMakeupOption showPlaceholder:NO];
            [self.vcMakeupOption.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_bottom);
                make.left.right.equalTo(self.cv);
            }];
            self.vcMakeupOption.view.alpha = 0;
            self.vcMakeupOption.beautyView.alpha = 0;
            self.categoryView.switchTabView.alpha = 1;
            self.cv.alpha = 1;
            [self.vcMakeupOption removeFromView];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self.vcMakeupOption showPlaceholder:NO];
        [self.vcMakeupOption removeFromView];
        self.categoryView.switchTabView.alpha = 1;
        self.cv.alpha = 1;
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    if (v == self) {
        return nil;
    }
    return v;
}

- (void)didClickResetBtn:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffectOnReset:)]) {
        [self.delegate beautyEffectOnReset:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self roundView:self.vBoard rect:UIRectCornerTopLeft|UIRectCornerTopRight withSize:CGSizeMake((self.cornerRadius), (self.cornerRadius))];
}

- (void)deSelectedConflictItemFor:(EffectItem *)item {
    NSArray <NSNumber *>*conflictTypes = [EffectDataManager conflictTypesFor:item.ID];
    if (conflictTypes == nil) {
        return;
    }

    NSMutableArray <NSIndexPath *>* reloadIndexPaths = [NSMutableArray arrayWithCapacity:conflictTypes.count];
    [self.dataSource.selectNodes.allObjects.copy enumerateObjectsUsingBlock:^(EffectItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([conflictTypes containsObject:@(obj.ID)]) {
            [self.dataSource.selectNodes removeObject:obj];
            [obj reset];
            [obj updateState];
            obj.parent.selectChild = nil;
            if (self.delegate
                && [self.delegate respondsToSelector:@selector(beautyEffect:didUnSelectedItem:)]) {
                [self.delegate beautyEffect:self didUnSelectedItem:obj];
            }
            [self.categories enumerateObjectsUsingBlock:^(EffectUIKitCategoryModel * _Nonnull categoryObj, NSUInteger categoryIdx, BOOL * _Nonnull categoryStop) {
                if ([conflictTypes containsObject:@(categoryObj.item.ID)]) {
                    if (categoryObj.item.selectChild) {
                        [self.dataSource.selectNodes removeObject:categoryObj.item.selectChild];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffect:didUnSelectedItem:)]) {
                            [self.delegate beautyEffect:self didUnSelectedItem:categoryObj.item.selectChild];
                        }
                    }
                    [categoryObj.item reset];
                    [categoryObj.item updateState];
                    [reloadIndexPaths addObject:[NSIndexPath indexPathForItem:categoryIdx inSection:0]];
                }
            }];
        }
    }];
    [self.cv reloadItemsAtIndexPaths:reloadIndexPaths];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EffectUIKitCategoryModel *model = self.categories[indexPath.row];
    UICollectionViewCell *cell = nil;
    if (model.type == EffectUIKitNodeTypeHairColor) {
        BeautyHairColorCell *beautyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BeautyHairColorCell" forIndexPath:indexPath];
        self.colorView.hidden = NO;
        [beautyCell.vc setItem:model.item];
        [beautyCell.vc setSelectNodes:self.dataSource.selectNodes dataManager:self.dataSource.dataManager];
        [beautyCell.vc setRemoveTitlePlaceholderView:self.colorView];
        [beautyCell.vc showPlaceholder:YES];
        [beautyCell.vc faceBeautyViewArray:self.faceBeautyViewArray];
        beautyCell.vc.delegate = self;
        cell = beautyCell;
    } else {
        EffectUIKitFaceBeautyViewCell *beautyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EffectUIKitFaceBeautyViewCell" forIndexPath:indexPath];
        [beautyCell.vc setItem:model.item];
        [beautyCell.vc setSelectNodes:self.dataSource.selectNodes dataManager:self.dataSource.dataManager];
        [beautyCell.vc faceBeautyViewArray:self.faceBeautyViewArray];
        beautyCell.vc.delegate = self;
        cell = beautyCell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout


#pragma mark - EffectUIKitSwitchTabViewDelegate
- (void)switchTabDidSelectedAtIndex:(NSInteger)index {
    EffectUIKitCategoryModel *model = self.categories[index];
    if (model.type == EffectUIKitNodeTypeStyleHairDyeFull) {
        for (int i=0; i<self.faceBeautyViewArray.count; i++) {
            FaceBeautyView *view = self.faceBeautyViewArray[i];
            [view hiddenColorListAdapter:YES];
        }
    }
    else {
        for (int i=0; i<self.faceBeautyViewArray.count; i++) {
            FaceBeautyView *view = self.faceBeautyViewArray[i];
            [view hiddenColorListAdapter:NO];
        }
    }
    if ([self.delegate respondsToSelector:@selector(beautyEffect:didSelectedCategory:)]) {
        [self.delegate beautyEffect:self didSelectedCategory:model];
    }
    if (labs(_selectIndex - index) == 1) {
        _selectIndex = index;
        [self.cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    } else {
        _selectIndex = index;
        [self.cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }

    [self showOrHideSliderViewForCategory:model];
    [self updateProgressWithItem:model.item.availableItem];
    self.selectedCategory = model;
}

- (void)showOrHideSliderViewForCategory:(EffectUIKitCategoryModel *)category {
    EffectItem *item = category.item;
    if (item.selectChild == nil) {
        [self setTextSliderHidden:YES];
        return;
    }
    [self showOrHideSliderViewForItem:item];
}

- (void)showOrHideSliderViewForItem:(EffectItem *)item {
    if (item.children == nil) {
        [self setTextSliderHidden:(!item.showIntensityBar || item.ID == EffectUIKitNodeTypeClose)];
        [self setupTextSwithForItem:item];
    } else {
        if (item.selectChild != nil && item.selectChild.children == nil) {
            [self showOrHideSliderViewForItem:item.selectChild];
        } else {
            [self setTextSliderHidden:YES];
        }
    }
}

/// MARK: - TextSwitchItemViewDelegate
- (void)textSwitchItemView:(TextSwitchItemView *)view didSelect:(TextSwitchItem *)item {
    NSUInteger index = [self.textSwitchView.items indexOfObject:item];
    if (index == NSNotFound) {
        return;
    }
    self.selectIntensityIndex = index;
    self.currentSelectItem.intensityIndex = index;
    [self updateProgressWithItem:self.currentSelectItem];
    if ([self.delegate respondsToSelector:@selector(beautyEffect:intensityIndexChanged:)]) {
        [self.delegate beautyEffect:self intensityIndexChanged:index];
    }
}

/// MARK: - FaceBeautyViewControllerDelegate
- (void)faceBeautyViewController:(FaceBeautyViewController *)vc didClickItem:(EffectItem *)item {
    [self showOrHideSliderViewForItem:item];
    if (item.children != nil && item.children.count > 0) {
        FaceBeautyViewController *optionVc = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffect:optionVCForItem:)]) {
            optionVc = [self.delegate beautyEffect:self optionVCForItem:item];
        }
        if (optionVc == nil) {
            optionVc = [self getDefaultFaceBeautyForItem:item];
        }
        [self showOption:optionVc withAnimation:YES];
    } else {
        self.currentSelectItem = item;
        [self updateProgressWithItem:item];
        [self deSelectedConflictItemFor:item];
        if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffect:didSelectedItem:)]) {
            [self.delegate beautyEffect:self didSelectedItem:item];
        }
    }
}

- (void)faceBeautyViewController:(FaceBeautyViewController *)vc didClickBack:(UIView *)sender {
    [self hideOption:YES];
    [self showOrHideSliderViewForCategory:self.selectedCategory];
}

/// MARK: - EffectUIKitUISliderDelegate
- (void)progressDidChange:(EffectUISlider *)sender progress:(CGFloat)progress {
    self.currentSelectItem.intensity = progress;
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffectProgressDidChange:progress:intensityIndex:)]) {
        [self.delegate beautyEffectProgressDidChange:self progress:progress intensityIndex:self.selectIntensityIndex];
    }
}

- (void)progressEndChange:(EffectUISlider *)sender progress:(CGFloat)progress {
    
    self.currentSelectItem.intensity = progress;
    [self.currentSelectItem updateState];
    if (self.delegate && [self.delegate respondsToSelector:@selector(beautyEffectProgressEndChange:progress:intensityIndex:)]) {
        [self.delegate beautyEffectProgressEndChange:self progress:progress intensityIndex:self.selectIntensityIndex];
    }
}

#pragma mark - getter
- (FaceBeautyViewController *)getDefaultFaceBeautyForItem:(EffectItem *)item {
    FaceBeautyViewController *vc = [self.vcMakeupOptionMap objectForKey:@(item.ID)];
    if (vc == nil) {
        vc = [[FaceBeautyViewController alloc] init];
        [self.vcMakeupOptionMap setObject:vc forKey:@(item.ID)];
        vc.delegate = self;
    }
    vc.item = item;
    [vc setSelectNodes:self.dataSource.selectNodes dataManager:self.dataSource.dataManager];
    [vc faceBeautyViewArray:self.faceBeautyViewArray];
    return vc;
}

- (EffectCategoryView *)categoryView {
    if (_categoryView == nil) {
        EffectCategoryView *categoryView = [EffectCategoryView new];
        categoryView.tabDelegate = self;
        categoryView.contentView = self.cv;
        _categoryView = categoryView;
    }
    return _categoryView;
}

- (EffectCollectionView *)cv {
    if (_cv == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        EffectCollectionView *contentCollectionView = [[EffectCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        contentCollectionView.backgroundColor = [UIColor clearColor];
        contentCollectionView.showsHorizontalScrollIndicator = NO;
        contentCollectionView.showsVerticalScrollIndicator = NO;
        contentCollectionView.pagingEnabled = YES;
        contentCollectionView.dataSource = self;
        contentCollectionView.delegate = self;
        [contentCollectionView registerClass:[EffectUIKitFaceBeautyViewCell class] forCellWithReuseIdentifier:@"EffectUIKitFaceBeautyViewCell"];
        [contentCollectionView registerClass:[BeautyHairColorCell class] forCellWithReuseIdentifier:@"BeautyHairColorCell"];
//        contentCollectionView.panGestureRecognizer.delegate = self;
        _cv = contentCollectionView;
    }
    return _cv;
}

- (EffectUISlider *)textSlider {
    if (!_textSlider) {
        _textSlider = [EffectUISlider new];
        _textSlider.backgroundColor = [UIColor clearColor];
        _textSlider.lineHeight = 2.5;
        _textSlider.textOffset = 25;
        _textSlider.animationTime = 0;
        _textSlider.delegate = self;
    }
    return _textSlider;
}

- (TextSwitchView *)textSwitchView {
    if (!_textSwitchView) {
        _textSwitchView = [[TextSwitchView alloc] init];
        _textSwitchView.delegate = self;
    }
    return _textSwitchView;
}

- (UIView *)vBoard {
    if (_vBoard == nil) {
        _vBoard = [[UIView alloc] init];
        _vBoard.clipsToBounds = YES;
        _vBoard.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return _vBoard;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        _resetBtn.hidden = YES;
        [_resetBtn setImage:[EffectCommon imageNamed:@"ic_refresh"] forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(didClickResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}
- (NSMutableDictionary<NSNumber *,FaceBeautyViewController *> *)vcMakeupOptionMap {
    if (!_vcMakeupOptionMap) {
        _vcMakeupOptionMap = [[NSMutableDictionary alloc] init];
    }
    return _vcMakeupOptionMap;
}

- (void)roundView:(UIView *)view rect:(UIRectCorner)corners withSize:(CGSize)size {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:size];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    view.layer.mask = layer;
}
@end
