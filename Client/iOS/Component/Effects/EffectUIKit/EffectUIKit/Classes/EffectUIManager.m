// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectUIManager.h"
#import "BeautyEffectView.h"
#import "EffectDataManager.h"
#import "ColorFaceBeautyViewController.h"
#import "FaceBeautyViewController.h"
#import "EffectConfig.h"
#import "SaveLocalParameterManager.h"
#import "BubbleTipManager.h"
#import "EffectUISlider.h"
#import <Masonry/Masonry.h>
#import "CompareView.h"
#import "EffectCommon.h"
#define EFFECT_UI_DEFAULT_CONFIG @"EFFECT_UI_DEFAULT_CONFIG"
@interface EffectUIManager () <BeautyEffectDelegate, BeautyEffectDataSource,
CompareViewDelegate, EffectUIKitUIManagerDelegate>
@property (nonatomic, strong, readwrite) EffectUIResourceHelper *resourceHelper;
// BeautyEffectDataSource
@property (nonatomic, strong, readwrite, nullable) NSMutableSet<EffectItem *> *selectNodes;
@property (nonatomic, strong, readwrite) EffectDataManager *dataManager;
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, strong) BeautyEffectView *beautyBoardView;
@property (nonatomic, strong) CompareView *compareView;
@property (nonatomic, strong) EffectItem *currentItem;
@property (nonatomic, strong) BubbleTipManager *tipManager;
@property (nonatomic, copy) NSString *locaSavedKey;
@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, strong) UIControl *maskControl;

@end

@implementation EffectUIManager
@synthesize showTargetView = _showTargetView;
- (instancetype)init {
    return [self initWithIdentifier:@"default"];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier fromVC:[EffectCommon topViewController]];
}

- (instancetype)initWithIdentifier:(NSString *)identifier fromVC:(UIViewController *)fromVC {
    if (self = [super init]) {
        _bottomMargin = EffectCommon.safeAreaInsets.bottom;
        _backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _sliderHeight = 45;
        _topTabHeight = 44;
        _boardContentHeight = 160;
        _sliderBottomMargin = 8;
        _cacheable = YES;
        _defaultEffectOn = YES;
        _showReset = YES;
        _showCompare = YES;
        _cornerRadius = 8;
        self.identifier = identifier;
        self.fromVC = fromVC;
    }
    return self;
}

- (BOOL)isShowing {
    if (_beautyBoardView.superview == nil || _beautyBoardView.superview != _showTargetView) {
        [_beautyBoardView removeFromSuperview];
        return NO;
    }
    return _fromVC != nil && (_beautyBoardView.superview == _fromVC.view || _beautyBoardView.superview == self.showTargetView);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    _beautyBoardView.backgroundColor = backgroundColor;
}

- (void)setShowVisulEffect:(BOOL)showVisulEffect {
    _showVisulEffect = showVisulEffect;
    _beautyBoardView.showVisulEffect = showVisulEffect;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    _beautyBoardView.cornerRadius = cornerRadius;
}

- (void)setShowCompare:(BOOL)showCompare {
    _showCompare = showCompare;
    [self.compareView updateShowCompare:showCompare];
    [self showCompareViewFromTarget:self.showTargetView];
}

- (void)setFromVC:(UIViewController *)fromVC {
    if (_fromVC != fromVC) {
        [self hide];
        [_beautyBoardView removeFromSuperview];
        _beautyBoardView = nil;
    }
    _fromVC = fromVC;
    [self showCompareViewFromTarget:self.showTargetView];
}

- (void)setShowReset:(BOOL)showReset {
    _showReset = showReset;
    self.beautyBoardView.showResetButton = showReset;
}

- (void)show {
    if (self.isShowing) {
        return;
    }
    [self showBottomView:self.beautyBoardView target:self.showTargetView];
}

- (void)hide {
    if (!self.isShowing) {
        return;
    }
    [self hideBottomView:_beautyBoardView];
}

- (void)reset {
    [SaveLocalParameterManager deleteFilesWithKey:self.locaSavedKey];
    [self resetToDefaultEffect:self.defaultEffectOn ? self.dataManager.buttonItemArrayWithDefaultIntensity : @[]];
}

- (void)recover {
    NSArray <EffectItem *>* localItems = nil;
    if (self.cacheable) {
        localItems = [SaveLocalParameterManager reloadLocalDataWith:self.dataManager WithKey:self.locaSavedKey];
    } else {
        localItems = self.defaultEffectOn ? self.dataManager.buttonItemArrayWithDefaultIntensity : @[];
    }
    [self resetToDefaultEffect:localItems];
}
- (void)reloadData {
    [self.beautyBoardView reloadData];
}
- (void)resetToDefaultEffect:(NSArray<EffectItem *> *)items {
    for (EffectItem *item in self.selectNodes) {
        if (item.ID == EffectUIKitNodeTypeFilter) {
            [self updateFilterItem:item select:NO];
        } else if (item.ID == EffectUIKitNodeTypeSticker) {
            [self updateStickerItem:item select:NO];
        } else if (item.model != nil) {
            [self updateComposerItem:item select:NO];
        }
    }
    
    [self.selectNodes removeAllObjects];
    [self.selectNodes addObjectsFromArray:items];
    
    if ([self.selectNodes.allObjects containsObject:self.currentItem]) {
        [self.beautyBoardView updateProgressWithItem:self.currentItem];
    } else {
        self.currentItem = nil;
        [self.beautyBoardView updateProgressWithItem:nil];
    }
    [self updateComposerNode:self.selectNodes.allObjects];
    for (EffectItem *item in items) {
        if (item.ID == EffectUIKitNodeTypeFilter) {
            [self updateFilterItem:item select:YES];
        } else if (item.ID == EffectUIKitNodeTypeSticker) {
            [self updateStickerItem:item select:YES];
        } else if (item.model != nil) {
            [self updateComposerNodeIntensity:item];
        }
    }
    if (_beautyBoardView) {
        [_beautyBoardView refreshUI];
    }
}
/// MARK: - BeautyEffectDelegate
- (void)beautyEffect:(BeautyEffectView *)view didSelectedItem:(EffectItem *)item {
    if (item.ID == EffectUIKitNodeTypeClose) {
        self.currentItem = nil;
    } else {
        self.currentItem = item;
    }
    EffectUIKitNode nodeType = item.validID;
    if (nodeType == EffectUIKitNodeTypeFilter) {
        [self updateFilterItem:item select:YES];
    } else if (nodeType == EffectUIKitNodeTypeSticker) {
        [self updateStickerItem:item select:YES];
    } else {
        [self updateComposerItem:item select:YES];
    }
    [SaveLocalParameterManager saveDataWith:self.selectNodes andKey:self.locaSavedKey];
}

- (void)beautyEffect:(BeautyEffectView *)view didUnSelectedItem:(EffectItem *)item {
    EffectUIKitNode nodeType = item.validID;
    if (nodeType == EffectUIKitNodeTypeFilter) {
        [self updateFilterItem:item select:NO];
    } else if (nodeType == EffectUIKitNodeTypeSticker) {
        [self updateStickerItem:item select:NO];
    } else {
        [self updateComposerItem:item select:NO];
    }
    [SaveLocalParameterManager saveDataWith:self.selectNodes andKey:self.locaSavedKey];
}

- (void)beautyEffectOnReset:(BeautyEffectView *)view {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectOnResetClickWithCompletion:)]) {
        __weak __typeof__(self)weakSelf = self;
        [self.delegate effectOnResetClickWithCompletion:^(BOOL result) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (result) {
                [self reset];
            }
        }];
    }
    [SaveLocalParameterManager saveDataWith:self.selectNodes andKey:self.locaSavedKey];
}

- (void)effectBaseView:(CompareView *)view onTouchDownCompare:(UIView *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectOnTouchUpCompare)]) {
        [self.delegate effectOnTouchDownCompare];
    }
}

- (void)effectBaseView:(CompareView *)view onTouchUpCompare:(UIView *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectOnTouchUpCompare)]) {
        [self.delegate effectOnTouchUpCompare];
    }
}

- (void)beautyEffectProgressDidChange:(BeautyEffectView *)sender
                             progress:(CGFloat)progress
                       intensityIndex:(NSInteger)intensityIndex {
    EffectUIKitNode nodeType = self.currentItem.validID;
    if (nodeType == EffectUIKitNodeTypeFilter) {
        [self updateFilterItemIntensity:self.currentItem progress:progress];
    } else if (self.currentItem.model != nil) {
        [self updateComposerNodeIntensity:self.currentItem];
    }
    [SaveLocalParameterManager updateNodeIntensityValue:self.currentItem WithKey:self.locaSavedKey];
}

- (void)checkEffectItem:(EffectItem *)item completion:(void (^)(EffectItem *item))completion {
    if (item.ID == EffectUIKitNodeTypeClose) {
        completion(item);
        return;
    }
    
    NSString *path = item.resourcePath;
    if (item.model != nil) {
        path = [self.resourceHelper composerNodePath:item.resourcePath];
    } else if (item.ID == EffectUIKitNodeTypeFilter) {
        path = [self.resourceHelper filterPath:item.resourcePath];
    } else if (item.ID == EffectUIKitNodeTypeSticker) {
        path = [self.resourceHelper stickerPath:item.resourcePath];
    }
    
    if ([self.resourceHelper isFileExistAt:path isDir:YES]) {
        completion(item);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectFallbackPathForNode:)]) {
        path = [self.delegate effectFallbackPathForNode:path];
        if ([self.resourceHelper isFileExistAt:path isDir:YES]) {
            completion(item);
            return;
        }
    }
    
    
    BOOL shouldDownload = YES;
    if (![self.resourceHelper isFileExistAt:path isDir:YES]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(effectShouldDownloadNode:)]) {
            shouldDownload = [self.delegate effectShouldDownloadNode:path];
        }
    }
    
    if (!shouldDownload) {
        completion(item);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(effectDownloadNode:progress:completion:)]) {
        __weak __typeof__(item)weakItem = item;
        [self.delegate effectDownloadNode:path
                                 progress:item.progressBlock
                               completion:^(BOOL success, NSError * _Nonnull error) {
            __strong __typeof__(weakItem)item = weakItem;
            if (item.completionBlock) {
                item.completionBlock(success, error);
            }
            completion(item);
        }];
    } else {
        completion(item);
    }
}


- (void)updateFilterItem:(EffectItem *)item select:(BOOL)select {
    __weak __typeof__(self)weakSelf = self;
    [self checkEffectItem:item completion:^(EffectItem *item) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self _updateFilterItem:item select:select];
    }];
}

- (void)_updateFilterItem:(EffectItem *)item select:(BOOL)select {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectFilterPathChanged:intensity:)]) {
        if (select && item.ID != EffectUIKitNodeTypeClose) {
            [self.delegate effectFilterPathChanged:[self.resourceHelper filterPath:item.resourcePath]?:@""
                                         intensity:item.intensity];
        } else {
            [self.delegate effectFilterPathChanged:@"" intensity:0];
        }
    }
}

- (void)updateFilterItemIntensity:(EffectItem *)item progress:(CGFloat)progress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectFilterIntensityChanged:)]) {
        [self.delegate effectFilterIntensityChanged:progress];
    }
}

- (void)updateStickerItem:(EffectItem *)item select:(BOOL)select {
    __weak __typeof__(self)weakSelf = self;
    [self checkEffectItem:item completion:^(EffectItem *item) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self _updateStickerItem:item select:select];
    }];
}

- (void)_updateStickerItem:(EffectItem *)item select:(BOOL)select {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectStickerPathChanged:)]) {
        if (select && item.ID != EffectUIKitNodeTypeClose) {
            [self.delegate effectStickerPathChanged:[self.resourceHelper stickerPath:item.resourcePath]?:@""];
            if (item.tipTitle.length > 0 || item.tipDesc.length > 0) {
                [self.tipManager showBubble:item.tipTitle desc:item.tipDesc duration:2];
            }
        } else {
            [self.delegate effectStickerPathChanged:@""];
        }
    }
}

- (void)updateComposerItem:(EffectItem *)item select:(BOOL)select {
    __weak __typeof__(self)weakSelf = self;
    [self checkEffectItem:item completion:^(EffectItem *item) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self _updateComposerItem:item select:select];
    }];
}
- (void)_updateComposerItem:(EffectItem *)item select:(BOOL)select {
    
    // generate nodes from selectNodes
    NSMutableSet<NSString *> *set = [NSMutableSet set];
    NSMutableArray<EffectItem *> *items = [NSMutableArray array];
    for (EffectItem *selItem in self.selectNodes) {
        if (selItem.model != nil && ![set containsObject:selItem.model.path]) {
            [set addObject:selItem.model.path];
            [items addObject:selItem];
        }
    }
    
    // do updateComposerNode
    [self updateComposerNode:[items copy]];
    
    // do updateComposerNodeIntensity
    if (item != nil && select) {
        // close all children of item's parent
        if (item.ID == EffectUIKitNodeTypeClose) {
            NSArray<EffectItem *> *allChildren = item.parent.allChildren;
            for (EffectItem *child in allChildren) {
                if (child.model != nil) {
                    [self updateComposerNodeIntensity:child];
                }
            }
        }
        // update current item's intensity
        if (item.model != nil && select) {
            [self updateComposerNodeIntensity:item];
        }
    } else {
        // update all items' intensity
        for (EffectItem *item in self.selectNodes) {
            [self updateComposerNodeIntensity:item];
        }
    }
}

- (void)updateComposerNode:(NSArray<EffectItem *> *)items {
    NSMutableArray<NSString *> *nodes = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableArray<NSString *> *tags = [NSMutableArray arrayWithCapacity:items.count];
    for (EffectItem *item in items) {
        if (item.model.path != nil && [self.resourceHelper composerNodePathExist:item.model.path]) {
            [nodes addObject:[self.resourceHelper composerNodePath:item.model.path]];
            [tags addObject:item.model.tag == nil ? @"" : item.model.tag];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectBeautyNodesChanged:tags:)]) {
        [self.delegate effectBeautyNodesChanged:nodes tags:tags];
    }
}

- (void)updateComposerNodeIntensity:(EffectItem *)item {
    [self updateComposerNodeIntensity:item intensityArray:nil];
}

- (void)updateComposerNodeIntensity:(EffectItem *)item intensityArray:(NSArray <NSNumber *>*)intensityArray {
    for (int i = 0; i < item.model.keyArray.count; i++) {
        if (item.model.path != nil && [self.resourceHelper composerNodePathExist:item.model.path]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(effectBeautyNode:nodeKey:nodeValue:)]) {

                [self.delegate effectBeautyNode:[self.resourceHelper composerNodePath:item.model.path]
                                        nodeKey:item.model.keyArray[i]
                                      nodeValue:[(intensityArray ?: item.intensityArray)[i] floatValue]];
            }
        }
    }
}

/// MARK: - UI
- (void)showCompareViewFromTarget:(UIView *)target {
    if (self.showCompare && self.compareView.superview != target) {
        [self.compareView removeFromSuperview];
        [target addSubview:self.compareView];
        [self.compareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(target);
        }];
    }
}

- (void)showMaskControlFromTarget:(UIView *)target {
    if (self.maskControl.superview != target) {
        [self.maskControl removeFromSuperview];
        [target addSubview:self.maskControl];
    }
    [self.maskControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(target);
    }];
}

- (void)hideMaskControl {
    [self.maskControl removeFromSuperview];
}

- (void)showBottomView:(UIView *)view target:(UIView *)target {
    [self showMaskControlFromTarget:target];
    [self showCompareViewFromTarget:target];
    if (view.superview != target) {
        [view removeFromSuperview];
    }
    [target addSubview:view];
    CGFloat height = [self getContentHeight];
    view.frame = CGRectMake(0, target.frame.size.height, target.frame.size.width, height);
    [view setNeedsLayout];
    [view layoutIfNeeded];
    [self reloadData];
    view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
        view.frame = CGRectMake(0,
                                target.frame.size.height - height,
                                target.frame.size.width,
                                height);
    } completion:^(BOOL finished) {
    }];
}

- (void)hideBottomView:(UIView *)view {
    UIView *target = view.superview;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0;
        view.frame = CGRectMake(0, target.frame.size.height, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {
        view.alpha = 1;
        [self removeBottomView];
        [self hideMaskControl];
        if (self.didHidBlock) {
            self.didHidBlock();
        }
    }];
}

- (void)removeBottomView {
    [self.beautyBoardView removeFromSuperview];
}

- (void)setDefaultEffectOn:(BOOL)defaultEffectOn {
    _defaultEffectOn = defaultEffectOn;
    self.dataManager.defaultEffectOn = defaultEffectOn;
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin;
    self.beautyBoardView.bottomMargin = bottomMargin;
}

- (void)setTopTabHeight:(CGFloat)topTabHeight {
    _topTabHeight = topTabHeight;
    self.beautyBoardView.topTabHeight = topTabHeight;
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    self.beautyBoardView.sliderHeight = sliderHeight;
}

- (void)setSliderBottomMargin:(CGFloat)sliderBottomMargin {
    _sliderBottomMargin = sliderBottomMargin;
    self.beautyBoardView.sliderBottomMargin = sliderBottomMargin;
}

- (void)setCacheable:(BOOL)cacheable {
    _cacheable = cacheable;
    self.dataManager.cacheable = cacheable;
}

- (EffectDataManager *)dataManager {
    if (_dataManager == nil) {
        _dataManager = [[EffectDataManager alloc] initWithType:EffectUIKitTypeLite];
        _dataManager.defaultEffectOn = self.defaultEffectOn;
        _dataManager.cacheable = self.cacheable;
    }
    return _dataManager;
}

- (NSMutableSet<EffectItem *> *)selectNodes {
    if (!_selectNodes) {
        _selectNodes = [[NSMutableSet alloc] init];
    }
    return _selectNodes;
}

- (BeautyEffectView *)beautyBoardView {
    if (_beautyBoardView == nil) {
        _beautyBoardView = [[BeautyEffectView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                 self.showTargetView.frame.size.width,
                                                                                 [self getContentHeight])];
        _beautyBoardView.delegate = self;
        _beautyBoardView.dataSource = self;
        _beautyBoardView.bottomMargin = self.bottomMargin;
        _beautyBoardView.showResetButton = self.showReset;
        _beautyBoardView.sliderHeight = self.sliderHeight;
        _beautyBoardView.topTabHeight = self.topTabHeight;
        _beautyBoardView.boardContentHeight = self.boardContentHeight;
        _beautyBoardView.sliderBottomMargin = self.sliderBottomMargin;
        _beautyBoardView.backgroundColor = self.backgroundColor;
        _beautyBoardView.showVisulEffect = self.showVisulEffect;
        _beautyBoardView.cornerRadius = self.cornerRadius;
    }
    return _beautyBoardView;
}

- (CompareView *)compareView {
    if (!_compareView) {
        _compareView = [[CompareView alloc] initWithButtomMargin:[self getContentHeight] + 10];
        _compareView.delegate = self;
        [_compareView updateShowCompare:self.showCompare];
    }
    return _compareView;
}

- (CGFloat)getContentHeight {
    return (self.boardContentHeight + self.topTabHeight + self.sliderHeight + self.bottomMargin);
}

- (EffectUIResourceHelper *)resourceHelper {
    if (!_resourceHelper) {
        _resourceHelper = [[EffectUIResourceHelper alloc] init];
    }
    return _resourceHelper;
}

- (BubbleTipManager *)tipManager {
    if (!_tipManager) {
        _tipManager = [[BubbleTipManager alloc] initWithContainer:self.showTargetView topMargin:70];
    }
    return _tipManager;
}

- (NSString *)locaSavedKey {
    if (!_locaSavedKey) {
        _locaSavedKey = [NSString stringWithFormat:@"%@_saved", self.identifier];
    }
    return _locaSavedKey;
}

- (UIView *)showTargetView {
    if (!_showTargetView) {
        UIViewController *vc = self.fromVC ?: [EffectCommon topViewController];
        _showTargetView = vc.view;
    }
    return _showTargetView;
}

- (void)setShowTargetView:(UIView *)showTargetView {
    if (_showTargetView != showTargetView) {
        [self hide];
        [_beautyBoardView removeFromSuperview];
        _beautyBoardView = nil;
    }
    _showTargetView = showTargetView;
}

- (UIControl *)maskControl {
    if (!_maskControl) {
        _maskControl = [[UIControl alloc] init];
        [_maskControl addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskControl;
}

- (void)dealloc {
    if (self.compareView.superview) {
        [self.compareView removeFromSuperview];
    }
}
@end
